#include <stdint.h>
#include <stdbool.h>
#include <string.h>

#include "inc/hw_types.h"
#include "inc/hw_gpio.h"
#include "inc/hw_memmap.h"
#include "inc/hw_sysctl.h"
#include "driverlib/gpio.h"
#include "driverlib/rom.h"
#include "driverlib/sysctl.h"
#include "driverlib/pin_map.h"
#include "driverlib/ssi.h"
#include "driverlib/uart.h"
#include "utils/uartstdio.h"

#define LED_RED GPIO_PIN_1
#define LED_BLUE GPIO_PIN_2
#define LED_GREEN GPIO_PIN_3

void led_setup(void)
{
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);

	GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, LED_RED|LED_BLUE|LED_GREEN);
}

void console_setup(void)
{
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);

	GPIOPinConfigure(GPIO_PA0_U0RX);
	GPIOPinConfigure(GPIO_PA1_U0TX);

	GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);

	UARTClockSourceSet(UART0_BASE, UART_CLOCK_PIOSC);

	UARTStdioConfig(0, 115200, 16000000);
}

#if defined(SPI_TEST)
/* SPI test setup is two ek-tm4c123gxl boards connected on SSI0 */
uint32_t data_tx[8] = { 0 };
uint32_t data_rx[8] = { 0 };
bool data_lower = true;

void spi_setup(void)
{
	SysCtlPeripheralEnable(SYSCTL_PERIPH_SSI0);
	SysCtlDelay(5);

	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
	SysCtlDelay(5);

	GPIOPinConfigure(GPIO_PA2_SSI0CLK);
	GPIOPinConfigure(GPIO_PA3_SSI0FSS);
	GPIOPinConfigure(GPIO_PA4_SSI0RX);
	GPIOPinConfigure(GPIO_PA5_SSI0TX);

	GPIOPinTypeSSI(GPIO_PORTA_BASE, GPIO_PIN_5 | GPIO_PIN_4 | GPIO_PIN_3 |
								GPIO_PIN_2);

#if defined(SPI_MASTER)
	SSIConfigSetExpClk(SSI0_BASE,
			   SysCtlClockGet(),
			   SSI_FRF_MOTO_MODE_0,
			   SSI_MODE_MASTER,
			   250000, 8);
#else
	SSIConfigSetExpClk(SSI0_BASE,
			   SysCtlClockGet(),
			   SSI_FRF_MOTO_MODE_0,
			   SSI_MODE_SLAVE,
			   250000, 8);
#endif

	SSIEnable(SSI0_BASE);

	/* drain residual data on SSI port */
	while(SSIDataGetNonBlocking(SSI0_BASE, &data_rx[0]));
}
#endif /* SPI_TEST */

#ifdef DEBUG
void
__error__(char *filename, uint32_t line)
{
	UARTprintf("%s:%lu\n", filename, line);
}
#endif

int main(void)
{
	SysCtlClockSet(SYSCTL_SYSDIV_4|SYSCTL_USE_PLL|SYSCTL_XTAL_16MHZ|SYSCTL_OSC_MAIN);

	led_setup();

	console_setup();

#if defined(SPI_TEST)
	spi_setup();
#endif

	while (true) {

		memset(data_rx, 0, sizeof(data_rx));

		UARTprintf("\033[2K\033[2J\rLED_RGB: RED");

		GPIOPinWrite(GPIO_PORTF_BASE, LED_RED|LED_GREEN|LED_BLUE, LED_RED);

		SysCtlDelay(10000000);

		UARTprintf("\033[2K\033[2J\rLED_RGB: GREEN");

		GPIOPinWrite(GPIO_PORTF_BASE, LED_RED|LED_GREEN|LED_BLUE, LED_GREEN);

		SysCtlDelay(10000000);

		UARTprintf("\033[2K\033[2J\rLED_RGB: BLUE");

		GPIOPinWrite(GPIO_PORTF_BASE, LED_RED|LED_GREEN|LED_BLUE, LED_BLUE);

		SysCtlDelay(10000000);

		UARTprintf("\033[2K\033[2J\rLED_RGB: OFF");

		GPIOPinWrite(GPIO_PORTF_BASE, LED_RED|LED_GREEN|LED_BLUE, 0);

		SysCtlDelay(10000000);

#if defined(SPI_TEST)
		if (data_lower) {
#if defined(SPI_MASTER)
			data_tx[0] = 'M';
			data_tx[1] = 'S';
			data_tx[2] = 'T';
			data_tx[3] = '\n';
			data_lower = false;
		} else {
			data_tx[0] = 'm';
			data_tx[1] = 's';
			data_tx[2] = 't';
			data_tx[3] = '\n';
			data_lower = true;
#else
			data_tx[0] = 'S';
			data_tx[1] = 'L';
			data_tx[2] = 'V';
			data_tx[3] = '\n';
			data_lower = false;
		} else {
			data_tx[0] = 's';
			data_tx[1] = 'l';
			data_tx[2] = 'v';
			data_tx[3] = '\n';
			data_lower = true;
#endif
		}

		UARTprintf("\033[2K\033[2J\rSSI0[send]: %02x %02x %02x %02x %02x %02x %02x %02x",
			   data_tx[0],
			   data_tx[1],
			   data_tx[2],
			   data_tx[3],
			   data_tx[4],
			   data_tx[5],
			   data_tx[6],
			   data_tx[7]);

		SysCtlDelay(10000000);

		for (int i = 0; i < (sizeof(data_tx)/sizeof(data_tx[0])); i++) {
			SSIDataPut(SSI0_BASE, data_tx[i]);
		}

		while (SSIBusy(SSI0_BASE));

		for (int i = 0; i < (sizeof(data_rx)/sizeof(data_rx[0])); i++) {
			SSIDataGet(SSI0_BASE, &data_rx[i]);
			/* 8-bit data mask */
			data_rx[i] &= 0x00ff;
			UARTprintf("\033[2K\033[2J\rSSI0[recv]: %d %02x", i, data_rx[i]);
			SysCtlDelay(10000000);
		}

		SysCtlDelay(10000000);

		UARTprintf("\033[2K\033[2J\rSSI0[recv]: %02x %02x %02x %02x %02x %02x %02x %02x",
			   data_rx[0],
			   data_rx[1],
			   data_rx[2],
			   data_rx[3],
			   data_rx[4],
			   data_rx[5],
			   data_rx[6],
			   data_rx[7]);

		SysCtlDelay(20000000);

#endif /* SPI_TEST */
	}

	return 0;
}
