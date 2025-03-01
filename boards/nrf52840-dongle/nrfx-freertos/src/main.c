#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stddef.h>
#include <ctype.h>

extern unsigned int __data_start;
unsigned int __data_source = (unsigned int)&__data_start;
extern unsigned int __tdata_start;
unsigned int __tls_base = (unsigned int)&__tdata_start;
extern unsigned int __tbss_start;
unsigned int __arm32_tls_tcb_offset = (unsigned int)&__tbss_start;

#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"

#include <nrfx_uarte.h>
#include <nrfx_spim.h>
#include <nrfx_twim.h>
#include <nrfx_saadc.h>
#include <nrfx_gpiote.h>
#include <helpers/nrfx_gppi.h>

#include "boards.h"

extern int syscalls_init(nrfx_uarte_t const *uart,
					nrfx_uarte_config_t const *config);

static void sw_1_handler(nrfx_gpiote_pin_t pin,
			   nrfx_gpiote_trigger_t trigger,
			   void *context)
{
	printf("%s: \r\n", __func__);
}

static const nrfx_gpiote_t gpiote = NRFX_GPIOTE_INSTANCE(0);
static uint8_t sw_1_ch;
static uint8_t led_1_g_ch;
static uint8_t led_2_r_ch;
static uint8_t led_2_g_ch;
static uint8_t led_2_b_ch;
static uint8_t ppi_ch;

static void gpio_init(void)
{
	nrfx_err_t err;
	// SW1 button
	static const nrf_gpio_pin_pull_t sw_1_pull_config = NRF_GPIO_PIN_PULLUP;
	nrfx_gpiote_trigger_config_t sw_1_trigger_config = {
		.trigger = NRFX_GPIOTE_TRIGGER_HITOLO,
		.p_in_channel = &sw_1_ch,
	};
	static const nrfx_gpiote_handler_config_t sw_1_handler_config = {
		.handler = sw_1_handler,
	};
	nrfx_gpiote_input_pin_config_t sw_1_in_config = {
		.p_pull_config = &sw_1_pull_config,
		.p_trigger_config = &sw_1_trigger_config,
		.p_handler_config = &sw_1_handler_config
	};
	// LED 1 Green
	static const nrfx_gpiote_output_config_t led_1_g_out_config = {
		.drive = NRF_GPIO_PIN_S0S1,
		.input_connect = NRF_GPIO_PIN_INPUT_DISCONNECT,
		.pull = NRF_GPIO_PIN_NOPULL,
	};
	const nrfx_gpiote_task_config_t led_1_g_task_config = {
		.task_ch = led_1_g_ch,
		.polarity = NRF_GPIOTE_POLARITY_TOGGLE,
		.init_val = 1,
	};
	// LED 2 Red
	static const nrfx_gpiote_output_config_t led_2_r_out_config = {
		.drive = NRF_GPIO_PIN_S0S1,
		.input_connect = NRF_GPIO_PIN_INPUT_DISCONNECT,
		.pull = NRF_GPIO_PIN_NOPULL,
	};
	const nrfx_gpiote_task_config_t led_2_r_task_config = {
		.task_ch = led_2_r_ch,
		.polarity = NRF_GPIOTE_POLARITY_TOGGLE,
		.init_val = 1,
	};
	// LED 2 Green
	static const nrfx_gpiote_output_config_t led_2_b_out_config = {
		.drive = NRF_GPIO_PIN_S0S1,
		.input_connect = NRF_GPIO_PIN_INPUT_DISCONNECT,
		.pull = NRF_GPIO_PIN_NOPULL,
	};
	const nrfx_gpiote_task_config_t led_2_b_task_config = {
		.task_ch = led_2_b_ch,
		.polarity = NRF_GPIOTE_POLARITY_TOGGLE,
		.init_val = 1,
	};
	// LED 2 Blue
	static const nrfx_gpiote_output_config_t led_2_g_out_config = {
		.drive = NRF_GPIO_PIN_S0S1,
		.input_connect = NRF_GPIO_PIN_INPUT_DISCONNECT,
		.pull = NRF_GPIO_PIN_NOPULL,
	};
	const nrfx_gpiote_task_config_t led_2_g_task_config = {
		.task_ch = led_2_g_ch,
		.polarity = NRF_GPIOTE_POLARITY_TOGGLE,
		.init_val = 1,
	};

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

	err = nrfx_gpiote_init(&gpiote, 0);
	if (err != NRFX_SUCCESS) {
		printf("%s: error (%u)\r\n", __func__, err);
		return;
	}

	// SW 1
	err = nrfx_gpiote_channel_alloc(&gpiote, &sw_1_ch);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_channel_alloc: sw_1: error (%u)\r\n", err);
		return;
	}

	err = nrfx_gpiote_input_configure(&gpiote, SW_1, &sw_1_in_config);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_input_configure: sw_1: error (%u)\r\n", err);
		return;
	}

	nrfx_gpiote_trigger_enable(&gpiote, SW_1, true);

	// LED 1 Green
	err = nrfx_gpiote_channel_alloc(&gpiote, &led_1_g_ch);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_channel_alloc: led_1_g: error (%u)\r\n", err);
		return;
	}

	err = nrfx_gpiote_output_configure(&gpiote, LED_1_G,
					   &led_1_g_out_config,
					   &led_1_g_task_config);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_output_configure: led_1_g: error (%u)\r\n", err);
		return;
	}

	nrfx_gpiote_out_task_enable(&gpiote, LED_1_G);

	// LED 2 Red
	err = nrfx_gpiote_channel_alloc(&gpiote, &led_2_r_ch);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_channel_alloc: led_2_r: error (%u)\r\n", err);
		return;
	}

	err = nrfx_gpiote_output_configure(&gpiote, LED_2_R,
					   &led_2_r_out_config,
					   &led_2_r_task_config);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_output_configure: led_2_r: error (%u)\r\n", err);
		return;
	}

	nrfx_gpiote_out_task_enable(&gpiote, LED_2_R);

	// LED 2 Green
	err = nrfx_gpiote_channel_alloc(&gpiote, &led_2_g_ch);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_channel_alloc: led_2_g: error (%u)\r\n", err);
		return;
	}

	err = nrfx_gpiote_output_configure(&gpiote, LED_2_G,
					   &led_2_g_out_config,
					   &led_2_g_task_config);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_output_configure: led_2_g: error (%u)\r\n", err);
		return;
	}

	nrfx_gpiote_out_task_enable(&gpiote, LED_2_G);

	// LED 2 Blue
	err = nrfx_gpiote_channel_alloc(&gpiote, &led_2_b_ch);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_channel_alloc: led_2_b: error (%u)\r\n", err);
		return;
	}

	err = nrfx_gpiote_output_configure(&gpiote, LED_2_B,
					   &led_2_b_out_config,
					   &led_2_b_task_config);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gpiote_output_configure: led_2_b: error (%u)\r\n", err);
		return;
	}

	nrfx_gpiote_out_task_enable(&gpiote, LED_2_B);

	err = nrfx_gppi_channel_alloc(&ppi_ch);
	if (err != NRFX_SUCCESS) {
		printf("nrfx_gppi_channel_alloc: error (%u)\r\n", err);
		return;
	}

	nrfx_gppi_channel_endpoints_setup(ppi_ch,
		nrfx_gpiote_in_event_address_get(&gpiote, SW_1),
		nrfx_gpiote_out_task_address_get(&gpiote, LED_1_G));
	nrfx_gppi_channels_enable(1UL << (ppi_ch));
}

static nrfx_uarte_t uarte_0 = {
	.p_reg = NRF_UARTE0,
	.drv_inst_idx = 0
};
static nrfx_uarte_config_t uarte_0_config = NRFX_UARTE_DEFAULT_CONFIG(UARTE_0_TX_PIN, UARTE_0_RX_PIN);

#if !defined(USE_SPIM_0)
static nrfx_uarte_t uarte_1 = {
	.p_reg = NRF_UARTE1,
	.drv_inst_idx = 1
};
static nrfx_uarte_config_t uarte_1_config = NRFX_UARTE_DEFAULT_CONFIG(UARTE_1_TX_PIN, UARTE_1_RX_PIN);
#endif // ! USE_SPIM_0

#if !defined(TEST_UARTE_NOTIFY)
#if !defined(USE_SPIM_0)
static nrfx_twim_t twim_0 = {
	.p_twim = NRF_TWIM1,
	.drv_inst_idx = 1
};
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

static int16_t saadc_value[4] = { 0 };
static uint32_t saadc_mask = 0xf;
static nrfx_saadc_channel_t saadc[] = {
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_0, 0),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_5, 1),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_7, 2),
	NRFX_SAADC_DEFAULT_CHANNEL_SE(AIN_VDD, 3),
};
#endif // ! TEST_UARTE_NOTIFY

#if !defined(USE_SPIM_0)
static uint8_t uarte_1_rx[1] = { 0 };
static TaskHandle_t uarte_1_task;

static void uarte_1_task_function (void *pvParameter)
{
	while (true) {
		// trigger IRQ read
		nrfx_uarte_rx(&uarte_1, uarte_1_rx, 1);
		// wait of IRQ completion
#if defined(TEST_UARTE_NOTIFY)
		if (ulTaskNotifyTake(pdTRUE, 5000 / portTICK_PERIOD_MS) != 1) {
			fprintf(stderr, "5 second timeout\r\n");
#else
		if (ulTaskNotifyTake(pdTRUE, portMAX_DELAY) != 1) {
#endif // TEST_UARTE_NOTIFY
			continue;
		}
#if defined(TEST_UARTE_NOTIFY)
		// echo to console
		while (nrfx_uarte_tx_in_progress(&uarte_1))
			nrfx_coredep_delay_us(10);
		nrfx_uarte_tx(&uarte_0, &uarte_1_rx[0], 1);
#endif // TEST_UARTE_NOTIFY
		nrfx_gpiote_out_toggle(&gpiote, LED_1_G);
	}
}

static void uarte_1_callback(nrfx_uarte_event_t const *evt, void *ctx)
{
	switch (evt->type) {
	case NRFX_UARTE_EVT_RX_DONE:
		{
			BaseType_t xHigherPriorityTaskWoken = pdFALSE;
			vTaskNotifyGiveFromISR(uarte_1_task, &xHigherPriorityTaskWoken);
			portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
		}
		break;

	case NRFX_UARTE_EVT_TX_DONE:
		break;

	case NRFX_UARTE_EVT_ERROR:
	default:
		break;
	}
}
#endif // ! USE_SPIM_0

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
#if !defined(TEST_UARTE_NOTIFY)
	uint8_t i;
#if !defined(USE_SPIM_0)
	uint8_t nl[] = { 13, 10 }; // '\r\n'
	nrfx_err_t err;
#endif // USE_SPIM_0
#endif // ! TEST_UARTE_NOTIFY

	while (true) {
#if defined(TEST_UARTE_NOTIFY)
		vTaskDelay(10 / portTICK_PERIOD_MS);
#else
		printf("  MS: %lu\r\n", count);
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
		// send data on SPIM 1, UARTE 1, and UARTE 0 [console]
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
			nrfx_uarte_tx(&uarte_1, &data_tx[tx_id][i], 1, 0);
#endif // USE_SPIM_0
		}
		printf("\r\n");
#if !defined(USE_SPIM_0)
		while (nrfx_uarte_tx_in_progress(&uarte_1))
			nrfx_coredep_delay_us(10);
		nrfx_uarte_tx(&uarte_1, nl, sizeof(nl), 0);
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

		vTaskDelay(1000 / portTICK_PERIOD_MS);

		nrfx_gpiote_out_clear(&gpiote, LED_2_G);
		nrfx_gpiote_out_clear(&gpiote, LED_2_B);
		nrfx_gpiote_out_set(&gpiote, LED_2_R);

		vTaskDelay(1000 / portTICK_PERIOD_MS);

		nrfx_gpiote_out_clear(&gpiote, LED_2_R);
		nrfx_gpiote_out_clear(&gpiote, LED_2_B);
		nrfx_gpiote_out_set(&gpiote, LED_2_G);

		vTaskDelay(1000 / portTICK_PERIOD_MS);

		nrfx_gpiote_out_clear(&gpiote, LED_2_R);
		nrfx_gpiote_out_clear(&gpiote, LED_2_G);
		nrfx_gpiote_out_set(&gpiote, LED_2_B);

		printf("\r\e[2J");
#endif // TEST_UARTE_NOTIFY
	}
}

int main(void)
{
	BaseType_t rc;
	nrfx_err_t err;

	syscalls_init(&uarte_0, &uarte_0_config);

	printf("\r\nStarting ...\r\n");

	gpio_init();

#if !defined(USE_SPIM_0)
	printf("\r\nUARTE 1 Init ...\r\n");

	err = nrfx_uarte_init(&uarte_1, &uarte_1_config, uarte_1_callback);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_uarte_init\r\n");
		nrfx_gpiote_out_clear(&gpiote, LED_2_G);
		nrfx_gpiote_out_clear(&gpiote, LED_2_B);
		nrfx_gpiote_out_clear(&gpiote, LED_1_G);
		while (true) {
			nrfx_coredep_delay_us(2000000);
			nrfx_gpiote_out_toggle(&gpiote, LED_2_R);
		}
	}
#endif // ! USE_SPIM_0

#if !defined(TEST_UARTE_NOTIFY)
	printf("\r\nSAADC Init ...\r\n");

	nrfx_saadc_init(NRFX_SAADC_DEFAULT_CONFIG_IRQ_PRIORITY);
	nrfx_saadc_channels_config(saadc, sizeof(saadc) / sizeof(saadc[0]));
	nrfx_saadc_offset_calibrate(NULL);

#if defined(USE_SPIM_0)
	printf("\r\nSPIM 0 Init ...\r\n");

	err = nrfx_spim_init(&spim_0, &spim_0_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_spim_init\r\n");
		nrfx_gpiote_out_clear(&gpiote, LED_2_G);
		nrfx_gpiote_out_clear(&gpiote, LED_2_B);
		nrfx_gpiote_out_clear(&gpiote, LED_1_G);
		while (true) {
			nrfx_coredep_delay_us(1000000);
			nrfx_gpiote_out_toggle(&gpiote, LED_2_R);
		}
	}
#else
	printf("\r\nTWIM 1 Init ...\r\n");

	err = nrfx_twim_init(&twim_0, &twim_0_config, NULL, NULL);
	if (err != NRFX_SUCCESS) {
		printf("error nrfx_twim_init\r\n");
		nrfx_gpiote_out_clear(&gpiote, LED_2_G);
		nrfx_gpiote_out_clear(&gpiote, LED_2_B);
		nrfx_gpiote_out_clear(&gpiote, LED_1_G);
		while (true) {
			nrfx_coredep_delay_us(3000000);
			nrfx_gpiote_out_toggle(&gpiote, LED_2_R);
		}
	}

	nrfx_twim_enable(&twim_0);
#endif // USE_SPIM_0
#endif // ! TEST_UARTE_NOTIFY

	nrfx_gpiote_out_toggle(&gpiote, LED_1_G);

	printf("\r\nCreating main_task ... ");

	rc = xTaskCreate(main_task_function, "main_task",
						configMINIMAL_STACK_SIZE + 200,
						NULL,
						2,
						&main_task);
	if (rc != pdPASS) {
		printf("error xTaskCreate (%lu)\r\n", rc);
		while (true);
	}
	printf("Done (%lu)\r\n", rc);

	printf("\r\nCreating count_task ... ");

	rc = xTaskCreate(count_task_function, "count_task",
						configMINIMAL_STACK_SIZE + 200,
						NULL,
						2,
						&count_task);
	if (rc != pdPASS) {
		printf("error xTaskCreate (%lu)\r\n", rc);
		while (true);
	}
	printf("Done (%lu)\r\n", rc);

#if !defined(USE_SPIM_0)
	printf("\r\nCreating uarte_1_task ... ");

	rc = xTaskCreate(uarte_1_task_function, "uarte_1_task",
						configMINIMAL_STACK_SIZE + 200,
						NULL,
						(configMAX_PRIORITIES - 1),
						&uarte_1_task);
	if (rc != pdPASS) {
		printf("error xTaskCreate (%lu)\r\n", rc);
		while (true);
	}
	printf("Done (%lu)\r\n", rc);
#endif // ! USE_SPIM_0

	SCB->SCR |= SCB_SCR_SLEEPDEEP_Msk;

	printf("\r\nStarting FreeRTOS Scheduler ...\r\n");

	vTaskStartScheduler();

	printf("Oops!\r\n");

	while (true);

	return 0;
}
