#include <stdint.h>
#include <stdbool.h>

#include "inc/hw_types.h"
#include "inc/hw_gpio.h"
#include "inc/hw_memmap.h"
#include "inc/hw_sysctl.h"
#include "driverlib/gpio.h"
#include "driverlib/rom.h"
#include "driverlib/sysctl.h"
#include "driverlib/pin_map.h"
#include "driverlib/uart.h"
#include "utils/uartstdio.h"

#define LED_D1 GPIO_PIN_1
#define LED_D2 GPIO_PIN_0
#define LED_D3 GPIO_PIN_4
#define LED_D4 GPIO_PIN_0

void led_setup(void)
{
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPION);

	GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, LED_D3|LED_D4);
	GPIOPinTypeGPIOOutput(GPIO_PORTN_BASE, LED_D1|LED_D2);
}

void console_setup(void)
{
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);

	GPIOPinConfigure(GPIO_PA0_U0RX);
	GPIOPinConfigure(GPIO_PA1_U0TX);

	GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0|GPIO_PIN_1);

	UARTClockSourceSet(UART0_BASE, UART_CLOCK_PIOSC);

	UARTStdioConfig(0, 115200, 16000000);
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
	SysCtlClockSet(SYSCTL_SYSDIV_4|SYSCTL_USE_PLL|SYSCTL_XTAL_16MHZ|SYSCTL_OSC_MAIN);

	led_setup();

	console_setup();

	while (true) {
		UARTprintf("\033[2K\033[2J\rON: LED_D1 + LED_D3");

		GPIOPinWrite(GPIO_PORTN_BASE, LED_D1|LED_D2, LED_D1|~LED_D2);
		GPIOPinWrite(GPIO_PORTF_BASE, LED_D3|LED_D4, LED_D3|~LED_D4);

		SysCtlDelay(20000000);

		UARTprintf("\033[2K\033[2J\rON: LED_D2 + LED_D4");

		GPIOPinWrite(GPIO_PORTN_BASE, LED_D1|LED_D2, ~LED_D1|LED_D2);
		GPIOPinWrite(GPIO_PORTF_BASE, LED_D3|LED_D4, ~LED_D3|LED_D4);

		SysCtlDelay(20000000);
	}

	return 0;
}
