/*
 * This is a C source file for the 'etinker' library
 *
 * Copyright (C) 2021-2022 Derald D. Woods
 *
 * This file is part of the Embedded Tinkerer Sandbox, and is made
 * available under the terms of the GNU General Public License version 3.
 */

#include <etinker.h>

#include "internal.h"

ETINKER_API
const char *etinker_version_string(void)
{
	return ETINKER_LIBRARY_VERSION;
}

ETINKER_API
unsigned int etinker_crc32(const unsigned char *buf, int len, unsigned int init, bool *err)
{
	if (!buf) {
		if (err)
			*err = true;
		return 0;
	}

	if (len <= 0) {
		if (err)
			*err = true;
		return 0;
	}

	return xcrc32(buf, len, init);
}
