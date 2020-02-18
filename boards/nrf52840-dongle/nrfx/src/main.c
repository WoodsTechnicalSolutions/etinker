#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

#include "nrfx_systick.h"
#include "nrfx_gpiote.h"
#include "nrfx_uarte.h"
#if defined(USE_SPIM_0)
#include "nrfx_spim.h"
#endif
#if defined(USE_TWIM_1)
#include "nrfx_twim.h"
#endif
#if defined(USE_SAADC)
#include "nrfx_saadc.h"
#endif
#if defined(USE_QSPI)
#include "nrfx_qspi.h"
#define QSPI_STD_CMD_WRSR   0x01
#define QSPI_STD_CMD_RSTEN  0x66
#define QSPI_STD_CMD_RST    0x99
#endif

#include "boards.h"

extern int syscalls_init(nrfx_uarte_t const *uart,
					nrfx_uarte_config_t const *config);

nrfx_gpiote_out_config_t led_config = NRFX_GPIOTE_CONFIG_OUT_SIMPLE(true);

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
		printf("%s: High Voltage Mode detected\r\n", __func__);
	} else {
		printf("%s: VDD == VDDH\r\n", __func__);
		goto gpio_config;
	}

	if ((NRF_UICR->REGOUT0 & UICR_REGOUT0_VOUT_Msk) ==
			(UICR_REGOUT0_VOUT_DEFAULT << UICR_REGOUT0_VOUT_Pos)) {

		printf("%s: Adjusting I/O Voltage to 3.3 V\r\n", __func__);

		NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Wen;

		while (NRF_NVMC->READY == NVMC_READY_READY_Busy);

		NRF_UICR->REGOUT0 = (NRF_UICR->REGOUT0 & ~((uint32_t)UICR_REGOUT0_VOUT_Msk));
		NRF_UICR->REGOUT0 |= (UICR_REGOUT0_VOUT_3V3 << UICR_REGOUT0_VOUT_Pos);

		NRF_NVMC->CONFIG = NVMC_CONFIG_WEN_Ren;

		while (NRF_NVMC->READY == NVMC_READY_READY_Busy);

		NVIC_SystemReset();
	}

gpio_config:

	err = nrfx_gpiote_init(NRFX_GPIOTE_DEFAULT_CONFIG_IRQ_PRIORITY);
	if (err != NRFX_SUCCESS)
		while (true);

	nrfx_gpiote_out_init(LED1_G, &led_config);
	nrfx_gpiote_out_init(LED2_R, &led_config);
	nrfx_gpiote_out_init(LED2_G, &led_config);
	nrfx_gpiote_out_init(LED2_B, &led_config);
}

int main(void)
{
	nrfx_err_t err;
	nrfx_uarte_t uarte_0 = NRFX_UARTE_INSTANCE(0);
	nrfx_uarte_config_t uarte_0_config = NRFX_UARTE_DEFAULT_CONFIG(
						UARTE_0_TX_PIN, UARTE_0_RX_PIN);
#if !defined(USE_QSPI)
#if defined(USE_SPIM_0) || defined(USE_TWIM_1)
	uint8_t i;
#endif
#if defined(USE_TWIM_1)
	nrfx_twim_t twim_1 = NRFX_TWIM_INSTANCE(1);
	nrfx_twim_config_t twim_1_config = NRFX_TWIM_DEFAULT_CONFIG(
						TWIM_1_SCL_PIN, TWIM_1_SDA_PIN);
#else
	nrfx_uarte_t uarte_1 = NRFX_UARTE_INSTANCE(1);
	nrfx_uarte_config_t uarte_1_config = NRFX_UARTE_DEFAULT_CONFIG(
						UARTE_1_TX_PIN, UARTE_1_RX_PIN);
#endif
#if defined(USE_SPIM_0)
	uint8_t tx[] = { 13, 10 }; // '\r\n'
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
	uint8_t spim_0_tx[] = { // '0123456789abcdef'
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 97, 98, 99, 100, 101, 102
	};
#endif
#endif // !USE_QSPI
#if defined(USE_SAADC)
	nrf_saadc_value_t saadc_value[4] = { 0 };
	uint32_t saadc_mask = 0xf;
	nrfx_saadc_channel_t saadc[] = {
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_0, 0),
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_5, 1),
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_7, 2),
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_VDD, 3),
	};

	nrfx_saadc_init(NRFX_SAADC_DEFAULT_CONFIG_IRQ_PRIORITY);
	nrfx_saadc_channels_config(saadc, sizeof(saadc) / sizeof(saadc[0]));
	nrfx_saadc_offset_calibrate(NULL);
#endif
#if defined(USE_QSPI)
	uint8_t qspi_data = 0x40;
	nrfx_qspi_config_t qspi = NRFX_QSPI_DEFAULT_CONFIG(
						QSPI_SCLK_PIN, QSPI_CS_PIN,
						QSPI_IO_0_PIN, QSPI_IO_1_PIN,
						QSPI_IO_2_PIN, QSPI_IO_3_PIN);
	nrf_qspi_cinstr_conf_t cinstr_cfg =
		NRFX_QSPI_DEFAULT_CINSTR(QSPI_STD_CMD_RSTEN, NRF_QSPI_CINSTR_LEN_1B);
#endif

	nrfx_systick_init();

	syscalls_init(&uarte_0, &uarte_0_config);

	printf("\r\nStarting ...\r\n");

	gpio_init();

#if defined(USE_QSPI)
	err = nrfx_qspi_init(&qspi, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error QSPI init\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(3000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}
	// Send reset enable
	err = nrfx_qspi_cinstr_xfer(&cinstr_cfg, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error QSPI enable\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(1000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}
	// Send reset command
	cinstr_cfg.opcode = QSPI_STD_CMD_RST;
	err = nrfx_qspi_cinstr_xfer(&cinstr_cfg, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error QSPI reset\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(500);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}
	// Switch to qspi mode
	cinstr_cfg.opcode = QSPI_STD_CMD_WRSR;
	cinstr_cfg.length = NRF_QSPI_CINSTR_LEN_2B;
	err = nrfx_qspi_cinstr_xfer(&cinstr_cfg, &qspi_data, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error QSPI mode set\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(100);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}
	for (uint8_t o = 0; o < 16; o++) {
		uint8_t data;
		nrfx_qspi_read(&data, 1, o);
		printf("%02x ", data);
	}
	printf("\r\n");
#else // !USE_QSPI
#if defined(USE_TWIM_1)
	err = nrfx_twim_init(&twim_1, &twim_1_config, NULL, NULL);
#else
	err = nrfx_uarte_init(&uarte_1, &uarte_1_config, NULL);
#endif
	if (err != NRFX_SUCCESS) {
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(3000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}
#if defined(USE_TWIM_1)
	nrfx_twim_enable(&twim_1);
#endif

#if defined(USE_SPIM_0)
	err = nrfx_spim_init(&spim_0, &spim_0_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(2000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}
#endif
#endif // USE_QSPI

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

#if !defined(USE_QSPI)
#if defined(USE_TWIM_1)
		for (i = 0; i < 128; i++) {
			uint8_t data = 0;
			nrfx_twim_xfer_desc_t xfer_desc = NRFX_TWIM_XFER_DESC_RX(i, &data, 1);
			err = nrfx_twim_xfer(&twim_1, &xfer_desc, 0);
			if (err != NRFX_SUCCESS)
				continue;
			while (nrfx_twim_is_busy(&twim_1));
			if (data)
				fprintf(stderr, "\rI2C device @ 0x%02x [0x%02x]", i, data);
		}
#endif

#if defined(USE_SPIM_0)
		for (i = 0; i < sizeof(spim_0_tx); i++) {
			spim_0_xfer.p_rx_buffer = NULL;
			spim_0_xfer.rx_length = 0;
			spim_0_xfer.p_tx_buffer = (uint8_t const *)&spim_0_tx[i];
			spim_0_xfer.tx_length = 1;
			nrfx_spim_xfer(&spim_0, &spim_0_xfer, 0);
			putchar(spim_0_tx[i]);
#if !defined(USE_TWIM_1)
			nrfx_uarte_tx(&uarte_1, &spim_0_tx[i], 1);
#endif
		}
#if !defined(USE_TWIM_1)
		nrfx_uarte_tx(&uarte_1, tx, sizeof(tx));
#endif
#endif
#if defined(USE_SAADC)
		nrfx_saadc_simple_mode_set(saadc_mask, NRF_SAADC_RESOLUTION_12BIT,
				NRF_SAADC_OVERSAMPLE_DISABLED, NULL);
		nrfx_saadc_buffer_set(saadc_value,
				sizeof(saadc_value) / sizeof(saadc_value[0]));
		nrfx_saadc_mode_trigger();
		fprintf(stderr, "\r0x%02x,0x%02x,0x%02x,0x%02x",
			saadc_value[0], saadc_value[1], saadc_value[2], saadc_value[3]);
#endif
#endif // !USE_QSPI
	}
}
