/**
 * C Library calls that need HAL routines to perform I/O
 *
 * [references]
 * - man 3 read
 * - man 3 write
 * - https://interrupt.memfault.com/blog/boostrapping-libc-with-newlib
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>

#include "utils/uartstdio.h"

void *_sbrk(ptrdiff_t incr)
{
	extern uint32_t __heap_start__;
	extern uint32_t __HeapLimit;
	static unsigned char *heap = NULL;
	unsigned char *prev_heap;

	if (heap == NULL)
		heap = (unsigned char*)&__heap_start__;

	prev_heap = heap;

	if (heap + incr >= (unsigned char*)&__HeapLimit)
		return (void *)-1;
	else
		heap += incr;

	return prev_heap;
}

ssize_t _write(int filedes, void *buf, size_t nbyte)
{
	return UARTwrite(buf, nbyte);
}

ssize_t _read(int filedes, void *buf, size_t nbyte)
{
	return UARTgets(buf, nbyte);
}

int _close(int file)
{
	return -1;
}

int _fstat(int file, struct stat *st)
{
	st->st_mode = S_IFCHR;

	return 0;
}

int _isatty(int file)
{
	return 1;
}

int _lseek(int file, int ptr, int dir)
{
	return 0;
}

void _exit(int status)
{
	//__asm("BKPT #0");
	for (;;);
}

void _kill(int pid, int sig)
{
	return;
}

int _getpid(void)
{
	return -1;
}
