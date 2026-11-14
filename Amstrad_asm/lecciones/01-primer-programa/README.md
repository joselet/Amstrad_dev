# Lección 01: Primer programa

Programa: [`hola.asm`](hola.asm) · Pruébalo con `probar lecciones\01-primer-programa\hola.asm`

## 1. Qué hay dentro de un CPC

- **CPU Z80** a 4 MHz. Es quien ejecuta nuestras instrucciones, una detrás de otra.
- **Memoria**: 64 KB direccionables, de `#0000` a `#FFFF` (el 6128 tiene 128 KB, pero se ven por bloques de 64 KB). Cada dirección guarda un **byte**: un número entre 0 y 255 (`#00`-`#FF`).
- **ROM**: memoria de solo lectura con el BASIC y el **firmware**, el "sistema operativo" del CPC.
- La **pantalla** también es memoria: ocupa de `#C000` a `#FFFF` (lo veremos en la lección 08).

> **Hexadecimal**: en ensamblador casi todo se escribe en base 16. Usaremos el prefijo `#`: `#4000` = 16384. En BASIC del CPC se escribe `&4000`.

## 2. Qué es ensamblador

El Z80 solo entiende bytes. Por ejemplo, `CD 06 BB` significa "llama a la rutina de la dirección `#BB06`". El ensamblador te deja escribirlo como `call #BB06`, y **RASM** lo traduce a esos bytes.

```
hola.asm  --(RASM)-->  bytes (HOLA.BIN)  dentro de  hola.dsk  --(emulador)-->  RUN"HOLA.BIN
```

## 3. Anatomía de una línea

```
etiqueta:   instrucción  operandos      ; comentario
bucle:      ld           a,(hl)         ; A = carácter actual
```

- **Etiqueta**: un nombre para una dirección de memoria, para poder saltar a ella sin saber el número exacto.
- **Comentario**: lo que va tras `;`. El ensamblador lo ignora.

Hay dos tipos de órdenes:
- **Instrucciones** del Z80 (`ld`, `call`, `jr`...): se convierten en código máquina.
- **Directivas** del ensamblador (`org`, `db`, `save`): instrucciones para RASM, no para el Z80.

## 4. El programa, línea a línea

| Línea | Qué hace |
|---|---|
| `org #4000` | Directiva: el código empieza en la dirección `#4000`, una zona libre de memoria. |
| `ld hl,mensaje` | Carga en el registro **HL** la dirección donde está el texto. |
| `ld a,(hl)` | Lee el byte de la dirección a la que apunta HL y lo mete en **A**. Los paréntesis significan "el contenido de". |
| `or a` | Truco habitual para preguntar "¿A vale 0?". Activa el **flag Z** (cero) si es así. |
| `jr z,espera` | Si el flag Z está activo, salta a `espera`; si no, sigue con la línea siguiente. |
| `call #BB5A` | Llama a la rutina del firmware TXT OUTPUT, que imprime el carácter que hay en A. |
| `inc hl` | HL = HL + 1: apunta al siguiente carácter. |
| `jr bucle` | Salta siempre a `bucle`. |
| `call #BB06` | KM WAIT CHAR: se queda esperando hasta que pulses una tecla. |
| `rst 0` | Salta a la dirección 0, donde está el reinicio del CPC. |
| `db "Pulsa...",0` | Directiva: coloca esos bytes (los códigos ASCII del texto) en memoria, y un 0 para marcar el final. |
| `save ...` | Directiva de RASM: guarda desde `inicio` hasta `fin` como `HOLA.BIN` en `build/hola.dsk`. |

## 5. Registros

Los registros son pequeñas "variables" dentro del propio Z80. Son mucho más rápidos que la memoria, pero hay muy pocos.

- **A** (acumulador): 8 bits. Es el protagonista de casi todas las operaciones.
- **HL**: 16 bits, se usa mucho como **puntero** (guarda una dirección de memoria).
- Hay más (B, C, D, E, H, L, BC, DE...); los veremos en la lección 02.

## 6. El firmware

Es una colección de rutinas de la ROM que se llaman con `call` a direcciones fijas: el **jumpblock**, de `#BB00` en adelante. Nos ahorran muchísimo trabajo: imprimir, leer el teclado, dibujar, cargar del disco... Cada rutina tiene sus **entradas** (qué registros debes preparar) y sus **salidas** (qué te devuelve). Las que vamos usando están en [`referencia/firmware.md`](../../referencia/firmware.md).

## Resumen

- Un programa son bytes en memoria. `org` dice dónde van.
- `ld` copia datos; `(hl)` es "lo que hay en la dirección HL".
- `call` usa rutinas del firmware; `jr` salta, y `jr z` salta solo si el resultado fue cero.
- `db` mete datos (textos) en el programa.

Ahora, a los [ejercicios](ejercicios.md).
