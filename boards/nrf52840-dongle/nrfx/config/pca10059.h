/**
 * Copyright (c) 2017 - 2019, Nordic Semiconductor ASA
 * Copyright (c) 2020 - 2025, Derald D. Woods <woods.technical@gmail.com>
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

#include "nrfx_gpiote.h"
#include "nrfx_saadc.h"

// fixed I/O pin assignments
//----------------------------------------------------------------------

#define SW_1  NRF_GPIO_PIN_MAP(1, 6)

#define LED_1_G  NRF_GPIO_PIN_MAP(0,  6)
#define LED_2_R  NRF_GPIO_PIN_MAP(0,  8)
#define LED_2_G  NRF_GPIO_PIN_MAP(1,  9)
#define LED_2_B  NRF_GPIO_PIN_MAP(0, 12)

// board edge pin assignments
//----------------------------------------------------------------------

#define UARTE_0_RX_PIN  NRF_GPIO_PIN_MAP(0, 13) // HF
#define UARTE_0_TX_PIN  NRF_GPIO_PIN_MAP(0, 15) // HF

#if defined(USE_SPIM_0)

#define SPIM_0_MISO_PIN  NRF_GPIO_PIN_MAP(0, 17) // HF
#define SPIM_0_MOSI_PIN  NRF_GPIO_PIN_MAP(0, 20) // HF
#define SPIM_0_SCLK_PIN  NRF_GPIO_PIN_MAP(0, 22) // HF
#define SPIM_0_CS_PIN    NRF_GPIO_PIN_MAP(0, 24) // HF

#else // !USE_SPIM_0

#define UARTE_1_RX_PIN  NRF_GPIO_PIN_MAP(0, 17) // HF
#define UARTE_1_TX_PIN  NRF_GPIO_PIN_MAP(0, 20) // HF

#define TWIM_0_SCL_PIN  NRF_GPIO_PIN_MAP(0, 22) // HF
#define TWIM_0_SDA_PIN  NRF_GPIO_PIN_MAP(0, 24) // HF

#endif // USE_SPIM_0

#define GPIO_PWM_PIN  NRF_GPIO_PIN_MAP(1, 0) // HF

#define GPIO_1_PIN  NRF_GPIO_PIN_MAP(0,  9)
#define GPIO_2_PIN  NRF_GPIO_PIN_MAP(0, 10)
#define GPIO_3_PIN  NRF_GPIO_PIN_MAP(1, 10)
#define GPIO_4_PIN  NRF_GPIO_PIN_MAP(1, 13)
#define GPIO_5_PIN  NRF_GPIO_PIN_MAP(1, 15)

#if defined(USE_ALL_GPIO)

#define GPIO_6_PIN  NRF_GPIO_PIN_MAP(0,  2)
#define GPIO_7_PIN  NRF_GPIO_PIN_MAP(0, 29)
#define GPIO_8_PIN  NRF_GPIO_PIN_MAP(0, 31)

#else

#define AIN_0  NRF_SAADC_INPUT_AIN0 // P0.02
#define AIN_5  NRF_SAADC_INPUT_AIN5 // P0.29
#define AIN_7  NRF_SAADC_INPUT_AIN7 // P0.31

#endif // USE_ADC

#define AIN_VDD  NRF_SAADC_INPUT_VDD  // VDD

// bottom side pin assignments
//----------------------------------------------------------------------

#define GPIO_9_PIN   NRF_GPIO_PIN_MAP(1,  1)
#define GPIO_10_PIN  NRF_GPIO_PIN_MAP(1,  2)
#define GPIO_11_PIN  NRF_GPIO_PIN_MAP(1,  4)
#define GPIO_12_PIN  NRF_GPIO_PIN_MAP(1,  7)
#define GPIO_13_PIN  NRF_GPIO_PIN_MAP(1, 11)

#define SPIM_1_SCLK_PIN  NRF_GPIO_PIN_MAP(0, 11) // HF
#define SPIM_1_CS_PIN    NRF_GPIO_PIN_MAP(0, 14) // HF
#define SPIM_1_MOSI_PIN  NRF_GPIO_PIN_MAP(0,  4) // HF
#define SPIM_1_MISO_PIN  NRF_GPIO_PIN_MAP(0, 26) // HF

#ifdef __cplusplus
}
#endif

#endif // PCA10059_H
