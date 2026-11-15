10 ' rsx.bas - Cargador y demo de comandos RSX (|HOLA, |BORDE, |SUMA)
20 ' El codigo maquina (fuente en rsx.asm) se copia en &A000 y se registra con CALL &A000
30 MEMORY &9FFF: ' BASIC ya no usara la memoria desde &A000: queda para nosotros
40 IF PEEK(&A000)=&21 AND PEEK(&A010)=1 THEN 120: ' ya instalado (RUN repetido)
50 p=&A000: s=0
60 READ a$: IF a$="FIN" THEN 90
70 v=VAL("&"+a$): POKE p,v: s=s+v: p=p+1: GOTO 60
90 IF s<>15653 THEN PRINT "Error en las lineas DATA (suma";s;")": END
100 CALL &A000: ' registra los comandos con KL LOG EXT
110 ' --- Demo ---
120 MODE 1
130 |HOLA
140 PRINT
150 r%=0: |SUMA,1200,34,@r%
160 PRINT "|SUMA,1200,34,@r%  ->  r% =";r%
170 PRINT: PRINT "|BORDE,n cambia el color del borde"
180 FOR c=0 TO 26: |BORDE,c: FOR t=1 TO 150: NEXT t,c
190 |BORDE,1
200 PRINT: PRINT "Y si faltan parametros (|BORDE):"
210 |BORDE
220 PRINT: PRINT "Prueba tu:  |HOLA   |BORDE,6"
225 PRINT "            |SUMA,5,7,@r%:PRINT r%"
230 END
990 ' --- Codigo maquina generado con RASM a partir de rsx.asm ---
1000 DATA 21,10,A0,7E,B7,C0,34,01,15,A0,21,11
1010 DATA A0,C3,D1,BC,00,00,00,00,00,20,A0,C3
1020 DATA 2E,A0,C3,36,A0,C3,41,A0,48,4F,4C,C1
1030 DATA 42,4F,52,44,C5,53,55,4D,C1,00,B7,20
1040 DATA 2C,21,69,A0,18,2A,FE,01,20,23,DD,46
1050 DATA 00,48,C3,38,BC,FE,03,20,18,DD,6E,04
1060 DATA DD,66,05,DD,5E,02,DD,56,03,19,EB,DD
1070 DATA 6E,00,DD,66,01,73,23,72,C9,21,84,A0
1080 DATA 7E,B7,C8,CD,5A,BB,23,18,F7,48,6F,6C
1090 DATA 61,21,20,53,6F,79,20,75,6E,20,63,6F
1100 DATA 6D,61,6E,64,6F,20,52,53,58,0D,0A,00
1110 DATA 52,53,58,3A,20,70,61,72,61,6D,65,74
1120 DATA 72,6F,73,20,69,6E,63,6F,72,72,65,63
1130 DATA 74,6F,73,0D,0A,00
2000 DATA FIN
