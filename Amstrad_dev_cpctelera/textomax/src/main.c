//------------------------------------------------------------------------------
// textomax: más filas y más columnas de texto que las del firmware
//
// LA IDEA
// -------
// El firmware del CPC escribe con letras de 8x8 píxeles, y de ahí salen sus
// 20/40/80 columnas y sus 25 filas. Pero el hardware no sabe nada de letras:
// solo lee bytes de memoria y los convierte en píxeles. Si dibujamos nosotros
// las letras, podemos elegir su tamaño:
//
//   COLUMNAS = ancho en píxeles / ancho de la letra
//     Con letras de 4 píxeles de ancho (3 de dibujo + 1 de separación):
//       modo 1: 320 / 4 =  80 columnas (¡con 4 colores!)
//       modo 2: 640 / 4 = 160 columnas (768 / 4 = 192 con overscan)
//
//   FILAS: el CRTC agrupa las líneas de la pantalla en "filas de carácter" de
//   R9+1 líneas. Normalmente R9 = 7 -> filas de 8 líneas. Con R9 = 5 las filas
//   miden 6 líneas, justo lo que mide nuestra letra (5 de dibujo + 1 de
//   separación), así que caben más filas en el mismo espacio.
//
// LOS REGISTROS DEL CRTC QUE TOCAMOS
// ----------------------------------
//   Registro                          Normal  Config 1  Config 2 y 3
//   R1  ancho visible (palabras)        40      40        48  (overscan)
//   R2  posición sincronismo H          46      46        50
//   R4  filas totales - 1               38      51        51
//   R6  filas visibles                  25      33        42
//   R7  posición sincronismo V          30      40        45
//   R9  líneas por fila - 1              7       5         5
//   R12 dirección de inicio (alta)     &30     &2C       &2C
//
//   - R4: la imagen tiene que durar 312 líneas, como siempre (si no, el
//     monitor pierde la sincronización). Antes: 39 filas x 8 = 312. Ahora:
//     52 filas x 6 = 312 -> R4 = 51.
//   - R7: el sincronismo vertical se cuenta en filas. Antes iba en la línea
//     30 x 8 = 240; ahora 240 / 6 = 40 para que la imagen quede en el mismo sitio.
//
// LA MEMORIA: 32 KB
// -----------------
// Cada fila de texto gasta R1 "palabras" (2 bytes) del contador del CRTC:
//   config 1: 40 x 33 = 1320 palabras;  config 2/3: 48 x 42 = 2016 palabras.
// Un banco de 16 KB solo tiene 1024, así que, como en el proyecto overscan,
// usamos R12 = &2C: la pantalla empieza en &8000 y continúa en &C000. Con 32 KB
// caben 2048 palabras; por eso con overscan no pasamos de 42 filas (43 x 48 =
// 2064 ya no cabría).
// Como &A600-&BFFF es del firmware, lo apagamos y llevamos la pila a &8000.
//
// Las líneas de una fila siguen estando separadas &800 bytes (línea 0 en +&0000,
// línea 1 en +&0800...). Con filas de 6 líneas, las líneas 6 y 7 de cada bloque
// (+&3000 y +&3800) no se ven: es memoria que queda libre.
//
// TECLAS: 1, 2 y 3 cambian de configuración.
//------------------------------------------------------------------------------

#include <cpctelera.h>
#include "fuente.h"

#define LINEAS_LETRA 6

// Cómo se dibujan las letras en cada configuración.
#define T_MODO1      0   // modo 1: 1 byte = 4 píxeles = 1 letra, con color
#define T_MODO2ANCHO 1   // modo 2: cada píxel de la letra se dibuja doble (8x6)
#define T_MODO2FINO  2   // modo 2: 1 byte = 8 píxeles = 2 letras

typedef struct {
   u8 modo;       // modo de vídeo
   u8 r1, r2;     // ancho visible y sincronismo horizontal
   u8 r6, r7;     // filas visibles y sincronismo vertical
   u8 cols;       // columnas de texto
   u8 filas;      // filas de texto
   u8 tipo;       // T_MODO1, T_MODO2ANCHO o T_MODO2FINO
} Config;

const Config configs[3] = {
   { 1, 40, 46, 33, 40,  80, 33, T_MODO1      },
   { 2, 48, 50, 42, 45,  96, 42, T_MODO2ANCHO },
   { 2, 48, 50, 42, 45, 192, 42, T_MODO2FINO  },
};

// Tintas: 0 fondo, 1-3 letras (el modo 2 solo usa la 0 y la 1).
const u8 paleta[4] = { HW_BLUE, HW_BRIGHT_YELLOW, HW_BRIGHT_CYAN, HW_BRIGHT_RED };

// Para T_MODO2ANCHO: convierte 4 bits en 8 duplicando cada uno (abcd -> aabbccdd).
const u8 doble[16] = {
   0x00, 0x03, 0x0C, 0x0F, 0x30, 0x33, 0x3C, 0x3F,
   0xC0, 0xC3, 0xCC, 0xCF, 0xF0, 0xF3, 0xFC, 0xFF
};

// Configuración activa (CPCtelera no inicializa globales: se asigna en activa()).
const Config* cfg;

// Valor del contador del CRTC al empezar cada fila (fila x R1). Se calcula una
// vez en activa() para no multiplicar en cada letra (el Z80 no sabe multiplicar
// y la multiplicación por software es lenta).
u16 inicioFila[42];

//------------------------------------------------------------------------------
// Dirección del byte x de la línea 0 de la fila de texto "fila".
// Igual que dirPantalla() del proyecto overscan, pero contando en filas de
// texto: la línea l de esa fila está en (dirección + l * &800).
//------------------------------------------------------------------------------
u8* dirFila(u8 x, u8 fila) {
   u16 palabra = inicioFila[fila] + (x >> 1);   // contador del CRTC
   return (u8*)(0x8000
              + ((palabra >> 10) << 14)       // banco: 0 -> &8000, 1 -> &C000
              + ((palabra & 0x3FF) << 1)      // posición dentro del banco
              + (x & 1));                     // byte par/impar de la palabra
}

//------------------------------------------------------------------------------
// Dibuja la letra c en la columna col, fila fila, con la tinta color (1-3;
// solo cuenta en modo 1).
//------------------------------------------------------------------------------
void letra(u8 col, u8 fila, u8 c, u8 color) {
   const u8* g;
   u8* p;
   u8 l, nib, mascara;

   if (col >= cfg->cols || fila >= cfg->filas) return;
   if (c < 32 || c > 127) c = '?';
   g = fuente[c - 32];

   // En modo 2 fino caben dos letras por byte: la columna par va en la mitad
   // izquierda (bits 7-4) y la impar en la derecha (bits 3-0).
   p = dirFila(cfg->tipo == T_MODO2FINO ? col >> 1 : col, fila);

   // Por cada línea: nib = 3 bits de dibujo en los bits 3-1 (el bit 0 es la
   // separación). Pasamos a la línea siguiente de la fila sumando &800.
   // Hay un bucle por tipo, para no decidir el tipo 6 veces por letra.
   switch (cfg->tipo) {
      case T_MODO1:
         // En modo 1 el píxel n usa el bit 7-n (bit 0 de la tinta) y el bit
         // 3-n (bit 1 de la tinta). Copiamos nib en las dos mitades del byte
         // (nib * &11) y la máscara deja solo las que pide la tinta.
         mascara = ((color & 1) ? 0xF0 : 0) | ((color & 2) ? 0x0F : 0);
         for (l = 0; l < LINEAS_LETRA; ++l, p += 0x800) {
            nib = g[l] << 1;
            *p = ((nib << 4) | nib) & mascara;
         }
         break;
      case T_MODO2ANCHO:
         for (l = 0; l < LINEAS_LETRA; ++l, p += 0x800)
            *p = doble[g[l] << 1];
         break;
      default:   // T_MODO2FINO
         if (col & 1)
            for (l = 0; l < LINEAS_LETRA; ++l, p += 0x800)
               *p = (*p & 0xF0) | (g[l] << 1);
         else
            for (l = 0; l < LINEAS_LETRA; ++l, p += 0x800)
               *p = (*p & 0x0F) | (g[l] << 5);
   }
}

// Escribe una cadena; devuelve la columna siguiente al último carácter.
u8 imprime(u8 col, u8 fila, const char* s, u8 color) {
   while (*s) letra(col++, fila, *s++, color);
   return col;
}

// Escribe un número en decimal (sin ceros a la izquierda).
u8 imprimeNum(u8 col, u8 fila, u8 n, u8 color) {
   char buf[4];
   u8 i = 3;
   buf[3] = 0;
   do { buf[--i] = '0' + n % 10; n /= 10; } while (n);
   return imprime(col, fila, buf + i, color);
}

//------------------------------------------------------------------------------
// Contenido de la demo
//------------------------------------------------------------------------------
const char* const textos[] = {
   "Este texto NO lo escribe el firmware: lo dibuja nuestra propia rutina.",
   "Cada letra mide 4x6 pixeles: 3x5 de dibujo + 1 de separacion.",
   "COLUMNAS = ancho en pixeles / ancho de letra. Modo 1: 320/4 = 80.",
   "Modo 2: 640/4 = 160; con overscan (96 bytes) 768/4 = 192 columnas.",
   "FILAS: el CRTC agrupa las lineas en filas de R9+1 (normal R9=7, 8 lin.)",
   "Con R9=5 cada fila mide 6 lineas: caben mas filas en la pantalla.",
   "Para que la imagen dure 312 lineas: R4=51 (52 filas x 6 = 312).",
   "R6 = filas visibles; R7 = fila del sincronismo vertical.",
   "La pantalla ocupa 32 KB (&8000-&FFFF) gracias a R12=&2C.",
   "Por eso apagamos el firmware y movemos la pila a &8000.",
   "Las lineas 6 y 7 de cada bloque de &800 bytes no se ven.",
   "Pulsa 1, 2 o 3 para cambiar de configuracion.",
};
#define NTEXTOS (sizeof(textos) / sizeof(textos[0]))

void dibuja(u8 n) {
   u8 f, c, ch, color;

   // Fila 0: título y ayuda.
   c = imprime(0, 0, "TEXTOMAX  config ", 2);
   letra(c++, 0, '1' + n, 3);
   c = imprime(c, 0, ": modo ", 2);
   letra(c++, 0, '0' + cfg->modo, 3);
   c = imprime(c, 0, ", ", 2);
   c = imprimeNum(c, 0, cfg->cols, 3);
   c = imprime(c, 0, " x ", 2);
   c = imprimeNum(c, 0, cfg->filas, 3);
   imprime(c, 0, "   Teclas: 1=80x33  2=96x42  3=192x42", 1);

   // Filas 1 y 2: regla para contar columnas (decenas y unidades).
   for (c = 0; c < cfg->cols; c += 10) imprimeNum(c, 1, c, 3);
   for (c = 0; c < cfg->cols; ++c)     letra(c, 2, '0' + c % 10, 2);

   // Resto: número de fila (para contarlas), un texto y, hasta el final de la
   // fila, el juego de caracteres.
   for (f = 3; f < cfg->filas; ++f) {
      color = 1 + f % 3;
      if (f < 9) letra(0, f, '0', color);
      c = imprimeNum(f < 9 ? 1 : 0, f, f + 1, color) + 1;
      if (f - 3 < NTEXTOS) c = imprime(c, f, textos[f - 3], 1) + 1;
      ch = 33 + f;
      while (c < cfg->cols) {
         letra(c++, f, ch, color);
         if (++ch > 126) ch = 33;
      }
   }
}

//------------------------------------------------------------------------------
// Activa la configuración n: modo, CRTC, borrado y dibujo.
//------------------------------------------------------------------------------
void activa(u8 n) {
   u8 f;
   cfg = &configs[n];
   for (f = 0; f < cfg->filas; ++f) inicioFila[f] = (u16)f * cfg->r1;
   cpct_waitVSYNC();
   cpct_setVideoMode(cfg->modo);
   cpct_setCRTCReg(9,  LINEAS_LETRA - 1);
   cpct_setCRTCReg(4,  51);
   cpct_setCRTCReg(1,  cfg->r1);
   cpct_setCRTCReg(2,  cfg->r2);
   cpct_setCRTCReg(6,  cfg->r6);
   cpct_setCRTCReg(7,  cfg->r7);
   cpct_setCRTCReg(12, 0x2C);
   cpct_setCRTCReg(13, 0x00);
   cpct_memset((void*)0x8000, 0, 0x8000);
   dibuja(n);
}

void main(void) {
   u8 actual;

   cpct_disableFirmware();
   cpct_setStackLocation((void*)0x8000);
   cpct_setPalette(paleta, 4);
   cpct_setBorder(HW_BLACK);

   actual = 0;
   activa(actual);

   while (1) {
      cpct_scanKeyboard_f();
      if      (cpct_isKeyPressed(Key_1) && actual != 0) activa(actual = 0);
      else if (cpct_isKeyPressed(Key_2) && actual != 1) activa(actual = 1);
      else if (cpct_isKeyPressed(Key_3) && actual != 2) activa(actual = 2);
   }
}
