# Lección 01: Ejercicios

Para cada ejercicio, copia `hola.asm` a `practicas\` con el nombre `ej01` + letra del ejercicio (`ej01a.asm`, `ej01b.asm`...) y cambia también el nombre en la línea `save`: `save "ej01a.bin",inicio,fin-inicio,DSK,"build/ej01a.dsk"`.

Pruébalo con `probar practicas\ej01a.asm`.

## Ejercicio A: Tu mensaje
Cambia el texto por el que quieras.

## Ejercicio B: Varias líneas
Haz que el mensaje ocupe dos líneas. Pista: en el CPC, el salto de línea son dos caracteres de control: 13 (volver al principio de la línea) y 10 (bajar una línea). En `db` puedes mezclar textos y números separados por comas: `db "Hola",13,10,"Adios",0`.

## Ejercicio C: Volver al BASIC en lugar de reiniciar
Cambia `rst 0` por `ret`. Ahora no lo ejecutes con `probar`. Abre el emulador con `ejecutar`, que lo lanzará con RUN: observa qué pasa. Después escribe en el BASIC del CPC:
```
memory &3fff
load"ej01c.bin"
call &4000
```
¿Qué diferencia hay? Pista: `call` de BASIC funciona igual que `call` del Z80.

Extra: prueba sin la línea `memory &3fff`. ¿Qué error sale? ¿Por qué crees que hace falta?

## Ejercicio D: Pensar (sin código)
1. Si `mensaje` estuviera en la dirección `#4012`, ¿qué valor tendría HL justo después de imprimir la "P"?
2. ¿Qué pasaría si olvidaras el `0` del final del `db`?

Cuando los tengas, dímelo y los revisamos juntos.
