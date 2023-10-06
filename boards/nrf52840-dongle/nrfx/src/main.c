#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

//#ifdef __picolibc_deprecated
/* 'picolibc' is present */
extern unsigned int __data_start;
unsigned int __data_source = (unsigned int)&__data_start;
extern unsigned int __tdata_start;
unsigned int __tls_base = (unsigned int)&__tdata_start;
extern unsigned int __tbss_start;
unsigned int __arm32_tls_tcb_offset = (unsigned int)&__tbss_start;
//#endif

#include "nrfx_gpiote.h"
#include "nrfx_uarte.h"
#include "nrfx_spim.h"
#include "nrfx_twim.h"
#include "nrfx_saadc.h"

#include "boards.h"

#ifndef stdin
FILE *const stdin = NULL;
#endif
#ifndef stdout
FILE *const stdout = NULL;
#endif
#ifndef stderr
FILE *const stderr = NULL;
#endif

extern int syscalls_init(nrfx_uarte_t const *uart,
					nrfx_uarte_config_t const *config);

static nrfx_gpiote_out_config_t led_config = NRFX_GPIOTE_CONFIG_OUT_SIMPLE(true);

static nrfx_gpiote_in_config_t sw_1_config = {
	.sense = NRF_GPIOTE_POLARITY_TOGGLE,
	.pull = NRF_GPIO_PIN_PULLUP,
	.is_watcher = false,
	.hi_accuracy = true,
	.skip_gpio_setup = false,
};

static void gpio_init(void)
{
	nrfx_err_t err;

	/**
	 * pulled from Nordic SDK 16.0.0 'components/boards/boards.c'
	 *
	 * If nRF52 USB Dongle is powered from USB (high voltage mode),
	 * GPIO output voltage is set to 1.8 V by default, which is not
	 * enough to turn on green and blue LEDs. Therefore, GPIO voltage
	 * needs to be increased to 3.3 V by configuring the UICR register.
	 */
	if (NRF_POWER->MAINREGSTATUS &
			(POWER_MAINREGSTATUS_MAINREGSTATUS_High <<
			 POWER_MAINREGSTATUS_MAINREGSTATUS_Pos)) {
		printf("\r\nHigh Voltage Mode detected\r\n");
	} else {
		printf("\r\nVDD == VDDH\r\n");
		goto gpio_config;
	}

	if ((NRF_UICR->REGOUT0 & UICR_REGOUT0_VOUT_Msk) ==
			(UICR_REGOUT0_VOUT_DEFAULT << UICR_REGOUT0_VOUT_Pos)) {

		printf("%s: Adjusting I/O Voltage to 3.3 V\r\n", __func__);

		NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Wen << NVMC_CONFIG_WEN_Pos;

		while (NRF_NVMC->READY == NVMC_READY_READY_Busy);

		NRF_UICR->REGOUT0 = (NRF_UICR->REGOUT0 & ~((uint32_t)UICR_REGOUT0_VOUT_Msk));
		NRF_UICR->REGOUT0 |= (UICR_REGOUT0_VOUT_3V3 << UICR_REGOUT0_VOUT_Pos);

		NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Ren << NVMC_CONFIG_WEN_Pos;

		while (NRF_NVMC->READY == NVMC_READY_READY_Busy);

		NVIC_SystemReset();
	}

gpio_config:

	err = nrfx_gpiote_init(NRFX_GPIOTE_DEFAULT_CONFIG_IRQ_PRIORITY);
	if (err != NRFX_SUCCESS)
		while (true);

	nrfx_gpiote_in_init(SW_1, &sw_1_config, NULL);

	nrfx_gpiote_out_init(LED_1_G, &led_config);
	nrfx_gpiote_out_init(LED_2_R, &led_config);
	nrfx_gpiote_out_init(LED_2_G, &led_config);
	nrfx_gpiote_out_init(LED_2_B, &led_config);
}

static nrfx_uarte_t uarte_0 = NRFX_UARTE_INSTANCE(0);
static nrfx_uarte_config_t uarte_0_config = NRFX_UARTE_DEFAULT_CONFIG(UARTE_0_TX_PIN, UARTE_0_RX_PIN);

#if !defined(USE_SPIM_0)
static nrfx_uarte_t uarte_1 = NRFX_UARTE_INSTANCE(1);
static nrfx_uarte_config_t uarte_1_config = NRFX_UARTE_DEFAULT_CONFIG(UARTE_1_TX_PIN, UARTE_1_RX_PIN);

static nrfx_twim_t twim_0 = NRFX_TWIM_INSTANCE(1);
static nrfx_twim_config_t twim_0_config = NRFX_TWIM_DEFAULT_CONFIG(TWIM_0_SCL_PIN, TWIM_0_SDA_PIN);
#endif // ! USE_SPIM_0

#if defined(USE_SPIM_0)
static nrfx_spim_t spim_0 = NRFX_SPIM_INSTANCE(0);
static nrfx_spim_config_t spim_0_config = {
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
static nrfx_spim_xfer_desc_t spim_0_xfer = { 0 };
static uint8_t data_rx[] = { 0 };
#endif // USE_SPIM_0

static uint8_t tx_id = 0;
static uint8_t data_tx[2][16] = {
	{ // '0123456789abcdef'
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 97, 98, 99, 100, 101, 102
	},
	{ // '0505050505050505'
		48, 53, 48, 53, 48, 53, 48, 53,
		48, 53, 48, 53, 48, 53, 48, 53
	}
};

static nrf_saadc_value_t saadc_value[4] = { 0 };
static uint32_t saadc_mask = 0xf;
static nrfx_saadc_channel_t saadc[] = {
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_0, 0),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_5, 1),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_7, 2),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_VDD, 3),
};

int main(void)
{
	uint8_t i;
	nrfx_err_t err;
#if !defined(USE_SPIM_0)
	uint8_t nl[] = { 13, 10 }; // '\r\n'
#endif // ! USE_SPIM_0

	syscalls_init(&uarte_0, &uarte_0_config);

	printf("\r\nStarting ...\r\n");

	gpio_init();

#if !defined(USE_SPIM_0)
	printf("\r\nUARTE 1 Init ...\r\n");

	err = nrfx_uarte_init(&uarte_1, &uarte_1_config, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_uarte_init\r\n");
		nrfx_gpiote_out_clear(LED_2_G);
		nrfx_gpiote_out_clear(LED_2_B);
		nrfx_gpiote_out_clear(LED_1_G);
		while (true) {
			nrfx_coredep_delay_us(2000000);
			nrfx_gpiote_out_toggle(LED_2_R);
		}
	}
#endif // ! USE_SPIM_0

	printf("\r\nSAADC Init ...\r\n");

	nrfx_saadc_init(NRFX_SAADC_DEFAULT_CONFIG_IRQ_PRIORITY);
	nrfx_saadc_channels_config(saadc, sizeof(saadc) / sizeof(saadc[0]));
	nrfx_saadc_offset_calibrate(NULL);

#if defined(USE_SPIM_0)
	printf("\r\nSPIM 0 Init ...\r\n");

	err = nrfx_spim_init(&spim_0, &spim_0_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_spim_init\r\n");
		nrfx_gpiote_out_clear(LED_2_G);
		nrfx_gpiote_out_clear(LED_2_B);
		nrfx_gpiote_out_clear(LED_1_G);
		while (true) {
			nrfx_coredep_delay_us(1000000);
			nrfx_gpiote_out_toggle(LED_2_R);
		}
	}
#else
	printf("\r\nTWIM 1 Init ...\r\n");

	err = nrfx_twim_init(&twim_0, &twim_0_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_twim_init\r\n");
		nrfx_gpiote_out_clear(LED_2_G);
		nrfx_gpiote_out_clear(LED_2_B);
		nrfx_gpiote_out_clear(LED_1_G);
		while (true) {
			nrfx_coredep_delay_us(3000000);
			nrfx_gpiote_out_toggle(LED_2_R);
		}
	}

	nrfx_twim_enable(&twim_0);
#endif // USE_SPIM_0

	nrfx_gpiote_out_toggle(LED_1_G);

	SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk;

	while (true) {
		printf(" SW1: %s\r\n", nrfx_gpiote_in_is_set(SW_1) ? "up" : "down");

#if !defined(USE_SPIM_0)
		// probe I2C and read PCF8575 16-bit I/O expander if found
		for (i = 0; i < 128; i++) {
			uint8_t data[2] = { 0 };
			nrfx_twim_xfer_desc_t xfer_desc =
					NRFX_TWIM_XFER_DESC_RX(i, &data[0], 2);
			err = nrfx_twim_xfer(&twim_0, &xfer_desc, 0);
			if (err != NRFX_SUCCESS)
				continue;
			while (nrfx_twim_is_busy(&twim_0));
			printf(" I2C: device @ 0x%02x [0x%02x%02x]\r\n",
							i, data[1], data[0]);
		}
#endif // ! USE_SPIM_0

#if defined(USE_SPIM_0)
		// send data on SPIM 0, UARTE 1, and UARTE 0 [console]
		printf(" SPI: ");
#endif // USE_SPIM_0
		tx_id = (tx_id == 0) ? 1 : 0;
		for (i = 0; i < sizeof(data_tx[0]); i++) {
#if defined(USE_SPIM_0)
			spim_0_xfer.p_rx_buffer = data_rx;
			spim_0_xfer.rx_length = 1;
			spim_0_xfer.p_tx_buffer = (uint8_t const *)&data_tx[tx_id][i];
			spim_0_xfer.tx_length = 1;
			nrfx_spim_xfer(&spim_0, &spim_0_xfer, 0);
			// UARTE 0
			printf("%c", data_rx[0]);
			data_rx[0] = 0;
#else
			// UARTE 1
			while (nrfx_uarte_tx_in_progress(&uarte_1))
				nrfx_coredep_delay_us(10);
			nrfx_uarte_tx(&uarte_1, &data_tx[tx_id][i], 1);
#endif // USE_SPIM_0
		}
		printf("\r\n");
#if !defined(USE_SPIM_0)
		while (nrfx_uarte_tx_in_progress(&uarte_1))
			nrfx_coredep_delay_us(10);
		nrfx_uarte_tx(&uarte_1, nl, sizeof(nl));
#endif // ! USE_SPIM_0

		// read SAADC 4 channels [0,5,7,VDD]
		nrfx_saadc_simple_mode_set(saadc_mask,
				NRF_SAADC_RESOLUTION_12BIT,
				NRF_SAADC_OVERSAMPLE_DISABLED, NULL);
		nrfx_saadc_buffer_set(saadc_value,
				sizeof(saadc_value) / sizeof(saadc_value[0]));
		nrfx_saadc_mode_trigger();
		printf(" ADC: [0:0x%03x],[5:0x%03x],[7:0x%03x],[VDD:0x%03x]\r\n",
			saadc_value[0], saadc_value[1],
			saadc_value[2], saadc_value[3]);

		nrfx_coredep_delay_us(1000000);

		nrfx_gpiote_out_clear(LED_2_G);
		nrfx_gpiote_out_clear(LED_2_B);
		nrfx_gpiote_out_set(LED_2_R);

		nrfx_coredep_delay_us(1000000);

		nrfx_gpiote_out_clear(LED_2_R);
		nrfx_gpiote_out_clear(LED_2_B);
		nrfx_gpiote_out_set(LED_2_G);

		nrfx_coredep_delay_us(1000000);

		nrfx_gpiote_out_clear(LED_2_R);
		nrfx_gpiote_out_clear(LED_2_G);
		nrfx_gpiote_out_set(LED_2_B);

		printf("\r\e[2J");
	}

	return 0;
}
