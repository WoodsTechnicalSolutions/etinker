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
	/**
	 * pulled from Nordic SDK 16.0.0 'components/boards/boards.c'
	 *
	 * If nRF52 USB Dongle is powered from USB (high voltage mode),
	 * GPIO output voltage is set to 1.8 V by default, which is not
	 * enough to turn on green and blue LEDs. Therefore, GPIO voltage
	 * needs to be increased to 3.0 V by configuring the UICR register.
	 */
	if (NRF_POWER->MAINREGSTATUS &
			(POWER_MAINREGSTATUS_MAINREGSTATUS_High << POWER_MAINREGSTATUS_MAINREGSTATUS_Pos)) {
		// setup 3.0V below
	} else {
		goto gpio_config;
	}

	if ((NRF_UICR->REGOUT0 & UICR_REGOUT0_VOUT_Msk) ==
			(UICR_REGOUT0_VOUT_DEFAULT << UICR_REGOUT0_VOUT_Pos)) {

		NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Wen;

		while (NRF_NVMC->READY == NVMC_READY_READY_Busy);

		NRF_UICR->REGOUT0 = (NRF_UICR->REGOUT0 & ~((uint32_t)UICR_REGOUT0_VOUT_Msk)) |
				    (UICR_REGOUT0_VOUT_3V0 << UICR_REGOUT0_VOUT_Pos);

		NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Ren;

		while (NRF_NVMC->READY == NVMC_READY_READY_Busy);

		NVIC_SystemReset();
	}

gpio_config:

	nrf_gpio_cfg_output(LED1_G);
	nrf_gpio_cfg_output(LED2_R);
	nrf_gpio_cfg_output(LED2_G);
	nrf_gpio_cfg_output(LED2_B);

	// default OFF
	nrf_gpio_pin_write(LED1_G, 0);
	nrf_gpio_pin_write(LED2_R, 0);
	nrf_gpio_pin_write(LED2_G, 0);
	nrf_gpio_pin_write(LED2_B, 0);
}

int main(void)
{
	nrfx_systick_init();

	dongle_gpio_init();

	nrf_gpio_pin_write(LED1_G, 1);

	while (true) {
		nrfx_systick_delay_ms(1000);
		nrf_gpio_pin_write(LED2_G, 0);
		nrf_gpio_pin_write(LED2_B, 0);
		nrfx_systick_delay_ms(100);
		nrf_gpio_pin_write(LED2_R, 1);
		nrf_gpio_pin_toggle(LED1_G);

		nrfx_systick_delay_ms(1000);
		nrf_gpio_pin_write(LED2_R, 0);
		nrf_gpio_pin_write(LED2_B, 0);
		nrfx_systick_delay_ms(100);
		nrf_gpio_pin_write(LED2_G, 1);
		nrf_gpio_pin_toggle(LED1_G);

		nrfx_systick_delay_ms(1000);
		nrf_gpio_pin_write(LED2_R, 0);
		nrf_gpio_pin_write(LED2_G, 0);
		nrfx_systick_delay_ms(100);
		nrf_gpio_pin_write(LED2_B, 1);
		nrf_gpio_pin_toggle(LED1_G);
	}
}
