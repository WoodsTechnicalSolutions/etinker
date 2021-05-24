/*
 * This is a C source file for the 'etinker' library
 *
 * Copyright (C) 2021 Derald D. Woods
 *
 * This file is part of the Embedded Tinkerer Sandbox, and is made
 * available under the terms of the GNU General Public License version 3.
 */

#include "internal.h"

ETINKER_API const char *etinker_version_string(void)
{
	return ETINKER_LIBRARY_VERSION;
}
