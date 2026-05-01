#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <string.h>

#define N 4

void verify_matmul(uint16_t *matrix_a, uint16_t *matrix_b, uint16_t *matrix_c) {
    for ( int i = 0; i < N; i++ ) {
        for ( int j = 0; j < N; j++ ) {
            uint16_t elem = 0;
            for ( int k = 0; k < N; k++ ) {
                elem += matrix_a[i * N + k] * matrix_b[j * N + k];
            }

            if ( elem != matrix_c[i * N + j] ) {
                printf("Mismatch (ref vs sa): %u != %u (%d, %d)\n", elem, matrix_c[i * N + j], i, j);
            }
        }
    }
}

void print_matrix(uint16_t *matrix, const char *const name) {
    printf("Matrix %s:\n", name);
    for ( int i = 0; i < N; i++ ) {
      for ( int j = 0; j < N; j++ ) {
        printf("%u\t", matrix[i * N + j]);
      }
      printf("\n");
    }
    printf("\n");
    printf("\n");
}

int main(int argc, char *argv[]) {
    uint16_t *matrix_a = NULL;
    uint16_t *matrix_b = NULL;
    uint16_t *matrix_c = NULL;

    /**
     * Allocate matrices.
     */
    matrix_a = malloc(N * N * sizeof(uint16_t));
    matrix_b = malloc(N * N * sizeof(uint16_t));
    matrix_c = malloc(N * N * sizeof(uint16_t));
    if ( !matrix_a || !matrix_b || !matrix_c ) {
        perror("malloc");
        return 1;
    }

    /**
     * Init matrices.
     */
    for ( int i = 0; i < N * N; i++ ) {
        matrix_a[i] = i;
        matrix_b[i] = i;
        matrix_c[i] = 0;
    }
    print_matrix(matrix_a, "A");
    print_matrix(matrix_b, "B");

    uint32_t addrs[3] = {};
    addrs[0] = (uint32_t)(uintptr_t)matrix_a;
    addrs[1] = (uint32_t)(uintptr_t)matrix_b;
    addrs[2] = (uint32_t)(uintptr_t)matrix_c;

    /**
     * Get SA descriptor to communicate with it.
     */
    int fd = open("/dev/sa-dev", O_WRONLY);
    if ( fd < 0 ) {
        perror("open");
        return 1;
    }

    /**
     * Write matrices addresses into SA.
     * Wait until compute is done.
     */
    if ( write(fd, addrs, sizeof(addrs)) < 0 ) {
        perror("write");
        close(fd);
        return 1;
    }
    print_matrix(matrix_c, "C (from SA)");

    verify_matmul(matrix_a, matrix_b, matrix_c);    

    close(fd);
    free(matrix_a);
    free(matrix_b);
    free(matrix_c);

    return 0;
}
