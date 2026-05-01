#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <limits.h>
#include "cmds.h"

int try_allocate(int fd, bool is_kmalloc, unsigned long size) {
    int cmd = is_kmalloc ? ALLOCATE_CONTINUOUS : ALLOCATE_ANY;
    return ioctl(fd, cmd, size);
}

unsigned long find_max_size(int fd, int is_kmalloc) {
    unsigned long low = 0;
    unsigned long high = 1;
    
    while (!try_allocate(fd, is_kmalloc, high)) {
        low = high;
        high *= 2;
    }
    
    return low;
}

int main() {
    int fd = open("/dev/allocate", O_RDWR);
    if (fd < 0) {
        perror("Cannot open device");
        return 1;
    }

    printf("Testing kmalloc...\n");
    unsigned long max_kmalloc = find_max_size(fd, true);
    printf("Max kmalloc size: %lu MB\n", max_kmalloc / (1024 * 1024));
    ioctl(fd, FREE_CONTINUOUS);

    printf("\nTesting vmalloc...\n");
    unsigned long max_vmalloc = find_max_size(fd, false);
    printf("Max vmalloc size: %lu bytes (%lu MB)\n", max_vmalloc / (1024 * 1024));
    ioctl(fd, FREE_ANY);

    close(fd);
    return 0;
}
