#include <linux/module.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/uaccess.h>
#include <linux/slab.h>
#include <linux/vmalloc.h>
#include "cmds.h"

static void *kmalloc_ptr = NULL;
static void *vmalloc_ptr = NULL;

static int allocate_kmalloc(unsigned long size) {
	kmalloc_ptr = kmalloc(size, GFP_KERNEL);

        if (!kmalloc_ptr) {
            pr_err("kmalloc allocation (%lu) is failed\n", size);
            return -ENOMEM;
        }
        pr_info("kmalloc allocation (%lu) is successful\n", size);

	return 0;
}

static int free_kmalloc(void) {
        if (kmalloc_ptr) {
            kfree(kmalloc_ptr);
            kmalloc_ptr = NULL;
            pr_err("kmalloc free is successfull\n");
        }
	return 0;
}

static int allocate_vmalloc(unsigned long size) {
	vmalloc_ptr = vmalloc(size);

        if (!vmalloc_ptr) {
            pr_err("vmalloc allocation (%lu) is failed\n", size);
            return -ENOMEM;
        }
        pr_info("vmalloc allocation (%lu) is successful\n", size);

	return 0;
}

static int free_vmalloc(void) {
        if (vmalloc_ptr) {
            vfree(vmalloc_ptr);
            vmalloc_ptr = NULL;
            pr_err("vmalloc free is successfull\n");
        }
	return 0;
}

static long allocate_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
    unsigned long size = arg;
    int ret = 0;

    switch (cmd) {
    case ALLOCATE_CONTINUOUS:
	ret |= free_kmalloc();
	ret |= allocate_kmalloc(size);
        break;

    case ALLOCATE_ANY:
	ret |= free_vmalloc();
        ret |= allocate_vmalloc(size);
        break;

    case FREE_CONTINUOUS:
	ret |= free_kmalloc();
        break;

    case FREE_ANY:
	ret |= free_vmalloc();
        break;

    default:
        return -ENOTTY;
    }

    return ret;
}

static const struct file_operations fops = {
    	.owner = THIS_MODULE,
    	.unlocked_ioctl = allocate_ioctl,
};

static struct miscdevice allocate_miscdev = {
    	.minor = MISC_DYNAMIC_MINOR,
    	.name = "allocate",
    	.fops = &fops,
    	.mode = 0666,
};

static int __init allocate_init(void)
{
    	int ret = misc_register(&allocate_miscdev);
    	if (ret) {
        	pr_err("Allocate device is not registered\n");
        	return ret;
    	}

    	pr_info("Allocate device is registered\n");
    	return 0;
}

static void __exit allocate_exit(void)
{
	free_kmalloc();
	free_vmalloc();
        
    	misc_deregister(&allocate_miscdev);
    	pr_info("Allocate device is deregistered\n");
}

module_init(allocate_init);
module_exit(allocate_exit);

MODULE_LICENSE("GPL");
