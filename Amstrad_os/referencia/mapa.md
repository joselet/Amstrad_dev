# Mapa de memoria (versión de disco)

| Rango | Uso |
|---|---|
| `#0000-#0037` | libre (el SO no usa RST) |
| `#0038-#003A` | `jp manejador` de la interrupción IM 1 |
| `#0040-#3FFF` | libre (futuro: buffers del shell y de la M4) |
| `#4000-...` | código del SO (`org #4000`, cargado con `RUN"OS.BIN`) |
| `#9000-#97FF` | fuente de 8x8 (2 KB), copiada de la ROM inferior al arrancar |
| `...-#BFFF` | pila (empieza en #C000 y crece hacia abajo) |
| `#C000-#FFFF` | pantalla (modo 2, 80x25) |

En la versión ROM, el código estará en #C000 (encima de la pantalla) y todo lo anterior que sea variable seguirá en RAM.
