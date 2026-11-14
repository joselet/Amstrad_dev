# Glosario

- **Bit / byte**: un bit es 0 o 1; un byte son 8 bits (0-255).
- **Hexadecimal**: base 16 (0-9, A-F). `#FF` = 255. En RASM se escribe con `#`; en BASIC del CPC, con `&`.
- **Registro**: pequeña memoria dentro del Z80 (A, HL...). Es muy rápida.
- **Puntero**: registro que guarda una dirección de memoria, como HL en `ld a,(hl)`.
- **Flag**: bit que indica cómo salió la última operación. Z = "el resultado fue cero".
- **Etiqueta**: nombre que damos a una dirección del programa.
- **Directiva**: orden para el ensamblador, no para el Z80 (`org`, `db`, `save`).
- **Firmware**: rutinas de la ROM del CPC, accesibles mediante el jumpblock (`#BB00`...).
- **Ensamblar**: traducir el código fuente a código máquina (bytes).
- **DSK**: imagen de un disquete del CPC.
- **AMSDOS**: sistema de disco del CPC. Nombres de archivo de 8+3 caracteres.
