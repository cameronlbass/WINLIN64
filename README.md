# WINLIN64
WINLIN64 is a handcrafted, dual-format executable header for Windows and Linux executing on AMD64.

**How to use**

 WinLin64 is an assembly header that produces a raw binary executable for both Windows and Linux (64-bit). You can use it as a drop-in header for flat NASM-formatted assembly files containing position-independent code. Assemble with: 
```sh
nasm -o WINLIN64.exe -f bin WINLIN64.asm
```
 The resulting WinLin64.exe is a valid Windows PE32+ executable and a valid Linux ELF64 binary - you can run it on either OS without any additional tooling. This has been tested working on AMD64 platforms running Windows 7 Pro, Windows 10 pro, and Ubuntu 22.

 **How it works**
 
 This header exploits the lenient bootstrapping of both Windows PE and Linux ELF formats. Since the file starts with MZ, Windows will check offset 0x3c "e_lfanew" for the position of the very minimal PE header (PE signature at offset 0x18), parse it, then load and run the executable code that follows. Linux will instead see the first 20 bytes of the file as the first line of a script, the headers as contained within a comment, then continue the script by producing and running an executable temporary file sliced from the script itself.
