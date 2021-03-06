PYTHON := python2.7
MD5 := md5sum -c

2bpp     := $(PYTHON) tools/gfx.py 2bpp
1bpp     := $(PYTHON) tools/gfx.py 1bpp
pic      := $(PYTHON) tools/pic.py compress
includes := $(PYTHON) tools/scan_includes.py

pokered_obj := audio_red.o main_red.o text_red.o wram_red.o
pokeblue_obj := audio_blue.o main_blue.o text_blue.o wram_blue.o

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png .2bpp .1bpp .pic
.SECONDEXPANSION:
# Suppress annoying intermediate file deletion messages.
.PRECIOUS: %.2bpp
.PHONY: all clean red blue compare

roms := pokered.gbc pokeblue.gbc

all: $(roms)
red: pokered.gbc
blue: pokeblue.gbc

# For contributors to make sure a change didn't affect the contents of the rom.
compare: red blue
	@$(MD5) roms.md5

clean:
	rm -f $(roms) $(pokered_obj) $(pokeblue_obj) $(roms:.gbc=.sym)
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pic' \) -exec rm {} +
	rm -rf tools/*.pyc

%.asm: ;

%_red.o: dep = $(shell $(includes) $(@D)/$*.asm)
$(pokered_obj): %_red.o: %.asm $$(dep)
	tools/rgbasm -D _RED -h -o $@ $*.asm

%_blue.o: dep = $(shell $(includes) $(@D)/$*.asm)
$(pokeblue_obj): %_blue.o: %.asm $$(dep)
	tools/rgbasm -D _BLUE -h -o $@ $*.asm

pokered_opt  = -Cjv -k 01 -l 0x33 -m 0x13 -p 0 -r 03 -t "POKEMON RED"
pokeblue_opt = -Cjv -k 01 -l 0x33 -m 0x13 -p 0 -r 03 -t "POKEMON BLUE"

%.gbc: $$(%_obj)
	tools/rgblink -n $*.sym -o $@ $^
	tools/rgbfix $($*_opt) $@

%.png:  ;
%.2bpp: %.png  ; @$(2bpp) $<
%.1bpp: %.png  ; @$(1bpp) $<
%.pic:  %.2bpp ; @$(pic)  $<
