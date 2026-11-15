; rsx.asm - Ejemplo de comandos RSX (|HOLA, |BORDE, |SUMA) para Amstrad CPC
;
; Un RSX ("Resident System eXtension") es un comando nuevo que BASIC reconoce
; cuando se escribe precedido de la barra vertical: |HOLA, |BORDE,5 ...
; Para crearlo hay que darle al firmware una "tabla de comandos" con:
;   - la dirección de una lista con los NOMBRES de los comandos
;   - un salto (JP) a la rutina de cada comando, en el mismo orden que los nombres
; y registrarla llamando a KL LOG EXT (#BCD1).
;
; Ensamblado con RASM (el del curso de ensamblador, en Amstrad_asm/tools/rasm):
;   rasm.exe rsx.asm -o rsx        -> genera rsx.bin (los bytes del DATA de rsx.bas)
; El cargador en BASIC (rsx.bas) copia esos bytes a #A000 y hace CALL #A000.

KL_LOG_EXT      equ #BCD1               ; registra una tabla de RSX
TXT_OUTPUT      equ #BB5A               ; escribe el carácter de A en pantalla
SCR_SET_BORDER  equ #BC38               ; color del borde: B y C = tinta (0-26)

                org #A000

; ---------------------------------------------------------------------------
; Instalación: CALL &A000 desde BASIC
; ---------------------------------------------------------------------------
inicio:
                ld hl,instalado         ; ¿ya lo habíamos registrado antes?
                ld a,(hl)
                or a
                ret nz                  ; sí: registrarlo dos veces encadenaría la tabla
                                        ; consigo misma y BASIC se colgaría buscando comandos
                inc (hl)                ; marcamos "instalado"
                ld bc,tabla             ; BC = dirección de la tabla de comandos
                ld hl,espacio           ; HL = 4 bytes de trabajo que usa el firmware
                jp KL_LOG_EXT           ; lo registra y vuelve a BASIC (JP = CALL + RET)

instalado:      db 0                    ; 0 = sin instalar, 1 = instalado
espacio:        defs 4                  ; el firmware enlaza aquí nuestra tabla con las demás

; ---------------------------------------------------------------------------
; Tabla de comandos
; ---------------------------------------------------------------------------
tabla:
                dw nombres              ; primero, dónde están los nombres
                jp hola                 ; 1er nombre -> 1er salto
                jp borde                ; 2º nombre  -> 2º salto
                jp suma                 ; 3er nombre -> 3er salto

; Cada nombre va en MAYÚSCULAS y su última letra lleva el bit 7 activado
; (+#80): así sabe el firmware dónde acaba. La directiva STR de RASM lo hace sola.
; Un 0 marca el final de la lista.
nombres:
                str "HOLA"              ; = "HOL", "A"+#80
                str "BORDE"
                str "SUMA"
                db 0

; ---------------------------------------------------------------------------
; Al entrar en un comando, el firmware nos deja:
;   A  = número de parámetros que se escribieron tras el nombre
;   IX = dirección de los parámetros; cada uno ocupa 2 bytes (16 bits),
;        y están al revés: (IX+0,IX+1) es el ÚLTIMO, (IX+2,IX+3) el penúltimo...
; Un número llega tal cual; una variable con @ (|SUMA,1,2,@r%) llega como
; la dirección en memoria de esa variable, para que podamos escribir en ella.
; ---------------------------------------------------------------------------

; |HOLA  -> escribe un saludo (sin parámetros)
hola:
                or a                    ; ¿A = 0 parámetros?
                jr nz,error
                ld hl,txt_hola
                jr imprime

; |BORDE,n  -> pone el borde de la tinta n (0-26)
borde:
                cp 1                    ; ¿exactamente 1 parámetro?
                jr nz,error
                ld b,(ix+0)             ; byte bajo del parámetro = n
                ld c,b                  ; B y C iguales: color fijo (si no, parpadea)
                jp SCR_SET_BORDER

; |SUMA,a,b,@r%  -> r% = a + b
suma:
                cp 3                    ; ¿3 parámetros?
                jr nz,error
                ld l,(ix+4)             ; HL = a (el primero está al final)
                ld h,(ix+5)
                ld e,(ix+2)             ; DE = b
                ld d,(ix+3)
                add hl,de               ; HL = a + b
                ex de,hl                ; DE = resultado
                ld l,(ix+0)             ; HL = dirección de la variable r%
                ld h,(ix+1)
                ld (hl),e               ; un entero de BASIC son 2 bytes:
                inc hl                  ; primero el bajo...
                ld (hl),d               ; ...y luego el alto
                ret

; Si el número de parámetros no es el esperado
error:
                ld hl,txt_error
                ; (sigue en imprime)

; Escribe el texto apuntado por HL hasta encontrar un 0
imprime:
                ld a,(hl)
                or a
                ret z                   ; fin del texto: volvemos a BASIC
                call TXT_OUTPUT         ; TXT OUTPUT no toca ningún registro
                inc hl
                jr imprime

txt_hola:       db "Hola! Soy un comando RSX",13,10,0
txt_error:      db "RSX: parametros incorrectos",13,10,0

fin:

; Guarda solo los bytes del código (sin cabecera AMSDOS) para pasarlos a DATA
save "rsx.bin",inicio,fin-inicio
