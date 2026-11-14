# Rutinas del firmware vistas

Se llaman con `call dirección`. "Entrada" son los registros que hay que preparar; "Salida", lo que devuelve la rutina. Los registros que no aparecen como preservados pueden cambiar.

| Dirección | Nombre | Entrada | Salida | Lección |
|---|---|---|---|---|
| `#BB06` | KM WAIT CHAR: espera una tecla | — | A = código del carácter pulsado | 01 |
| `#BB5A` | TXT OUTPUT: imprime un carácter (o ejecuta un código de control, <32) | A = carácter | Preserva todos los registros | 01 |

## Direcciones especiales

| Dirección | Qué hay |
|---|---|
| `#0000` | Reinicio (`rst 0`) |
| `#4000` | Zona libre donde ponemos nuestros programas |
| `#C000`-`#FFFF` | Memoria de pantalla |

## Códigos de control útiles (con TXT OUTPUT)

| Código | Efecto |
|---|---|
| 10 | Bajar una línea |
| 13 | Volver al principio de la línea |

Referencia completa: *CPC 464/664/6128 Firmware Guide* (Soft 968), disponible en cpcwiki.eu.
