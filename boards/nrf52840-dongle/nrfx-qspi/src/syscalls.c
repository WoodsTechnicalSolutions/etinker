/**
 * C Library calls that need HAL routines to perform I/O
 *
 * [references]
 * - man 3 read
 * - man 3 write
 * - https://interrupt.memfault.com/blog/boostrapping-libc-with-newlib
 * - https://embeddedartistry.com/blog/2019/page/9/
 * - https://devzone.nordicsemi.com/f/nordic-q-a/3351/nrf51822-with-gcc---stacksize-and-heapsize
 */

#include <stdio.h>
#include <stdlib.h>

#include "nrfx_uarte.h"

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
		nrfx_uarte_tx(sys_uart, (uint8_t *)buf++, 1);
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
