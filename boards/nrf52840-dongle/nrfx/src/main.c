#include <stdio.h>
#include <stdbool.h>
#include <stddef.h>
#include <ctype.h>

#include "nrf.h"
#include "nrf_gpio.h"
#include "nrfx_systick.h"

#include "boards.h"

static void dongle_gpio_init(void)
{
	nrf_gpio_cfg_output(LED1_G);
	nrf_gpio_cfg_output(LED2_R);
	nrf_gpio_cfg_output(LED2_G);
	nrf_gpio_cfg_output(LED2_B);
}

int main(void)
{
	nrfx_systick_init();

	dongle_gpio_init();

	nrf_gpio_pin_set(LED1_G);

	while (true) {
		nrfx_systick_delay_ms(1000);
		nrf_gpio_pin_set(LED2_R);
		nrf_gpio_pin_clear(LED2_G);
		nrf_gpio_pin_clear(LED2_B);
		nrf_gpio_pin_toggle(LED1_G);

		nrfx_systick_delay_ms(1000);
		nrf_gpio_pin_clear(LED2_R);
		nrf_gpio_pin_set(LED2_G);
		nrf_gpio_pin_clear(LED2_B);
		nrf_gpio_pin_toggle(LED1_G);

		nrfx_systick_delay_ms(1000);
		nrf_gpio_pin_clear(LED2_R);
		nrf_gpio_pin_clear(LED2_G);
		nrf_gpio_pin_set(LED2_B);
		nrf_gpio_pin_toggle(LED1_G);
	}
}
