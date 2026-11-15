# rsx_bas: cómo crear comandos RSX (|HOLA, |BORDE, |SUMA)

Un **RSX** es un comando nuevo que BASIC acepta escrito con la barra vertical delante (`|DISC`, `|CPM`... son RSX de la ROM de disco). Se programa en código máquina y se "registra" en el firmware.

## Ficheros
- `rsx.asm`: el código fuente comentado (sintaxis RASM, la del curso `Amstrad_asm`). Es lo interesante.
- `rsx.bas`: cargador en BASIC. Copia los bytes del código (líneas `DATA`) en `&A000`, comprueba la suma y hace `CALL &A000`. Después hace una pequeña demo.

Ejecutar (desde `Amstrad_dev_cpctelera`, en WSL): `./cpc.sh run rsx_bas`

## Los pasos para crear un RSX
1. **Reservar memoria**: `MEMORY &9FFF` para que BASIC no pise el código en `&A000`.
2. **Tabla de comandos**: la dirección de la lista de nombres y, después, un `JP` por comando en el mismo orden.
3. **Nombres**: en mayúsculas y con la última letra +`&80` (bit 7) para marcar el final; un `0` cierra la lista.
4. **Registrar**: `KL LOG EXT` (`&BCD1`) con `BC` = tabla y `HL` = 4 bytes libres que usa el firmware para encadenar las tablas.
5. **Recibir parámetros**: al entrar en la rutina, `A` = número de parámetros e `IX` = dónde están, de 2 bytes cada uno y **en orden inverso** (`IX+0` es el último).
   - Un número llega tal cual (16 bits).
   - `@variable` llega como la dirección de la variable, para poder devolver resultados (así funciona `|SUMA,a,b,@r%`). La variable tiene que existir antes (`r%=0`).

## Trampa: no registrar dos veces
Si se llama a `KL LOG EXT` dos veces con la misma tabla, queda enlazada consigo misma y BASIC se cuelga al buscar un comando que no existe. Por eso `rsx.asm` tiene el indicador `instalado` y `rsx.bas` no recarga nada si ya está puesto (al hacer `RUN` otra vez).

## Si cambias rsx.asm
1. Ensamblar con RASM: `..\..\Amstrad_asm\tools\rasm\rasm.exe rsx.asm` → genera `rsx.bin` (solo el código, sin cabecera).
2. Pasar los bytes de `rsx.bin` a las líneas `DATA` de `rsx.bas` y actualizar la suma de la línea 90.
3. Si cambia de sitio la etiqueta `instalado`, ajustar el `PEEK(&A010)` de la línea 40.

## Ideas para seguir explorando
- Un comando con texto: `|ESCRIBE,@a$` recibe la dirección del *descriptor* de la cadena (longitud, y dirección en 2 bytes).
- Devolver error de verdad con la rutina de BASIC en lugar de un mensaje propio.
- Grabar el código como binario (`SAVE "rsx.bin",B,&A000,longitud`) y cargarlo con `LOAD` en vez de con `DATA`.
