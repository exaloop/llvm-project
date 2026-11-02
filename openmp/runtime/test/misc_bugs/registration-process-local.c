// RUN: %libomp-compile -ldl -lrt && %libomp-run
// REQUIRES: linux

#define _GNU_SOURCE
#include <dlfcn.h>
#include <omp.h>
#include <sys/mman.h>
#include <sys/types.h>

static int shared_registrations;

int shm_open(const char *name, int flags, mode_t mode) {
  ++shared_registrations;
  int (*original)(const char *, int, mode_t) = dlsym(RTLD_NEXT, "shm_open");
  return original ? original(name, flags, mode) : -1;
}

int main(void) {
  int threads = 0;
#pragma omp parallel num_threads(2) reduction(+ : threads)
  threads += 1;
  return threads != 2 || shared_registrations != 0;
}
