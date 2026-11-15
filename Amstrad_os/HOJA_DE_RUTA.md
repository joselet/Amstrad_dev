# Hoja de ruta

## Fase 0: arranque del proyecto
- [x] Estructura, `CLAUDE.md`, referencias de hardware y de la M4
- [x] `src/os.asm` mínimo: toma de control, modo 2, texto con la fuente de la ROM, cursor parpadeando por interrupciones
- [ ] Probado en el CPC real del usuario (desde la SD de la M4)

## Fase 1: núcleo
- [ ] Módulo `video`: `cls`, `putc`, `print`, posición del cursor, scroll por hardware (CRTC R12/R13)
- [ ] Fuente propia de 8x8 en el binario (no depender de la ROM inferior, necesario para la versión ROM)
- [ ] Módulo `teclado`: lectura de la matriz (PPI + PSG) en la interrupción, buffer, repetición y mayúsculas
- [ ] Módulo `shell`: línea de edición (borrar, cursores), separar el comando de sus argumentos, tabla de comandos
- [ ] Comandos: `HELP`, `CLS`, `MEM`, `PEEK`, `POKE`, `INFO` (modelo y RAM), `RESET`
- [ ] Módulo `mem`: detectar 64/128 KB

## Fase 2: driver M4
- [ ] Detectar la placa: buscar el slot de ROM cuyo nombre es "M4 BOARD" y leer la versión (#FF00)
- [ ] `m4_enviar` / `m4_respuesta` con comprobación de errores
- [ ] Comandos: `DIR`, `CD`, `PWD`, `TYPE`, `COPY`, `DEL`, `REN`, `MKDIR`, `FREE`
- [ ] `RUN`: cargar un binario (cabecera AMSDOS) y ejecutarlo
- [ ] `NET`: estado de la red, IP y hora (`C_NETSTAT`, `C_TIME`)

## Fase 3: Commander
- [ ] Dos paneles con la lista de ficheros, navegación con cursores, cambio de panel
- [ ] Barra de funciones: ver, copiar, mover, borrar, renombrar, crear directorio
- [ ] Selección múltiple y confirmaciones

## Fase 4: versión ROM
- [ ] Ensamblar con cabecera de ROM de fondo y cargarla en un slot de la M4
- [ ] Arrancar al encender (o con un RSX) y volver a BASIC con `EXIT`

## Fase 5: extras (opcionales)
- [ ] Disquetera interna por el FDC 765
- [ ] Más funciones de red de la M4 (HTTP GET, sockets)
