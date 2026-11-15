# Amstrad OS

Un sistema operativo sencillo para Amstrad CPC (464/664/6128) en ensamblador Z80. Desactiva el firmware, toma el control total del hardware y ofrece su propia interfaz de comandos. El objetivo final es un **gestor de ficheros de dos paneles para la placa M4**, robusto y que no se cuelgue.

Estado y fases: [`HOJA_DE_RUTA.md`](HOJA_DE_RUTA.md).

## Requisitos
Usa las herramientas del proyecto hermano [`../Amstrad_asm/`](../Amstrad_asm/): RASM en `tools\rasm\` y Caprice32 en `tools\cap32\`. Ver su README para instalarlas.

## Compilar y probar en el emulador
Desde esta carpeta:
```
probar src\os.asm        (compila build\os.dsk y lo ejecuta en Caprice32)
compilar src\os.asm      (solo compila)
ejecutar src\os.asm      (solo ejecuta)
```

## Probar en el CPC real con la M4
1. Copia `build\os.dsk` a la tarjeta SD (o, desde el CPC, súbelo por la interfaz web de la M4).
2. En el CPC: `|CD` hasta la carpeta, monta el disco (o copia `OS.BIN` suelto) y escribe `RUN"OS`.
3. Para volver a BASIC: reset (de momento no hay comando `EXIT`).

Caprice32 no emula la M4: las funciones de ficheros solo se pueden probar en el hardware real.

## Estructura
| Carpeta | Contenido |
|---|---|
| `src/` | código fuente (`os.asm` y, más adelante, sus módulos) |
| `referencia/` | `hardware.md` (puertos del CPC), `m4.md` (protocolo de la M4), `mapa.md` (memoria) |
| `build/` | discos generados (no se versiona) |
