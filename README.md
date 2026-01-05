# VZ200-Aseprite-Export
LUA script to export sprite data to VZ200 Assembly Hex format

or TRSE byte Array in Decimal format

or Z88DK char Array in Decimal format

or use TRS-80 Coco FCB opcode for Assembly Hex format


VZ200 sprite data export by Jason "WauloK" Oakley
https://www.BlueBilby.com/


Based on Gameboy export code from

https://github.com/boombuler/aseprite-gbexport/blob/master/GameboyExport.lua

May also work for other Motorola 6847 based graphics chip computers

https://en.wikipedia.org/wiki/Motorola_6847

Place this file in the Aseprite scripts directory.
Usually on Windows: %APPDATA%\Aseprite\scripts
and on Linux: ~/.config/aseprite/scripts/

I've also included the Indexed palette to use. Load it in Aseprite.

Example outputs.


VZ200 Assembly:

DB $00, $00

DB $40, $01

DB $80, $02

DB $c0, $03

DB $00, $00

DB $00, $00

DB $00, $00

DB $00, $00


TRSE byte Array:

spriteData: array[] of byte =(001, 064, 064, 001, 128, 002, 192, 003, 000, 000, 068, 068, 017, 017, 068, 068);

Z88DK char Array:

char sprite[16]={15, 240, 63, 124, 255, 223, 255, 255, 255, 255, 251, 255, 62, 252, 15, 240};

TRS-80 Coco Assembly:

FCB $01, $40

FCB $40, $01

FCB $80, $02

FCB $c0, $03

FCB $00, $00

FCB $44, $44

FCB $11, $11

FCB $44, $44

Now also supporting binary file output of hires 2bbp sprite data and 1bit character font data.
