/**
 * C Library calls that need HAL routines to perform I/O
 *
 * [references]
 * - man 3 read
 * - man 3 write
 * - https://interrupt.memfault.com/blog/boostrapping-libc-with-newlib
 * - https://embeddedartistry.com/blog/2019/page/9/
 * - https://devzone.nordicsemi.com/f/nordic-q-a/3351/nrf51822-with-gcc---stacksize-and-heapsize
 * - https://github.com/picolibc/picolibc/blob/main/doc/os.md
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/stat.h>

#include <nrfx_uarte.h>

char syscalls_string[1024] = { '\0' };
uint8_t syscalls_memory[4096] = { 0 };

static nrfx_uarte_t const *sys_uart = NULL;
static nrfx_uarte_config_t const *sys_uart_config = NULL;

int syscalls_init(nrfx_uarte_t const *uart, nrfx_uarte_config_t const *config)
{
	if (nrfx_uarte_init(uart, config , NULL) != NRFX_SUCCESS)
		return -1;

	sys_uart = uart;
	sys_uart_config = config;

	return 0;
}

void *_sbrk(ptrdiff_t incr)
{
	extern uint32_t __HeapBase;
	extern uint32_t __HeapLimit;
	static unsigned char *heap = NULL;
	unsigned char *prev_heap;

	if (heap == NULL)
		heap = (unsigned char*)&__HeapBase;

	prev_heap = heap;

	if (heap + incr >= (unsigned char*)&__HeapLimit)
		return (void *)-1;
	else
		heap += incr;

	return prev_heap;
}

ssize_t _write(int filedes, void *buf, size_t nbyte)
{
	ssize_t n = 0;

	for (; nbyte != 0; --nbyte) {
		nrfx_uarte_tx(sys_uart, (uint8_t *)buf++, 1, 0);
		++n;
	}

	return n;
}

ssize_t _read(int filedes, void *buf, size_t nbyte)
{
	ssize_t n = 0;

	for (; nbyte > 0; --nbyte) {
		nrfx_uarte_rx(sys_uart, (uint8_t *)buf++, 1);
		n++;
	}

	return n;
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

#if defined(PICOLIBC_STDIO_GLOBALS)

static int uart_putc(char c, FILE *file __attribute__((unused)))
{
	nrfx_uarte_tx(sys_uart, (uint8_t *)&c, 1, 0);
	return c;
}

static int uart_getc(FILE *file __attribute__((unused)))
{
	uint8_t byte = 0;
	nrfx_uarte_tx(sys_uart, &byte, 1, 0);
	return (int)byte;
}

static int uart_flush(FILE *file __attribute__((unused)))
{
	return 0;
}

static FILE __stdio = FDEV_SETUP_STREAM(uart_putc,
					uart_getc,
					uart_flush,
					_FDEV_SETUP_RW);
FILE *const stdin = &__stdio;
__strong_reference(stdin, stdout);
__strong_reference(stdin, stderr);

#else // NOT PICOLIBC_STDIO_GLOBALS

#ifndef stdin
FILE *const stdin = NULL;
#endif
#ifndef stdout
FILE *const stdout = NULL;
#endif
#ifndef stderr
FILE *const stderr = NULL;
#endif

#endif // PICOLIBC_STDIO_GLOBALS
