# Ensamblador Z80 para Amstrad CPC

Curso práctico, paso a paso.

## Organización

| Carpeta / archivo | Contenido |
|---|---|
| `PROGRESO.md` | Temario y por dónde vamos |
| `lecciones\` | Una carpeta por lección: teoría (`README.md`), ejercicios y ejemplos `.asm` |
| `practicas\` | **Tu** código: soluciones a los ejercicios y experimentos |
| `referencia\` | Fichas de consulta que crecen con cada lección: instrucciones Z80, rutinas del firmware, glosario |
| `build\` | Discos `.dsk` generados (se puede borrar sin problema) |
| `tools\` | Ensamblador RASM y emulador Caprice32 (no versionados, ver abajo) |

## Instalar las herramientas

Los binarios no están en el repositorio. Tras clonar:

- **RASM 3.3.1**: copiar `rasm.exe` en `tools\rasm\`.
- **Caprice32 4.6.0** (Windows, portable): descomprimirlo en `tools\cap32\` (debe quedar `tools\cap32\cap32.exe` junto a su carpeta `rom\`). Copiar `cap32.cfg.tmpl` como `cap32.cfg` si no existe.

## Compilar y ejecutar

Desde esta carpeta:

```
compilar lecciones\01-primer-programa\hola.asm    -> genera build\hola.dsk
ejecutar lecciones\01-primer-programa\hola.asm    -> abre el emulador y lo ejecuta
probar   lecciones\01-primer-programa\hola.asm    -> las dos cosas seguidas
```

`probar` es lo más cómodo: si hay errores de compilación, los muestra y no abre el emulador. Si el emulador ya estaba abierto, lo cierra antes.

Cada `.asm` debe terminar con una línea así, usando el mismo nombre que el archivo (8 letras como máximo):

```
save "nombre.bin",inicio,fin-inicio,DSK,"build/nombre.dsk"
```

## Emulador (Caprice32)

- **F1**: menú de opciones. **F10**: salir.
- Desde el BASIC del CPC: `cat` lista el disco y `run"hola.bin` ejecuta el programa.
