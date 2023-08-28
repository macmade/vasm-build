#-------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2014 Jean-David Gadina - www-xs-labs.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

DIR_BUILD := $(realpath ./)/build/
DIR_SRC   := $(realpath ./)/source/
DIR_TMP   := $(realpath ./)/temp/

VASM_VERSION := 1.9 1.9a 1.9c 1.9d
VASM_CPU     := 6502 6800 6809 arm c16x jagrisc m68k pdp11 ppc qnice test tr3200 vidcore x86 z80
VASM_SYNTAX  := std madmac mot oldstyle test

.PHONY: clean

all: $(patsubst %,vasm-%,$(VASM_VERSION))
	
	@:

clean:
	
	@rm -rf $(DIR_TMP)*
	
.SECONDEXPANSION:
	
vasm-%: _VERSION = $(word 2,$(subst -, ,$@))
vasm-%: _UNPACK  = $(patsubst %,unpack-%,$(_VERSION))
vasm-%: _TARGET  = $(foreach CPU,$(VASM_CPU),$(patsubst %,$(CPU)-%,$(VASM_SYNTAX)))
vasm-%: _BUILD   = $(patsubst %,build-$(_VERSION)-%,$(_TARGET))
vasm-%: $$(_UNPACK) $$(_BUILD)
	
	@:

unpack-%: _VERSION = $(word 2,$(subst -, ,$@))
unpack-%: _ARCHIVE = $(DIR_SRC)vasm-$(_VERSION).tar.gz
unpack-%: _TMP     = $(DIR_TMP)vasm-$(_VERSION)/
unpack-%:
	
	@echo "Unpacking vasm $(_VERSION)"
	@if [ ! -d $(_TMP) ]; then mkdir $(_TMP); fi
	@tar -xf $(_ARCHIVE) -C $(_TMP) --strip-components=1

build-%: _VERSION = $(word 2,$(subst -, ,$@))
build-%: _CPU     = $(word 3,$(subst -, ,$@))
build-%: _SYNTAX  = $(word 4,$(subst -, ,$@))
build-%: _TMP     = $(DIR_TMP)vasm-$(_VERSION)/
build-%: _BUILD   = $(DIR_BUILD)vasm-$(_VERSION)/
build-%:

	@echo "Building vasm $(_VERSION) for $(_CPU) - $(_SYNTAX)"
	@cd $(_TMP) && make CPU=$(_CPU) SYNTAX=$(_SYNTAX) 2> /dev/null 1> /dev/null
	@if [ ! -d $(_BUILD) ]; then mkdir $(_BUILD); fi
	@cp $(_TMP)vasm$(_CPU)_$(_SYNTAX) $(_BUILD)
