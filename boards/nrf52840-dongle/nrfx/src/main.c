#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"

#include "nrfx_systick.h"
#include "nrfx_gpiote.h"
#include "nrfx_uarte.h"
#include "nrfx_spim.h"
#include "nrfx_twim.h"
#include "nrfx_saadc.h"

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

static uint8_t i;
static nrfx_err_t err;
static nrfx_uarte_t uarte_0 = NRFX_UARTE_INSTANCE(0);
static nrfx_uarte_config_t uarte_0_config = NRFX_UARTE_DEFAULT_CONFIG(UARTE_0_TX_PIN, UARTE_0_RX_PIN);
static nrfx_twim_t twim_1 = NRFX_TWIM_INSTANCE(1);
static nrfx_twim_config_t twim_1_config = NRFX_TWIM_DEFAULT_CONFIG(TWIM_1_SCL_PIN, TWIM_1_SDA_PIN);
static nrfx_uarte_t uarte_1 = NRFX_UARTE_INSTANCE(1);
static nrfx_uarte_config_t uarte_1_config = NRFX_UARTE_DEFAULT_CONFIG(
						UARTE_1_TX_PIN, UARTE_1_RX_PIN);
static uint8_t nl[] = { 13, 10 }; // '\r\n'
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
static uint8_t spim_0_tx[] = { // '0123456789abcdef'
	48, 49, 50, 51, 52, 53, 54, 55,
	56, 57, 97, 98, 99, 100, 101, 102
};
static nrf_saadc_value_t saadc_value[4] = { 0 };
static uint32_t saadc_mask = 0xf;
static nrfx_saadc_channel_t saadc[] = {
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_0, 0),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_5, 1),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_7, 2),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_VDD, 3),
};

static uint32_t count = 0;

static TaskHandle_t count_task;

static void count_task_function (void *pvParameter)
{
	while (true) {
		vTaskDelay(1 / portTICK_PERIOD_MS);
		if (++count == UINT32_MAX)
			count = 0;
	}
}

static TaskHandle_t main_task;

static void main_task_function (void *pvParameter)
{
	while (true) {
		printf("  MS: %lu\r\n", count);

		// probe I2C and read PCF8575 16-bit I/O expander if found
		for (i = 0; i < 128; i++) {
			uint8_t data[2] = { 0 };
			nrfx_twim_xfer_desc_t xfer_desc =
					NRFX_TWIM_XFER_DESC_RX(i, &data[0], 2);
			err = nrfx_twim_xfer(&twim_1, &xfer_desc, 0);
			if (err != NRFX_SUCCESS)
				continue;
			while (nrfx_twim_is_busy(&twim_1));
			printf(" I2C: device @ 0x%02x [0x%02x%02x]\r\n",
							i, data[1], data[0]);
		}

		// send data on SPIM 0, UARTE 1, and UARTE 0 [console]
		printf(" SPI: ");
		for (i = 0; i < sizeof(spim_0_tx); i++) {
			spim_0_xfer.p_rx_buffer = NULL;
			spim_0_xfer.rx_length = 0;
			spim_0_xfer.p_tx_buffer = (uint8_t const *)&spim_0_tx[i];
			spim_0_xfer.tx_length = 1;
			nrfx_spim_xfer(&spim_0, &spim_0_xfer, 0);
			// UARTE 0
			printf("%c", spim_0_tx[i]);
			// UARTE 1
			nrfx_uarte_tx(&uarte_1, &spim_0_tx[i], 1);
		}
		printf("\r\n");
		nrfx_uarte_tx(&uarte_1, nl, sizeof(nl));

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

		vTaskDelay(1000 / portTICK_PERIOD_MS);

		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_set(LED2_R);

		vTaskDelay(1000 / portTICK_PERIOD_MS);

		nrfx_gpiote_out_clear(LED2_R);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_set(LED2_G);

		vTaskDelay(1000 / portTICK_PERIOD_MS);

		nrfx_gpiote_out_clear(LED2_R);
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_set(LED2_B);

		printf("\r\e[2J");
	}
}

int main(void)
{
	BaseType_t rc;

	nrfx_systick_init();

	syscalls_init(&uarte_0, &uarte_0_config);

	printf("\r\nStarting ...\r\n");

	gpio_init();

	printf("\r\nSAADC Init ...\r\n");

	nrfx_saadc_init(NRFX_SAADC_DEFAULT_CONFIG_IRQ_PRIORITY);
	nrfx_saadc_channels_config(saadc, sizeof(saadc) / sizeof(saadc[0]));
	nrfx_saadc_offset_calibrate(NULL);

	printf("\r\nTWIM 1 Init ...\r\n");

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

	printf("\r\nUARTE 1 Init ...\r\n");

	err = nrfx_uarte_init(&uarte_1, &uarte_1_config, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_uarte_init\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(2000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}

	printf("\r\nSPIM 0 Init ...\r\n");

	err = nrfx_spim_init(&spim_0, &spim_0_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_spim_init\r\n");
		nrfx_gpiote_out_clear(LED2_G);
		nrfx_gpiote_out_clear(LED2_B);
		nrfx_gpiote_out_clear(LED1_G);
		while (true) {
			nrfx_systick_delay_ms(1000);
			nrfx_gpiote_out_toggle(LED2_R);
		}
	}

	nrfx_gpiote_out_toggle(LED1_G);

	printf("\r\nCreating main_task ... ");

	rc = xTaskCreate(main_task_function, "main_task", configMINIMAL_STACK_SIZE + 200, NULL, 2, &main_task);
	if (rc != pdPASS) {
		printf("error xTaskCreate (%lu)\r\n", rc);
		while (true);
	}
	printf("Done (%lu)\r\n", rc);

	printf("\r\nCreating count_task ... ");

	rc = xTaskCreate(count_task_function, "count_task", configMINIMAL_STACK_SIZE + 200, NULL, 2, &count_task);
	if (rc != pdPASS) {
		printf("error xTaskCreate (%lu)\r\n", rc);
		while (true);
	}
	printf("Done (%lu)\r\n", rc);

	SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk;

	printf("\r\nStarting FreeRTOS Scheduler ...\r\n");

	vTaskStartScheduler();

	printf("Oops!\r\n");

	while (true);

	return 0;
}
