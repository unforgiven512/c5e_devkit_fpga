# Makefile for building the application selector boot code

S = @
E = @echo \\\# `date +%Y.%m.%d.%H.%M.%S` ---

OBJ = ./obj

ifeq ("$(CODE_BASE)","")
 CODE_BASE = 0x0
endif

ifeq ("$(FLASH_BASE)","")
 FLASH_BASE = 0x0
endif

ifeq ("$(BOOT_IMAGE_OFFSET)","")
 BOOT_IMAGE_OFFSET = 0x0
endif

ALL_TARGS = \
	$(OBJ)/boot_code.elf \
	$(OBJ)/boot_code_relocated.elf \
	$(OBJ)/boot_code.objdump \
	$(OBJ)/boot_code.nm \
	boot_code.srec \
#	boot_code.hex \

all : $(OBJ) $(ALL_TARGS)

clean :
	$(E) Cleaning up
	$(S) -rm -vf $(ALL_TARGS)
	$(S) -rm -vf $(OBJ)/*.s
	$(S) if [ -d $(OBJ) ] ; then rmdir -v $(OBJ) ; fi

$(OBJ) :
	$(E) Creating $@
	$(S) mkdir $@

$(OBJ)/boot_code.elf : \
		boot_code.s \
		boot_code.h \
		$(OBJ)
	$(E) Compiling to $@
	$(S) nios2-elf-cpp boot_code.s \
			-o $(OBJ)/boot_code_pp.s \
			-D FLASH_BASE=$(FLASH_BASE) \
			-D BOOT_IMAGE_OFFSET=$(BOOT_IMAGE_OFFSET)
	$(S) nios2-elf-gcc -nostdlib \
			$(OBJ)/boot_code_pp.s \
			 -Wa, \
			-o $@ -Os

# 			-gdwarf2 -g3 -Wa,-gdwarf \

$(OBJ)/boot_code.objdump : $(OBJ)/boot_code.elf $(OBJ)
	$(E) Objdumping boot_code.elf
	$(S) nios2-elf-objdump -D --source $(OBJ)/boot_code.elf > $@

$(OBJ)/boot_code.nm : $(OBJ)/boot_code.elf $(OBJ)
	$(E) Nm-ing boot_code.elf
	$(S) nios2-elf-nm $(OBJ)/boot_code.elf | sort > $@

boot_code.srec : $(OBJ)/boot_code.elf $(OBJ)
	$(E) Creating SREC file $@
	$(S) nios2-elf-objcopy --output-target=srec $(OBJ)/boot_code.elf $@

#boot_code.hex : boot_code.srec
#	$(E) Creating HEX file $@
#	$(S) nios-convert --infile=boot_code.srec --outfile=$@ --width=32 --oformat=hex
#	$(S) if [ -d boot_code ] ; then rmdir -v boot_code ; fi

$(OBJ)/boot_code_relocated.elf : $(OBJ)/boot_code.elf
	$(E) Relocating .elf to $(CODE_BASE)
	$(S) nios2-elf-objcopy -F elf32-littlenios2 --change-addresses $(CODE_BASE) \
		$(OBJ)/boot_code.elf $@

run : $(OBJ) $(ALL_TARGS)
	$(E) Running .elf at $(CODE_BASE)
	$(S) nios2-download -g $(OBJ)/boot_code_relocated.elf

help :
	@echo .
	@echo . To just build the boot copier:
	@echo .  - make all FLASH_BASE=0x0 BOOT_IMAGE_OFFSET=0x00100000
	@echo .
	@echo . To build and run the boot copier:
	@echo .  - make run CODE_BASE=0x01002000 FLASH_BASE=0x0 BOOT_IMAGE_OFFSET=0x00100000
	@echo .
	@echo . CODE_BASE  = Where the boot copier runs from \(likely on-chip ram\)
	@echo . FLASH_BASE = The base address of your CFI flash component
	@echo . BOOT_IMAGE_OFFSET = The offset within CFI flash where your boot 
	@echo .											image has been programmed
	@echo . 
	@echo . IMPORTANT: To use the \"run\" target, CODE_BASE must point to a RAM.  On-chip
	@echo . memory configured as ROM cannot be loaded externally.  If you intend to use
	@echo . the /"run/" target to run the boot copier from an on-chip memory, ensure the
	@echo . on-chip memory is configured as RAM, not ROM.
	@echo . 

# end of file
