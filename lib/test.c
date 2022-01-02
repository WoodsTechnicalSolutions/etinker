/*
 * This is a C source file for the 'etinker' library
 *
 * Copyright (C) 2021-2022 Derald D. Woods
 *
 * This file is part of the Embedded Tinkerer Sandbox, and is made
 * available under the terms of the GNU General Public License version 3.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <etinker.h>

static int total = 0;
static int passed = 0;
static int failed = 0;

bool etinker_version_string_test(void)
{
	bool passing = true;

	printf("________________________________________________________________________\n");
	printf("TEST:\tconst char *etinker_version_string(void)\n");
	printf("------------------------------------------------------------------------\n");

	printf("\tetinker_version_string(): NULL CHECK: ");
	if (etinker_version_string() == NULL) {
		printf("FAILED\n");
		passing = false;
		failed++;
	} else {
		printf("PASSED\n");
		passed++;
	}
	total++;

	printf("\tetinker_version_string(): EMPTY CHECK: ");
	if (!strlen(etinker_version_string())) {
		printf("FAILED\n");
		passing = false;
		failed++;
	} else {
		printf("PASSED\n");
		passed++;
	}
	total++;

	if (passing)
		printf("\tetinker_version_string(): %s\n", etinker_version_string());

	return passing;
}

bool etinker_crc32_test(void)
{
	bool err = false;
	bool passing = true;
	const char *str = "etinker library";
	size_t len = strlen(str);
	unsigned char data[16];

	memcpy(data, str, sizeof(data));

	printf("________________________________________________________________________\n");
	printf("TEST:\tunsigned int etinker_crc32(const unsigned char *buf, int len, unsigned int init, bool *err)\n");
	printf("------------------------------------------------------------------------\n");

	printf("\tetinker_crc32(): NULL 'buf' CHECK: ");
	etinker_crc32(NULL, len, ETINKER_CRC32_INIT, &err);
	if (err == false) {
		printf("FAILED\n");
		passing = false;
		failed++;
	} else {
		printf("PASSED\n");
		passed++;
	}
	total++;

	printf("\tetinker_crc32(): ZERO 'len' CHECK: ");
	etinker_crc32(data, 0, ETINKER_CRC32_INIT, &err);
	if (err == false) {
		printf("FAILED\n");
		passing = false;
		failed++;
	} else {
		printf("PASSED\n");
		passed++;
	}
	total++;

	printf("\tetinker_crc32(): NEGATIVE 'len' CHECK: ");
	etinker_crc32(data, -len, ETINKER_CRC32_INIT, &err);
	if (err == false) {
		printf("FAILED\n");
		passing = false;
		failed++;
	} else {
		printf("PASSED\n");
		passed++;
	}
	total++;

	if (passing)
		printf("\tetinker_crc32(): \"etinker library\" -> 0x%08x\n",
			etinker_crc32(data, len, ETINKER_CRC32_INIT, &err));

	return passing;
}

int main(int argc, const char **argv, const char **envp)
{
	if (argc > 1) {
		int i = 0;
		if (argv) {
			while (i < argc) {
				printf("%s", argv[i++]);
				if (i < argc)
					printf(" ");
			}
			printf("\n");
		}
		if (envp && envp[0]) {
			i = 0;
			while (envp[i])
				printf("%s\n", envp[i++]);
		}
	}

	etinker_version_string_test();
	etinker_crc32_test();

	printf("________________________________________________________________________\n");
	printf("TEST: TOTAL(%d): PASSED(%d): FAILED(%d)\n", total, passed, failed);

	exit(EXIT_SUCCESS);
}
