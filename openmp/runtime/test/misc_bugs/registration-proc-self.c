// RUN: %libomp-compile -ldl -lrt && %libomp-run
// REQUIRES: linux

#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

static char numeric_maps[64];
static int self_maps_checks;
static unsigned long stale_flag;

FILE *fopen(const char *name, const char *mode) {
  if (strcmp(name, numeric_maps) == 0) {
    errno = ENOENT;
    return NULL;
  }
  if (strcmp(name, "/proc/self/maps") == 0)
    ++self_maps_checks;
  FILE *(*original)(const char *, const char *) = dlsym(RTLD_NEXT, "fopen");
  if (!original)
    abort();
  return original(name, mode);
}

__attribute__((noinline)) static int parallel_region(void) {
  int threads = 0;
#pragma omp parallel num_threads(2) reduction(+ : threads)
  threads += 1;
  return threads;
}

int main(void) {
  char name[128], shared_name[128], registration[128];
  snprintf(numeric_maps, sizeof(numeric_maps), "/proc/%d/maps", (int)getpid());
  snprintf(name, sizeof(name), "__KMP_REGISTERED_LIB_%d_%d", (int)getpid(),
           (int)getuid());
  snprintf(shared_name, sizeof(shared_name), "/%s", name);
  snprintf(registration, sizeof(registration), "%p-1-stale-libomp",
           (void *)&stale_flag);
  int shared = shm_open(shared_name, O_CREAT | O_EXCL | O_RDWR, 0600);
  if (shared < 0)
    return 1;
  if (ftruncate(shared, sizeof(registration)) != 0 ||
      write(shared, registration, strlen(registration) + 1) !=
          (ssize_t)strlen(registration) + 1) {
    close(shared);
    shm_unlink(shared_name);
    return 2;
  }
  close(shared);
  if (setenv(name, registration, 1) != 0)
    return 3;
  snprintf(name, sizeof(name), "__KMP_REGISTERED_LIB_%d", (int)getpid());
  if (setenv(name, registration, 1) != 0)
    return 3;

  int threads = parallel_region();
  shm_unlink(shared_name);
  return threads != 2 || self_maps_checks == 0;
}
