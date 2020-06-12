@echo Compilando con sjasmplus
sjasmplus borde10.asm -DPASMO=0 --raw=prueba.bin
if errorlevel 1 goto error_compilando

@echo iniciando RetroVirtualMachine
RetroVirtualMachine.exe -b=zx48k -l=0x8000 prueba.bin -j=0x8000 -ns
goto end

:error_compilando
@echo Error compilando 

:end