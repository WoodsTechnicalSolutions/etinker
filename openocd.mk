#
# This is a GNU Make include for 'etinker'.
#
# openocd JTAG/SWD files
#
# Copyright (C) 2022-2024, Derald D. Woods <woods.technical@gmail.com>
#
# This file is part of the Embedded Tinkerer Sandbox, and is made
# available under the terms of the GNU General Public License version 3.
#
export OPENOCD_CONFIG ?= openocd.cfg
export OPENOCD_GDB_CONFIG ?= openocd-gdb.cfg
export OPENOCD_GDB_LOG := openocd-gdb.log
export OPENOCD_PROGRAM_LOG := openocd-program.log

define openocd
	@if [ -z "`which openocd $(ET_NOERR)`" ]; then \
		printf "***** [$(ET_BOARD)][$(ET_BOARD_TYPE)] 'openocd' is MISSING! *****\n"; \
		exit 2; \
	fi
	@case $(1) in \
	gdb) \
		$(ET_CROSS_TUPLE)-gdb -ex 'target extended-remote | openocd -f $(OPENOCD_CONFIG) -f $(OPENOCD_GDB_CONFIG) -c "telnet_port disabled; tcl_port disabled; gdb_port pipe; log_output $(OPENOCD_GDB_LOG)"' $(2); \
		;; \
	program) \
		openocd -f $(OPENOCD_CONFIG) -c "telnet_port disabled; tcl_port disabled; gdb_port disabled; log_output $(OPENOCD_PROGRAM_LOG); program $(2) verify reset exit"; \
		cat $(OPENOCD_PROGRAM_LOG); \
		;; \
	reset) \
		openocd -f $(OPENOCD_CONFIG) -c "telnet_port disabled; tcl_port disabled; gdb_port disabled" -c "init; reset; exit"; \
		;; \
	server) \
		openocd -f $(OPENOCD_CONFIG); \
		;; \
	*) \
		openocd -f $(OPENOCD_CONFIG) -c $(1); \
		;; \
	esac
endef
