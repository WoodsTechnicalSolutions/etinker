/*
 * This is the public C header file for the 'etinker' library
 *
 * Copyright (C) 2021 Derald D. Woods
 *
 * This file is part of the Embedded Tinkerer Sandbox, and is made
 * available under the terms of the GNU General Public License version 3.
 */

#pragma once

const char *etinker_version_string(void);

// Third-Party routines

// GPLv2: from libiberty
unsigned int xcrc32 (const unsigned char *buf, int len, unsigned int init);
