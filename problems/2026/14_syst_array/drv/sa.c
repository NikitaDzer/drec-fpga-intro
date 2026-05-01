#include <linux/delay.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/of.h>
#include <linux/mm.h>
#include <linux/of_irq.h>
#include <linux/dma-mapping.h>
#include <linux/miscdevice.h>
#include <linux/uaccess.h>

static uint16_t *buf_a;
static uint16_t *buf_b;
static uint16_t *buf_c;

static dma_addr_t phys_a;
static dma_addr_t phys_b;
static dma_addr_t phys_c;

static void __iomem *sa_mmio_reg;
static struct device *sa_dev;

static DECLARE_COMPLETION(compute_done);

static ssize_t sa_write(struct file *filp,
                        const char __user *buf,
                        size_t count,
                        loff_t *ppos) {
    uint32_t addrs[3] = {};

    if ( count < sizeof(addrs) ) {
        return -EINVAL;
    }

    /**
     * Get addresses from user.
     */
    if ( copy_from_user(addrs, buf, sizeof(addrs)) ) {
        return -EFAULT;
    }

    /**
     * Copy matrices to DMA mapped region.
     */
    if ( copy_from_user(buf_a, (void __user *)addrs[0], PAGE_SIZE) ) {
        return -EFAULT;
    }

    if ( copy_from_user(buf_b, (void __user *)addrs[1], PAGE_SIZE) ) {
        return -EFAULT;
    }

    /**
     * Write matrix addresses into SA.
     */
    iowrite32(phys_b, sa_mmio_reg);
    iowrite32(phys_a, sa_mmio_reg);
    iowrite32(phys_c, sa_mmio_reg);

    /**
     * Wait for compute.
     */
    wait_for_completion_timeout(&compute_done, msecs_to_jiffies(1000));

    /**
     * Copy result from DMA mapped region.
     */
    if ( copy_to_user((void __user *)addrs[2], buf_c, PAGE_SIZE) ) {
        return -EFAULT;
    }

    return sizeof(addrs);
}

static const struct file_operations sa_fops = {
    .owner = THIS_MODULE,
    .write = sa_write,
};

static struct miscdevice sa_misc = {
    .minor = MISC_DYNAMIC_MINOR,
    .name = "sa-dev",
    .fops = &sa_fops,
};

static irqreturn_t sa_irq_handler(int irq, void *dev_id)
{
    return IRQ_WAKE_THREAD;
}

static irqreturn_t sa_irq_thread(int irq, void *dev_id)
{
    struct device *dev = dev_id;
    dev_info(dev, "IRQ received\n");
    
    complete(&compute_done);
    return IRQ_HANDLED;
}

static int sa_probe(struct platform_device *pdef) {
    struct device *dev = &pdef->dev;
    sa_dev = dev;
    int ret = 0;

    /**
     * Get MMIO region for SA register.
     */
    sa_mmio_reg = devm_platform_ioremap_resource(pdef, 0);
    if ( IS_ERR(sa_mmio_reg) ) {
        return PTR_ERR(sa_mmio_reg);
    }
    dev_info(dev, "MMIO at %px\n", sa_mmio_reg);

    /**
     * Allocate DMA mapped region for matrices.
     */
    ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32));
    if ( ret ) {
        dev_err_probe(dev, ret, "Failed to set DMA mask!\n");
    }

    buf_a = dmam_alloc_coherent(dev, PAGE_SIZE, &phys_a, GFP_KERNEL);
    buf_b = dmam_alloc_coherent(dev, PAGE_SIZE, &phys_b, GFP_KERNEL);
    buf_c = dmam_alloc_coherent(dev, PAGE_SIZE, &phys_c, GFP_KERNEL);

    dev_info(dev, "Buffer A at %px (%x)\n",  buf_a, phys_a);
    dev_info(dev, "Buffer B at %px (%x)\n",  buf_b, phys_b);
    dev_info(dev, "Buffer C at %px (%x)\n",  buf_c, phys_c);

    if (!buf_a || !buf_b || !buf_c) {
        return -ENOMEM;
    }

    /**
     * Allocate IRQ for device.
     */
    int irq = platform_get_irq(pdef, 0);
    if ( irq < 0 ) {
        dev_err(dev, "Failed to get IRQ\n");
        return irq;
    }
    dev_info(dev, "Allocate IRQ %d\n", irq);

    ret = request_threaded_irq(irq, sa_irq_handler, sa_irq_thread,
                               IRQF_ONESHOT, "sa-irq", dev);
    if ( ret ) {
        dev_err(dev, "Failed to request IRQ\n");
        return ret;
    }

    /**
     * Register SA as miscdevice.
     */
    ret = misc_register(&sa_misc);
    if ( ret ) {
        dev_err_probe(dev, ret, "Failed to register miscdevice!\n");
        return ret;
    }

    dev_info(dev, "Systolic array registered\n");
    return 0;
}

static const struct of_device_id sa_dt_match[] = {{
        .compatible = "drec-fpga-intro,sa-dev",
    }, {},
};
MODULE_DEVICE_TABLE(of, sa_dt_match);

static struct platform_driver sa_drv = {
    .probe = sa_probe,
    .driver = {
        .name = KBUILD_MODNAME,
        .of_match_table = sa_dt_match,
    },
};

module_platform_driver(sa_drv);

MODULE_LICENSE("GPL");
