; Assemble with "nasm -o WINLIN64.exe -f bin WINLIN64.asm"

bits 64
org 0

SOF: ; Marks the start of the file.
; MZ signature also produces a temporary file.
db 'MZ="$(mktemp)";'
; Block comment the headers.
db ' : ', 27h, 10
dd 0a746967h

PE:
db 'PE',0,0 ; PE HEADER SIG (4 bytes)

; COFF Header (20 bytes)
dw 0x8664             ; Machine: AMD64
dw 0                  ; NumberOfSections CAN BE ZERO
dd 6275680ah                 ; TimeDateStamp UNUSED ; 2025-07-10 01:30
dd 6d6f632eh                ; PointerToSymbolTable UNUSED
dd 0a61632fh                 ; NumberOfSymbols UNUSED
dw OHE-OH             ; SizeOfOptionalHeader
; Characteristics
; IMAGE_FILE_EXECUTABLE_IMAGE        = 0x0002
; IMAGE_FILE_LARGE_ADDRESS_AWARE     = 0x0020
; IMAGE_FILE_DEBUG_STRIPPED          = 0x0200
; IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP = 0x0400
dw 0x0622

OH: ; Start of Optional header (PE32+, 112 bytes)
dw 0x20B              ; Magic: PE32+
db 0ah                ; MajorLinkerVersion UNUSED
db 6dh                ; MinorLinkerVersion UNUSED
dd 6e6f7265h          ; SizeOfCode UNUSED
dd 0a61626ch          ; SizeOfInitializedData UNUSED
dd PE                 ; SizeOfUninitializedData UNUSED
dd WSTART             ; AddressOfEntryPoint (RVA)
dd 0a73730ah          ; BaseOfCode UNUSED = e_lfanew
dq 0x0000000000400000 ; ImageBase
dd 0x00000200         ; SectionAlignment
dd 0x00000200         ; FileAlignment
dw 4957h              ; MajorOperatingSystemVersion UNUSED WinXP = 5
dw 4c4eh              ; MinorOperatingSystemVersion UNUSED Pro x64 = 2
dw 4e49h              ; MajorImageVersion UNUSED
dw 3436h              ; MinorImageVersion UNUSED
dw 4                  ; MajorSubsystemVersion (>=4)
dw 0                  ; MinorSubsystemVersion UNUSED
dd 0                  ; Win32VersionValue UNUSED
dd ((EOF-SOF+0x1ff)/0x200)*0x200 ; SizeOfImage
dd 0x200              ; SizeOfHeaders
dd 0                  ; Checksum UNUSED
dw 3                  ; Subsystem: 2 = Win GUI, 3 = Win CUI
dw 0                  ; DllCharacteristics
dq 0x00100000         ; Stack reserve
dq 0x00001000         ; Stack commit
dq 0x00100000         ; Heap reserve
dq 0x00001000         ; Heap commit
dd 0                  ; LoaderFlags
dd 0                  ; NumberOfRvaAndSizes CAN BE ZERO
;times 16 dq 0        ; Data directories NOT NEEDED
OHE: ; End of Optional Header


EH: ; Start of ELF Header
db 7fh, 'ELF'         ; ELF executable signature
db 2                  ; EI_CLASS: 64-bit
db 1                  ; EI_DATA: little-endian
db 1                  ; EI_VERSION: original ELF
db 0                  ; EI_OSABI: System V
db 0                  ; EI_ABIVERSION: none
times 7 db 0          ; EI_PAD: Reserved, zero fill
dw 2                  ; e_type: ET_EXEC, executable file
dw 0x3E               ; e_machine: AMD64
dd 1                  ; e_version: original ELF
dq LSTART-EH+0x400000  ; e_entry: code location
dq PH-EH              ; e_phoff = immediately after header
dq 0                  ; e_shoff: no section headers
dd 0                  ; e_flags: none for AMD64
dw EHE-EH             ; e_ehsize: size of ELF header
dw PHE-PH             ; e_phentsize: size of program header
dw 1                  ; e_phnum: number of entries in program header
dw 0                  ; e_shentsize: size of section header table 
dw 0                  ; e_shnum: number of section header entries
dw 0                  ; e_shstrndx: index of section naming entry
EHE: ; End of ELF Header

; ELF Program Header
PH: ; Start of ELF Program Header
dd 1                ; p_type = PT_LOAD, loadable segment
; p_flags
; PF_X = 0x1        ; Executable
; PF_R = 0x4        ; Readable
dd 5  
dq 0                ; p_offset: virtual offset of segment
dq 0x400000         ; p_vaddr: virtual address of segment
dq 0x400000         ; p_paddr: physical address of segment
dq EOF - EH         ; p_filesz = Image Size
dq EOF - EH         ; p_memsz = Memory to prepare
dq 0x1000           ; p_align = Page Align 4096
PHE:

; End the block comment.
db 27h, 0ah
; Skip 160 bytes, copy the rest to temporary file.
db 'dd if="$0" of="$MZ" bs=1 skip=160 2>/dev/null;'
; Give the temporary file execution permissions.
db 'chmod +x "$MZ";'
; Execute temporary file with given args.
db 'exec "$MZ" "$@";'
; Save the return value to var "r".
db 'r=$?;'
; Delete the temporary file.
db 'rm -f "$MZ";'
; Pass return value back to shell.
db 'exit $r', 10


; 128 bytes of space. More code?


LSTART: ; Start Linux code.
  ;jmp short STARTASM
WINIT:
  ;jmp STARTASM

  times 200h-($-$$) nop ; Space fill with "no op" for later use.
WSTART: ; Start Windows code. Must be aligned to 200h.
  ;jmp short WINIT

STARTASM:
	xor eax, eax
.BUSYLOOP:
  inc rax
  jmp short .BUSYLOOP

EOF: ; End Of File marker.