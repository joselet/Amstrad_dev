# CLAUDE.md

Sistema operativo sencillo para Amstrad CPC escrito en ensamblador Z80. Toma el control total de la máquina, sin firmware, y ofrece su propia interfaz de comandos. Encima de él irá un gestor de ficheros de dos paneles, tipo Norton Commander, para la placa **M4** del usuario.

La motivación: el usuario quiere ver "otro sistema" en su CPC real, y el gestor de ficheros M4 que existe se le cuelga a menudo. **La robustez es un requisito, no un extra.**

## Cómo trabajar
- Todo en español (explicaciones, comentarios del código, documentación).
- Claude diseña y programa; el usuario prueba en su hardware real. Explicar el porqué de las decisiones de diseño, porque el usuario está aprendiendo Z80 (ver el curso en `../Amstrad_asm/`).
- Avanzar por hitos pequeños que funcionen, siguiendo `HOJA_DE_RUTA.md`. Al cerrar un hito, marcarlo allí y actualizar `referencia/` si hay puertos, rutinas o direcciones nuevas.

## Máquina objetivo
- Todos los CPC: 464, 664 y 6128. El mínimo común es de 64 KB; si se detectan 128 KB, se aprovechan (paginación #7FC0-#7FC7).
- Arranque: primero desde disco o desde la SD de la M4 (`RUN"OS`). Más adelante, como ROM de fondo que la M4 carga en un slot, para que arranque al encender.

## Arquitectura
- El núcleo hace `di`, desactiva las ROM (Gate Array), instala su propio manejador IM 1 en #0038 y **no llama nunca a rutinas del firmware**. Las ROM solo se leen como datos (fuente de la ROM inferior, respuestas de la M4).
- Módulos en `src/`, cada uno con su interfaz por registros documentada en la cabecera de cada rutina (entrada, salida y registros que modifica):
  - `video`: modo 2 (80x25), fuente 8x8, scroll por hardware con el CRTC.
  - `teclado`: matriz por PPI/PSG, buffer y repetición.
  - `shell`: intérprete de comandos.
  - `mem`: detección de 64/128 KB y paginación.
  - `m4`: driver de la placa por puertos.
- El mapa de memoria está en `referencia/mapa.md`. Cualquier cambio de direcciones se refleja allí.
- El mismo código debe poder ensamblarse para RAM (disco) o para ROM (#C000, cabecera de ROM de fondo) cambiando un `define`. No asumir que el código es escribible: las variables van en RAM, nunca junto al código.

## La M4 (ver `referencia/m4.md`)
- Driver propio con el protocolo de puertos (envío por #FE00, disparo por #FC00, respuesta en #E800 de la ROM de la M4). No se usan los RSX ni el código de la ROM de la M4, solo su zona de respuesta.
- Comprobar siempre el código de estado de cada respuesta. Ante cualquier error: mensaje claro y volver al shell. La máquina no debe quedarse nunca colgada.
- Pedir confirmación antes de cualquier operación destructiva: borrar, sobrescribir, renombrar encima de otro fichero, escribir sectores...
- La ROM de la M4 se pagina en #C000, encima de la memoria de vídeo. Mientras está paginada, leer #C000-#FFFF devuelve ROM (escribir sí va a la RAM de pantalla). Desactivarla en cuanto se ha copiado la respuesta.

## Convenciones del código
- Ensamblador **RASM**; hexadecimal con `#`; etiquetas en español; comentarios en español alineados a la derecha.
- Nombres AMSDOS: máximo 8 caracteres, solo letras y números.
- El programa principal es `src/os.asm` (incluye los módulos con `include`) y termina con su línea `save` hacia `build/os.dsk`.

## Herramientas (compartidas con `../Amstrad_asm/`, no se copian)
- RASM: `..\Amstrad_asm\tools\rasm\rasm.exe`. Caprice32: `..\Amstrad_asm\tools\cap32\`. Captura: `..\Amstrad_asm\tools\captura.ps1`.
- Desde la carpeta `Amstrad_os/`:
  - `compilar src\os.asm`: genera `build\os.dsk`.
  - `ejecutar src\os.asm`: cierra cap32 y lo lanza con `RUN"OS.BIN`.
  - `probar src\os.asm`: hace las dos cosas.
  - Desde PowerShell: `cmd /c ".\probar.bat src\os.asm"`.

## Verificar (Claude)
- Lanzar con `ejecutar`, esperar ~8-10 s, capturar con `captura.ps1` (PNG en el scratchpad) y leer la imagen. Cerrar antes cualquier cap32 previo (`Get-Process cap32 | Stop-Process`), porque si no la captura puede salir de la instancia vieja.
- Teclas simuladas: `keybd_event` con scancode (`MapVirtualKey(vk,0)`), mantenidas ~300 ms.
- **Caprice32 no emula la M4.** Las funciones M4 las prueba el usuario en su CPC real (o en un emulador con M4, como ACE-DL, si se instala). Cada entrega que toque la M4 va acompañada de una lista corta de pruebas para el usuario.
- Al acabar, cerrar el emulador: `Stop-Process -Name cap32`.
