/*
 * This is the public C header file for the 'etinker' library
 *
 * Uses similar library concepts as found in 'libgpiod' here:
 * - https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git
 *
 * Copyright (C) 2021-2022 Derald D. Woods
 *
 * This file is part of the Embedded Tinkerer Sandbox, and is made
 * available under the terms of the GNU General Public License version 3.
 */

#pragma once

#include <stdbool.h>

enum etinker_enum {
	ETINKER_CRC32_INIT = 0xffffffff,
};

const char *etinker_version_string(void);

unsigned int etinker_crc32(const unsigned char *buf, int len, unsigned int init, bool *err);

// Third-Party routines

// GPLv2: from libiberty
unsigned int xcrc32 (const unsigned char *buf, int len, unsigned int init);
