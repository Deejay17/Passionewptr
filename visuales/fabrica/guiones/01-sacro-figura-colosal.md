# Guion de loop: Sacro · Figura colosal

| | |
|---|---|
| Archivo final | `sacro_figura_100bpm_8c.mp4` |
| BPM de producción | 100 (momentos pop y vocales) |
| Compases | 8 (a 100 BPM = 19,2 s) |
| Tipo | Loop |
| Sección / mood | Intro, break y groove · **Sacro** |
| Formato | 2048 × 1024, 60 fps, sin audio |
| Paleta | Fondo `#000000` · oro de vela `#d4a24c` · blanco cálido `#fff0d0` |
| Ruta | IA generativa (imagen a video) |

## La idea en una frase

Una presencia sagrada del tamaño de un edificio que mira a la pista: respeto antes que susto.

## Qué se ve

Una figura monacal colosal, original: hábito y velo negros, **sin rostro visible** (solo sombra bajo el velo), de pie al fondo de una nave en ruinas. Escala monumental, a lo Anyma: la figura ocupa dos tercios del alto y se pierde en la niebla. Abajo, filas de velas góticas encendidas, la única fuente de luz. Todo lo demás, negro. Movimiento mínimo: la niebla avanza, las llamas tiemblan, la cámara se acerca muy despacio.

## Rejilla

| Compás | Qué pasa | En el tiempo |
|---|---|---|
| 1–2 | Solo velas y niebla; la figura se intuye | Las llamas laten en el 1 |
| 3–4 | La figura emerge de la niebla, contraluz dorado | Avance de cámara continuo |
| 5–6 | La figura completa, el velo se mueve como con viento | Destello de vela en el 1 de cada compás |
| 7–8 | La niebla vuelve a cubrirla hasta el estado del compás 1 | Para el empalme |

## Prompt (video con IA)

```
Colossal faceless nun silhouette, towering two thirds of the frame, black habit and veil,
face hidden in deep shadow, standing in a ruined gothic cathedral nave, rows of lit gothic
candles in the foreground as the only light source, golden rim light, thick low fog rolling
slowly, pure black background, monumental scale, slow dolly-in, cinematic, high contrast,
ultra wide 2:1 composition, subject centered
```

Evitar: rostro visible, personajes reconocibles de películas, texto, cielos o fondos claros, colores saturados.

Las tomas de IA duran 5–10 s: genera dos y únelas o pide una de 10 s y deja que el conformador la estire (×2).

## Conformar

```bash
bash conformar.sh toma_sacro.mp4 100 8 --perfil psicoroom --hap --nombre sacro_figura
```
