/*
 * This is a C source file for the 'etinker' library
 *
 * Copyright (C) 2021 Derald D. Woods
 *
 * This file is part of the Embedded Tinkerer Sandbox, and is made
 * available under the terms of the GNU General Public License version 3.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include <etinker.h>

static int total = 0;
static int passed = 0;
static int failed = 0;

bool etinker_version_string_test(void)
{
	bool passing = true;

	printf("________________________________________________________________________\n");
	printf("TEST:\tetinker_version_string()\n");

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

	printf("________________________________________________________________________\n");
	printf("TEST: TOTAL(%d): PASSED(%d): FAILED(%d)\n", total, passed, failed);

	exit(EXIT_SUCCESS);
}
