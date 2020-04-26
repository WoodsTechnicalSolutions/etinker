/**
 * Copyright (c) 2017 - 2019, Nordic Semiconductor ASA
 * Copyright (c) 2020, Derald D. Woods <woods.technical@gmail.com>
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

#define BUTTON_1       NRF_GPIO_PIN_MAP(1,6)
#define BUTTON_PULL    NRF_GPIO_PIN_PULLUP

// DEFAULT PIN ASSIGNMENTS

#define UARTE_0_RX      26 // P0.26
#define UARTE_0_TX       4 // P0.04
#define UARTE_0_RX_PIN  NRF_GPIO_PIN_MAP(0, UARTE_0_RX)
#define UARTE_0_TX_PIN  NRF_GPIO_PIN_MAP(0, UARTE_0_TX)

#define TWIM_1_SCL      11 // P0.11
#define TWIM_1_SDA      14 // P0.14
#define TWIM_1_SCL_PIN  NRF_GPIO_PIN_MAP(0, TWIM_1_SCL)
#define TWIM_1_SDA_PIN  NRF_GPIO_PIN_MAP(0, TWIM_1_SDA)

#define QSPI_CS        13 // P0.13
#define QSPI_CLK       15 // P0.15
#define QSPI_IO_0      17 // P0.17 [MOSI/DI/SI]
#define QSPI_IO_1      20 // P0.20 [MISO/DO/SO]
#define QSPI_IO_2      22 // P0.22 [/WP]
#define QSPI_IO_3      24 // P0.24 [/HOLD]
#define QSPI_CS_PIN    NRF_GPIO_PIN_MAP(0, QSPI_CS)
#define QSPI_CLK_PIN   NRF_GPIO_PIN_MAP(0, QSPI_CLK)
#define QSPI_IO_0_PIN  NRF_GPIO_PIN_MAP(0, QSPI_IO_0)
#define QSPI_IO_1_PIN  NRF_GPIO_PIN_MAP(0, QSPI_IO_1)
#define QSPI_IO_2_PIN  NRF_GPIO_PIN_MAP(0, QSPI_IO_2)
#define QSPI_IO_3_PIN  NRF_GPIO_PIN_MAP(0, QSPI_IO_3)

// low frequency I/O

#define GPIO_1    NRF_GPIO_PIN_MAP(0,  9) // input
#define GPIO_2    NRF_GPIO_PIN_MAP(0, 10) // input
#define GPIO_3    NRF_GPIO_PIN_MAP(1, 10) // output
#define GPIO_4    NRF_GPIO_PIN_MAP(1, 13) // output
#define GPIO_5    NRF_GPIO_PIN_MAP(1, 15) // output

#define GPIO_PWM  NRF_GPIO_PIN_MAP(1, 0)

#define AIN_0    NRF_SAADC_INPUT_AIN0 // P0.02
#define AIN_5    NRF_SAADC_INPUT_AIN5 // P0.29
#define AIN_7    NRF_SAADC_INPUT_AIN7 // P0.31
#define AIN_VDD  NRF_SAADC_INPUT_VDD  // VDD

#ifdef __cplusplus
}
#endif

#endif // PCA10059_H