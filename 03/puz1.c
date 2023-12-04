#include <err.h>
#include <fcntl.h>
#include <limits.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/stat.h>

#define BLOCKSIZE 4096

struct stat statbuf;
int32_t columns;
int32_t rows;
char *inbuf;
char *mask;

void find_dims();
char *get_line(char *, int32_t);
long find_sum();
bool is_symbol(char);
bool is_digit(char);
void set_mask_neighborhood(int32_t,int32_t);
void print_masked();

int main (int argc, char **argv) {
  if (argc < 2) {
    return EX_USAGE;
  }
  int fd = open(argv[1], O_RDONLY);
  if (-1 == fd) err(EX_IOERR, "open(%s)", argv[1]);
  if (-1 == fstat(fd, &statbuf))
    err(EX_IOERR, "stat(%s)", argv[1]);
  /* void *mmap(void addr[.length], size_t length, int prot, int flags,
   *                              int fd, off_t offset);
   */
  inbuf = mmap(NULL, statbuf.st_size, PROT_READ, MAP_SHARED, fd, 0);
  if (MAP_FAILED == inbuf) err(EX_IOERR, "mmap(%s)", argv[1]);
  find_dims();
  mask = calloc(statbuf.st_size,1);
  if (NULL == mask) err(EX_OSERR, "calloc");
  for (int32_t i = 0; i < rows; i++) {
    char *line = get_line(inbuf, i);
    for (int32_t j = 0; j < columns; j++) {
      if (is_symbol(line[j]))
        set_mask_neighborhood(i,j);
    }
  }
  //print_masked();
  printf("%ld\n", find_sum());
}

void find_dims() {
  for (columns = 0; columns < statbuf.st_size; columns++) {
    if ('\n' == inbuf[columns]) {
      rows = statbuf.st_size / (1+columns);
      return;
    }
  }
}

char *get_line(char *buf, int32_t n) {
  return buf + ((1+columns) * n);
}

long find_sum() {
  int32_t i,j,lo;
  long sum = 0;

  for (i = 0; i < rows; i++) {
    char *line = get_line(inbuf, i);
    char *maskline = get_line(mask, i);
    for (j = 0; j < columns; j++) {
      char c = line[j] & maskline[j];
      //fprintf(stderr, "input[%d,%d] & mask[%d,%d] = '%c' & %02x = %02x\n",i,j,i,j,line[j],maskline[j],c);
      if (is_digit(c)) {
        //fprintf(stderr, "digit[%d,%d](%c)\n", i, j,c);
        for (lo = j; lo >= 0; lo--) {
          //fprintf(stderr, "line[%d] -->\n", lo);
          if (! is_digit(line[lo]))
            break;
        }
        lo++;
        for (; j < columns; j++) {
          //fprintf(stderr, "line[%d] --> line[%d]\n", lo, j);
          if (! is_digit(line[j]))
            break;
        }
        j--;
        // TODO: use endptr
        long x = strtol(&line[lo], NULL, 10);
        if (LONG_MIN == x || LONG_MAX == x) err(EX_SOFTWARE, "strtol");
        //fprintf(stderr, "sum += %d\n", x);
        sum += x;
      }
    }
  }
  return sum;
}

bool is_digit(char c) {
  return '0' <= c && c <= '9';
}

bool is_symbol(char c) {
  return !('.' == c || is_digit(c));
}

int32_t min(int32_t a, int32_t b) {
  if (a<b) return a;
  return b;
}

int32_t max(int32_t a, int32_t b) {
  if (a>b) return a;
  return b;
}

void set_mask_neighborhood(int32_t y, int32_t x) {
  for (int32_t i = max(0, y-1); i <= min(rows-1, y+1); i++) {
    char *line = get_line(mask, i);
    for (int32_t j = max(0, x-1); j <= min(columns-1, x+1); j++) {
      line[j] = 0xFF;
      //fprintf(stderr, "set mask [%d,%d]\n", i, j);
    }
  }
}

void print_masked() {
  for (int32_t i = 0; i < rows; i++) {
    char *line = get_line(inbuf, i);
    char *maskline = get_line(mask, i);
    for (int32_t j = 0; j < columns; j++) {
      char c = line[j] & maskline[j];
      if (c)
        printf("%c", c);
      else
        printf(" ");
    }
    printf("\n");
  }
}
