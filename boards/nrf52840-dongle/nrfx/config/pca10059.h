/**
 * Copyright (c) 2017 - 2019, Nordic Semiconductor ASA
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form, except as embedded into a Nordic
 *    Semiconductor ASA integrated circuit in a product or a software update for
 *    such product, must reproduce the above copyright notice, this list of
 *    conditions and the following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *
 * 3. Neither the name of Nordic Semiconductor ASA nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * 4. This software, with or without modification, must only be used with a
 *    Nordic Semiconductor ASA integrated circuit.
 *
 * 5. Any software provided in binary form under this license must not be reverse
 *    engineered, decompiled, modified and/or disassembled.
 *
 * THIS SOFTWARE IS PROVIDED BY NORDIC SEMICONDUCTOR ASA "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL NORDIC SEMICONDUCTOR ASA OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
#ifndef PCA10059_H
#define PCA10059_H

#ifdef __cplusplus
extern "C" {
#endif

#include "nrf_gpio.h"
#include "nrfx_saadc.h"

// LED definitions for PCA10059
// Each LED color is considered a separate LED
#define LEDS_NUMBER    4

#define LED1_G         NRF_GPIO_PIN_MAP(0,6)
#define LED2_R         NRF_GPIO_PIN_MAP(0,8)
#define LED2_G         NRF_GPIO_PIN_MAP(1,9)
#define LED2_B         NRF_GPIO_PIN_MAP(0,12)

#define LED_1          LED1_G
#define LED_2          LED2_R
#define LED_3          LED2_G
#define LED_4          LED2_B

#define LEDS_ACTIVE_STATE 0

#define LEDS_LIST { LED_1, LED_2, LED_3, LED_4 }

#define LEDS_INV_MASK  LEDS_MASK

#define BSP_LED_0      LED_1
#define BSP_LED_1      LED_2
#define BSP_LED_2      LED_3
#define BSP_LED_3      LED_4

// There is only one button for the application
// as the second button is used for a RESET.
#define BUTTONS_NUMBER 1

#define BUTTON_1       NRF_GPIO_PIN_MAP(1,6)
#define BUTTON_PULL    NRF_GPIO_PIN_PULLUP

#define BUTTONS_ACTIVE_STATE 0

#define BUTTONS_LIST { BUTTON_1 }

#define BSP_BUTTON_0   BUTTON_1

#define BSP_SELF_PINRESET_PIN NRF_GPIO_PIN_MAP(0,19)

#define HWFC           true

// DEFAULT PIN ASSIGNMENTS

#define UART_0_RX       9 // P0.09
#define UART_0_TX      10 // P0.10
#define UART_0_RX_PIN  NRF_GPIO_PIN_MAP(0,UART_0_RX)
#define UART_0_TX_PIN  NRF_GPIO_PIN_MAP(0,UART_0_TX)

#define UART_1_RX       0 // P1.00
#define UART_1_TX      15 // P1.15
#define UART_1_RX_PIN  NRF_GPIO_PIN_MAP(1,UART_1_RX)
#define UART_1_TX_PIN  NRF_GPIO_PIN_MAP(1,UART_1_TX)

#define SPI_MISO      13 // P0.13
#define SPI_MOSI      15 // P0.15
#define SPI_SCLK      17 // P0.17
#define SPI_CS        20 // P0.20
#define SPI_MISO_PIN  NRF_GPIO_PIN_MAP(0,SPI_MISO)
#define SPI_MOSI_PIN  NRF_GPIO_PIN_MAP(0,SPI_MOSI)
#define SPI_SCLK_PIN  NRF_GPIO_PIN_MAP(0,SPI_SCLK)
#define SPI_CS_PIN    NRF_GPIO_PIN_MAP(0,SPI_CS)

#define I2C_SCL      10 // P1.10
#define I2C_SDA      13 // P1.13
#define I2C_SCL_PIN  NRF_GPIO_PIN_MAP(1,I2C_SCL)
#define I2C_SDA_PIN  NRF_GPIO_PIN_MAP(1,I2C_SDA)

#define GPIO_1    NRF_GPIO_PIN_MAP(0,22)
#define GPIO_2    NRF_GPIO_PIN_MAP(0,24)

#define GPIO_PWM  NRF_GPIO_PIN_MAP(0,31)

#define AIN_0  NRF_ADC_CONFIG_INPUT_0 // P0.02
#define AIN_5  NRF_ADC_CONFIG_INPUT_5 // P0.29

#ifdef __cplusplus
}
#endif

#endif // PCA10059_H
