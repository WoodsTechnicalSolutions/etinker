#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

#include "nrfx_systick.h"
#include "nrfx_gpiote.h"
#include "nrfx_uarte.h"
#include "nrfx_twim.h"
#include "nrfx_saadc.h"
#include "nrfx_qspi.h"
#define QSPI_STD_CMD_WRSR   0x01
#define QSPI_STD_CMD_RSTEN  0x66
#define QSPI_STD_CMD_RST    0x99

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

	nrfx_gpiote_out_init(LED1_G, &led_config);
	nrfx_gpiote_out_init(LED2_R, &led_config);
	nrfx_gpiote_out_init(LED2_G, &led_config);
	nrfx_gpiote_out_init(LED2_B, &led_config);
}

int main(void)
{
	uint8_t i;
	nrfx_err_t err;
	nrfx_uarte_t uarte_0 = NRFX_UARTE_INSTANCE(0);
	nrfx_uarte_config_t uarte_0_config = NRFX_UARTE_DEFAULT_CONFIG(
						UARTE_0_TX_PIN, UARTE_0_RX_PIN);
	nrfx_twim_t twim_1 = NRFX_TWIM_INSTANCE(1);
	nrfx_twim_config_t twim_1_config = NRFX_TWIM_DEFAULT_CONFIG(
						TWIM_1_SCL_PIN, TWIM_1_SDA_PIN);
	uint8_t qspi_data = 0x40;
	nrfx_qspi_config_t qspi = NRFX_QSPI_DEFAULT_CONFIG(
						QSPI_CLK_PIN, QSPI_CS_PIN,
						QSPI_IO_0_PIN, QSPI_IO_1_PIN,
						QSPI_IO_2_PIN, QSPI_IO_3_PIN);
	nrf_qspi_cinstr_conf_t cinstr_cfg =
		NRFX_QSPI_DEFAULT_CINSTR(QSPI_STD_CMD_RSTEN, NRF_QSPI_CINSTR_LEN_1B);

	nrf_saadc_value_t saadc_value[4] = { 0 };
	uint32_t saadc_mask = 0xf;
	nrfx_saadc_channel_t saadc[] = {
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_0, 0),
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_5, 1),
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_7, 2),
		NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_VDD, 3),
	};

	nrfx_systick_init();

	syscalls_init(&uarte_0, &uarte_0_config);

	printf("\r\nStarting ...\r\n");

	gpio_init();

	nrfx_saadc_init(NRFX_SAADC_DEFAULT_CONFIG_IRQ_PRIORITY);
	nrfx_saadc_channels_config(saadc, sizeof(saadc) / sizeof(saadc[0]));
	nrfx_saadc_offset_calibrate(NULL);

	err = nrfx_twim_init(&twim_1, &twim_1_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_twim_init\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(3000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}

	nrfx_twim_enable(&twim_1);

	qspi.phy_if.sck_delay = 1;

	err = nrfx_qspi_init(&qspi, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_qspi_init\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(2000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}

	cinstr_cfg.io2_level = true;
	cinstr_cfg.io3_level = true;
	cinstr_cfg.wipwait = false;
	cinstr_cfg.wren = false;

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

	nrfx_systick_delay_us(35);

	// Switch to qspi mode
	cinstr_cfg.opcode = QSPI_STD_CMD_WRSR;
	cinstr_cfg.length = NRF_QSPI_CINSTR_LEN_2B;
	cinstr_cfg.wren = true;
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

	nrfx_systick_delay_ms(3000);

	nrfx_gpiote_out_toggle(LED1_G);

	while (true) {
		nrfx_systick_delay_ms(1000);

		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_set(LED2_R);

		nrfx_systick_delay_ms(1000);

		nrfx_gpiote_out_clear(LED2_R);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_set(LED2_G);

		nrfx_systick_delay_ms(1000);

		nrfx_gpiote_out_clear(LED2_R);
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_set(LED2_B);

		fprintf(stderr, "\033[2J");

		// read some QSPI data
		fprintf(stderr, "QSPI: ");
		for (i = 0; i < 16; i++) {
			uint8_t data = 0x5a;
			err = nrfx_qspi_read(&data, 1, i);
			if (err != NRFX_SUCCESS)
				fprintf(stderr, "-- ");
			else
				fprintf(stderr, "%02x ", data);
		}
		fprintf(stderr, "\r\n");

		// probe I2C and read PCF8575 16-bit I/O expander if found
		for (i = 0; i < 128; i++) {
			uint8_t data[2] = { 0 };
			nrfx_twim_xfer_desc_t xfer_desc =
					NRFX_TWIM_XFER_DESC_RX(i, &data[0], 2);
			err = nrfx_twim_xfer(&twim_1, &xfer_desc, 0);
			if (err != NRFX_SUCCESS)
				continue;
			while (nrfx_twim_is_busy(&twim_1));
			fprintf(stderr, " I2C: device @ 0x%02x [0x%02x%02x]\r\n",
							i, data[1], data[0]);
		}

		// read SAADC 4 channels [0,5,7,VDD]
		nrfx_saadc_simple_mode_set(saadc_mask,
				NRF_SAADC_RESOLUTION_12BIT,
				NRF_SAADC_OVERSAMPLE_DISABLED, NULL);
		nrfx_saadc_buffer_set(saadc_value,
				sizeof(saadc_value) / sizeof(saadc_value[0]));
		nrfx_saadc_mode_trigger();
		fprintf(stderr,
			" ADC: [0:0x%03x],[5:0x%03x],[7:0x%03x],[VDD:0x%03x]\r\n",
			saadc_value[0], saadc_value[1],
			saadc_value[2], saadc_value[3]);
	}
}
