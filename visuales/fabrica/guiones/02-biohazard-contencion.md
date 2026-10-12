# Guion de loop: Bio-Hazard · Brecha de contención

| | |
|---|---|
| Archivo final | `drop_contencion_128bpm_4c.mp4` |
| BPM de producción | 128 (drops pesados) |
| Compases | 4 (a 128 BPM = 7,5 s, 450 cuadros exactos a 60 fps) |
| Tipo | Loop |
| Sección / mood | Drop · **Bio-Hazard** |
| Formato | 2048 × 1024, 60 fps, sin audio |
| Paleta | Fondo `#000000` · verde mutágeno `#39ff14` · alarma `#ff1a1a` |
| Ruta | IA generativa; el motor pone encima los códigos y las franjas de peligro |

## La idea en una frase

Algo enorme rompió la contención y viene hacia la pista.

## Qué se ve

Una criatura de contención original: gigante, piel quirúrgica con tubos y placas de metal, silueta pesada; se ve en contraluz verde, nunca del todo. Pasillo de laboratorio en ruinas, luz de emergencia roja que gira, vapor verde mutágeno a ras de suelo. Fondo negro dominante.

## Rejilla

| Compás | Qué pasa | En el tiempo |
|---|---|---|
| 1 | Pasillo vacío, luz roja girando | La luz de emergencia barre en cada tiempo |
| 2 | La silueta aparece al fondo, en contraluz verde | Paso de la criatura en el 1 y el 3 |
| 3 | Avanza hacia cámara; el vapor se abre | Golpe de luz roja en cada tiempo |
| 4 | Se funde en el vapor hasta el estado del compás 1 | Para el empalme |

## Prompt (video con IA)

```
Original giant bio-engineered creature, surgical skin with tubes and metal plates, heavy
silhouette backlit by toxic green light, walking slowly toward camera through a ruined
underground laboratory corridor, rotating red emergency light, green mutagen vapor at floor
level, pure black surroundings, horror, cinematic, high contrast, ultra wide 2:1 composition,
subject centered
```

Evitar: personajes reconocibles de videojuegos o películas, texto, armas, sangre explícita, fondos claros.

## Conformar

```bash
bash conformar.sh toma_bio.mp4 128 4 --perfil psicoroom --hap --nombre drop_contencion
```
