#ifndef CMDS_H
#define CMDS_H

#define ALLOCATE_CONTINUOUS _IOW('M', 1, unsigned)
#define ALLOCATE_ANY _IOW('M', 2, unsigned)

#define FREE_CONTINUOUS _IO('M', 3)
#define FREE_ANY _IO('M', 4)

#endif
