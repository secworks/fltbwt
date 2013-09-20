fltbwt
======

Burrows-Wheeler Transform tool that supports several input and output
data formats including raw binary formats.

The implementation uses index based sorting to keep the memory footprint
down to about 2*n where n is the size of the blocks processed.

There is also (the beginnings of) a decoder in portable 6502
assembler. The decoder requires the presence of an expansion memory
(REU) and will use two memory banks during processing.


