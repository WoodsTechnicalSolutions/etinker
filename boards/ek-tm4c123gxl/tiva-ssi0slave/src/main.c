#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

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

	GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, LED_BLUE);
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

uint32_t data_rx[1] = { 0 };

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

	SSIConfigSetExpClk(SSI0_BASE,
			   SysCtlClockGet(),
			   SSI_FRF_MOTO_MODE_0,
			   SSI_MODE_SLAVE,
			   1000000, 8);

	SSIEnable(SSI0_BASE);

	/* drain residual data on SSI port */
	while(SSIDataGetNonBlocking(SSI0_BASE, &data_rx[0]));
}

#ifdef DEBUG
void
__error__(char *filename, uint32_t line)
{
	UARTprintf("%s:%lu\n", filename, line);
}
#endif

int main(void)
{
	int i = 0;
	int k;
	uint32_t j = 0;
	uint8_t led = LED_BLUE;
	char ascii[16] = { '.' };

	SysCtlClockSet(SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_XTAL_16MHZ |
							SYSCTL_OSC_MAIN);

	led_setup();

	console_setup();

	spi_setup();

	while (true) {

		led = led == 0 ? LED_BLUE : 0;

		GPIOPinWrite(GPIO_PORTF_BASE, LED_BLUE, led);

		// recv byte

		SSIDataGet(SSI0_BASE, &data_rx[0]);

		data_rx[0] &= 0x00ff;

		if (i == 0) {
			UARTprintf("%08x: ", j);
		}

		UARTprintf("%02x", data_rx[0]);

		if (isspace((int)data_rx[0])) {
			ascii[i] = '.';
		} else {
			ascii[i] = (char)data_rx[0];
		}

		// send byte (echo)
		SSIDataPut(SSI0_BASE, data_rx[0]);

		if (++i == 16) {
			UARTprintf(" | ");
			for (k = 0; k < i; k++) {
				UARTprintf("%c", ascii[k]);
			}
			UARTprintf("\n");
			if ((j + 16) > UINT32_MAX) {
				j = 0;
			} else {
				j += i;
			}
			i = 0;
			memset(ascii, '\0', sizeof(ascii));
		} else {
			UARTprintf(" ");
		}
	}

	return 0;
}
