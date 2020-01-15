target = main

.PHONY: clean all bitstream pnr flash

all: bitstream

bitstream: $(target).bin

$(target).json: $(target).v
	yosys -p 'synth_ice40 -top $(target) -json $(target).json' $(target).v

pnr: $(target).asc
$(target).asc: $(target).json $(target).pcf
	nextpnr-ice40 --hx1k --json $(target).json --pcf $(target).pcf --asc $(target).asc

$(target).bin: $(target).asc
	icepack $(target).asc $(target).bin

flash: $(target).bin
	iceprog $(target).bin

clean:
	rm -rf $(target).asc $(target).json $(target).bin $(target).blif
