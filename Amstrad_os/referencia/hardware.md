# Hardware del CPC sin firmware

Solo importa el byte alto del puerto (registro B en `out (c),r`).

## Gate Array (`#7Fxx`)
Un mismo puerto; los bits 7-6 del dato eligen la función:

| Dato | Función |
|---|---|
| `%000ppppp` | elegir pluma (0-15) o borde (`#10`) |
| `%010ccccc` | color hardware de la pluma elegida (`#40` + código) |
| `%100iurmm` | `mm` = modo de pantalla, `r` = 1 desactiva la ROM inferior, `u` = 1 desactiva la superior, `i` = 1 reinicia el contador de interrupciones |
| `%11......` | paginación de RAM (6128 / 128 KB): `#C0`-`#C7` |

Valores habituales: `#8E` = modo 2 sin ROM; `#8A` = modo 2 con la ROM inferior; `#86` = modo 2 con la ROM superior.

Algunos colores hardware: negro `#54`, azul `#44`, azul brillante `#55`, blanco `#40`, blanco brillante `#4B`, amarillo brillante `#43`, verde brillante `#52`, rojo brillante `#4C`.

## Interrupciones
El Gate Array genera una interrupción cada 52 líneas: **300 por segundo**, 6 por cuadro. El SO usa **IM 1** (salto a #0038). El Z80 la reconoce automáticamente al aceptarla; el contador interno se sincroniza con el VSYNC.

## CRTC 6845 (`#BCxx` registro, `#BDxx` valor)
- R1 = 40 (columnas de 2 bytes visibles), R6 = 25 (filas de caracteres visibles), R9 = 7 (líneas por fila).
- **R12/R13**: dirección de inicio de pantalla. `R12 = #30, R13 = 0` → #C000. Variar el desplazamiento (en palabras) produce scroll por hardware.

Dirección de un carácter en modo 2 con desplazamiento 0: `#C000 + fila*80 + columna`. Cada línea de píxeles del carácter suma `#800`.

## PPI 8255 (`#F4xx` A, `#F5xx` B, `#F6xx` C, `#F7xx` control)
- El puerto A habla con el PSG (bus de datos). El puerto C: bits 0-3 = fila del teclado, bits 7-6 = función del PSG.
- Puerto B, bit 0: VSYNC del CRTC.
- Lectura del teclado: seleccionar el registro 14 del PSG, poner el puerto A en entrada y escribir la fila (0-9) en C con la función "leer". Cada bit a 0 es una tecla pulsada.

## Selección de ROM superior (`#DFxx`)
`out (#DFxx),n` elige qué ROM aparece en #C000 cuando la ROM superior está activada. La 0 suele ser BASIC y la 7 AMSDOS. La M4 ocupa el slot que tenga configurado.

## ROM inferior
El sistema operativo de Amstrad en #0000-#3FFF. La fuente de caracteres de 8x8 está en **#3800-#3FFF** en los 464/664/6128.
