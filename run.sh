#!/bin/bash
rmac main.s -px -v -m68000
if [[ $? == 0 ]]; then
	hatari --fast-boot true -d $(pwd) --auto main.prg --debug
fi
