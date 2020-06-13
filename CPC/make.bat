@echo Compilando con sjasmplus
@sjasmplus --nologo --syntax=m -DWINAPE=0 example_borde.asm --raw=prueba.bin
if errorlevel 1 goto error_compilando

@echo iniciando RetroVirtualMachine
RetroVirtualMachine.exe -b=cpc464 -l=0x8000 prueba.bin -j=0x8000 -ns
goto end

:error_compilando
@echo Error compilando 

:end