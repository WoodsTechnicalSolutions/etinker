#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

#include "nrfx_gpiote.h"
#include "nrfx_spim.h"
#include "nrfx_systick.h"
#include "nrfx_uarte.h"

#include "boards.h"

nrfx_gpiote_out_config_t led_config = NRFX_GPIOTE_CONFIG_OUT_SIMPLE(true);

static void gpio_init(void)
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

	nrfx_gpiote_init(NRFX_GPIOTE_DEFAULT_CONFIG_IRQ_PRIORITY);

	nrfx_gpiote_out_init(LED1_G, &led_config);
	nrfx_gpiote_out_init(LED2_R, &led_config);
	nrfx_gpiote_out_init(LED2_G, &led_config);
	nrfx_gpiote_out_init(LED2_B, &led_config);
}

int main(void)
{
	uint8_t i;
	uint8_t tx;
	nrfx_uarte_t uarte_0 = NRFX_UARTE_INSTANCE(0);
	nrfx_uarte_config_t uarte_0_config = NRFX_UARTE_DEFAULT_CONFIG(
						UARTE_0_TX_PIN, UARTE_0_RX_PIN);
#if defined(USE_TWIM_1)
	// TODO: TWIM instance 1 declarations
#else
	nrfx_uarte_t uarte_1 = NRFX_UARTE_INSTANCE(1);
	nrfx_uarte_config_t uarte_1_config = NRFX_UARTE_DEFAULT_CONFIG(
						UARTE_1_TX_PIN, UARTE_1_RX_PIN);
#endif
	nrfx_spim_t spim_0 = NRFX_SPIM_INSTANCE(0);
	nrfx_spim_config_t spim_0_config = {
		.sck_pin        = SPIM_0_SCLK_PIN,
		.mosi_pin       = SPIM_0_MOSI_PIN,
		.miso_pin       = SPIM_0_MISO_PIN,
		.ss_pin         = SPIM_0_CS_PIN,
		.ss_active_high = false,
		.irq_priority   = NRFX_SPIM_DEFAULT_CONFIG_IRQ_PRIORITY,
		.orc            = 0xFF,
		.frequency      = NRF_SPIM_FREQ_1M,
		.mode           = NRF_SPIM_MODE_0,
		.bit_order      = NRF_SPIM_BIT_ORDER_MSB_FIRST,
		.miso_pull      = NRF_GPIO_PIN_NOPULL,
	};
	nrfx_spim_xfer_desc_t spim_0_xfer = { 0 };
	uint8_t spim_0_tx[] = { 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102 };

	gpio_init();

	nrfx_systick_init();

	nrfx_uarte_init(&uarte_0, &uarte_0_config , NULL);

#if defined(USE_TWIM_1)
	// TODO: TWIM instance 1 initialization
#else
	nrfx_uarte_init(&uarte_1, &uarte_1_config , NULL);
#endif

	nrfx_spim_init(&spim_0, &spim_0_config, NULL, NULL);

	nrfx_gpiote_out_toggle(LED1_G);

	while (true) {

		nrfx_systick_delay_ms(1000);

		nrfx_gpiote_out_set(LED2_R);
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);

		nrfx_systick_delay_ms(1000);

		nrfx_gpiote_out_clear(LED2_R);
		nrfx_gpiote_out_set(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);

		nrfx_systick_delay_ms(1000);

		nrfx_gpiote_out_clear(LED2_R);
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_set(LED2_B);

		for (i = 0; i < sizeof(spim_0_tx); i++) {
			spim_0_xfer.p_rx_buffer = NULL;
			spim_0_xfer.rx_length = 0;
			spim_0_xfer.p_tx_buffer = (uint8_t const *)&spim_0_tx[i];
			spim_0_xfer.tx_length = 1;
			nrfx_spim_xfer(&spim_0, &spim_0_xfer, 0);
			nrfx_uarte_tx(&uarte_0, &spim_0_tx[i], 1);
#if !defined(USE_TWIM_1)
			nrfx_uarte_tx(&uarte_1, &spim_0_tx[i], 1);
#endif
		}
		tx = '\r';
		nrfx_uarte_tx(&uarte_0, &tx, 1);
#if !defined(USE_TWIM_1)
		nrfx_uarte_tx(&uarte_1, &tx, 1);
#endif
		tx = '\n';
		nrfx_uarte_tx(&uarte_0, &tx, 1);
#if !defined(USE_TWIM_1)
		nrfx_uarte_tx(&uarte_1, &tx, 1);
#endif
	}
}
