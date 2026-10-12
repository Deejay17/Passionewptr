# Subida y coro: que el video se emocione en el momento justo

Los cinco roles (intro, groove, break, subida y coro), con la plantilla de prompt de cada uno, están en [`roles.md`](roles.md). Aquí va el porqué y el ejemplo completo de la subida y el coro.

Ningún generador de video entiende de BPM ni clava un golpe de medio segundo. Por eso el trabajo se reparte en tres:

| Quién | Pone | Precisión |
|---|---|---|
| **El video** | La emoción: qué se ve y cómo crece | Por compases (bloques de unos 2 s) |
| **El corte** | La sorpresa: el coro entra como un clip nuevo en el 1 del drop, con flash o whiteout | Al cuadro, lo hace el motor |
| **El motor** | El ritmo de cada tiempo: kick, redoble, strobe, glitch, blackout del último tiempo | Al tiempo, lo hace el motor |

Así que el prompt no se escribe por cuadros ni con el código de tiempo de la canción, sino **por compases**. El motor y `conformar.sh` se encargan de que esos compases caigan en los de la música.

## Lo que sí entiende un generador

- **Orden y tiempos aproximados.** Veo acepta bloques con tiempo dentro del prompt (`[00:00-00:02] …`). Los respeta más o menos (medio segundo de desvío es normal): sirve para marcar compases, no tiempos.
- **Primer y último fotograma.** Veo 3.1 (y Kling, Runway o Luma) pueden arrancar o terminar en una imagen que tú les das. Es la herramienta para encadenar tomas y para que la subida y el coro sean coherentes.
- **Tomas de 4 a 8 s.** Una subida más larga se hace con varias tomas seguidas, cada una arrancando del último fotograma de la anterior.

## La regla: un bloque de 2 s por compás

Escribe la toma de 8 s en **4 bloques de 2 s**, uno por compás:

```
[00:00-00:02] compás 1
[00:02-00:04] compás 2
[00:04-00:06] compás 3
[00:06-00:08] compás 4
```

Después, `conformar.sh --rol` (o `--entero`) estira o encoge la toma entera hasta los compases exactos del BPM real, sin recortar el final: lo que el prompt pone en el segundo 4 cae al empezar el compás 3. A 128 BPM, 4 compases son 7,5 s, así que la toma se acelera un 6 %, y no se nota.

Para 90–100 BPM (Perreo a 95, Sacro a 100) una toma de 8 s son **3 compases**: bloques `[00:00-00:03]`, `[00:03-00:05]`, `[00:05-00:08]`.

Cuánto dura cada cosa (compases × 240 ÷ BPM):

| BPM | 4 compases | 8 compases | 16 compases |
|---|---|---|---|
| 95 | 10,1 s | 20,2 s | 40,4 s |
| 100 | 9,6 s | 19,2 s | 38,4 s |
| 120 | 8 s | 16 s | 32 s |
| 126 | 7,6 s | 15,2 s | 30,5 s |
| 128 | 7,5 s | 15 s | 30 s |

Genera tomas que sumen más o menos eso; `conformar.sh` te dice cuánto cambia la velocidad y avisa si se pasa.

## La subida

Un clip de tipo **Subida** recorre la subida entera en el motor y su último cuadro cae justo en el drop. Su línea de tiempo se reparte a lo largo de los compases de la subida, sean 4, 8 o 16, y a cualquier BPM. Entran así los archivos con `subida`, `build` o `riser` en el nombre.

Qué pedir en cada tramo:

| Tramo | Qué pedir |
|---|---|
| Primer cuarto | Calma tensa: plano abierto, casi quieto, una sola fuente de luz |
| Segundo cuarto | Algo empieza a moverse: la cámara avanza, suben partículas, sopla viento |
| Tercer cuarto | Aceleración: cámara más rápida, la luz parpadea |
| Último cuarto | Carrera final hacia el sujeto y la imagen **satura a blanco** (o se funde a negro) |

El final en blanco o en negro no es estético, es técnico: el motor apaga la pantalla en el último tiempo y la enciende con flash o whiteout en el 1 del drop. El empalme queda tapado, y el medio segundo que el generador se desvía desaparece ahí.

Además, sobre el clip el motor sigue haciendo lo suyo: el blur respira con cada tiempo, el glitch entra con el redoble y el strobe en la segunda mitad.

## El coro (el drop)

Un clip con `coro` o `drop` en el nombre se usa en el drop. Queda preparado en su **primer cuadro** durante la subida y entra en el 1 sin retraso. Por eso su primer compás es el impacto:

- **Sorpresa (recomendado).** El coro abre con lo contrario de lo que cerró la subida: si la subida terminó en un primer plano oscuro que se quema a blanco, el coro abre en plano general, con la figura entera y la luz a tope. Es la ruptura de patrón de PRotocolive.
- **Continuidad.** Si quieres que la explosión salga de la misma imagen, usa el último fotograma de la subida como primer fotograma del coro.

Hazlo de 8 compases: el compás 1 es el impacto y vuelve cada 8 compases, como la frase del coro.

## Ejemplo completo: Sacro a 128 BPM, subida de 8 compases

**Toma 1** (compases 1–4):

```
Ultra wide 2:1 cinematic shot, pure black background. A colossal faceless nun silhouette
far away in a ruined gothic nave, lit only by rows of candles.
[00:00-00:02] Almost still, thin fog, candle flames trembling.
[00:02-00:04] A slow dolly-in begins, the fog starts rising.
[00:04-00:06] The candles flare brighter, the veil starts moving in a rising wind.
[00:06-00:08] The dolly-in accelerates, dust and embers swirling upward.
```

**Toma 2** (compases 5–8), con el último fotograma de la toma 1 como primer fotograma:

```
Continue the same shot.
[00:00-00:02] Fast push toward the figure, embers rushing past the camera.
[00:02-00:04] The light flickers violently, the silhouette fills half the frame.
[00:04-00:06] Extreme rush forward, golden light blooming from behind the figure.
[00:06-00:08] The whole frame overexposes to pure white.
```

**Coro** (8 compases, dos tomas igual que arriba; la primera abre así):

```
Ultra wide 2:1 cinematic shot, pure black background.
[00:00-00:02] Impact: the colossal nun revealed in full, towering, backlit by a blinding
white beam, a burst of embers exploding outward.
[00:02-00:04] The beam sweeps slowly, embers drift down like snow.
[00:04-00:06] Slow orbit around the figure, candles rising from the floor.
[00:06-00:08] The figure stands still, golden haze pulsing.
```

**Conformar:**

```bash
bash conformar.sh toma1.mp4 128 8 --rol subida --luego toma2.mp4 --perfil psicoroom --nombre sacro
bash conformar.sh coro1.mp4 128 8 --rol coro --luego coro2.mp4 --perfil psicoroom --nombre sacro
# → sacro_subida_128bpm_8c.mp4 (tipo Subida)  y  sacro_coro_128bpm_8c.mp4 (loop del drop)
```

Los dos usan la toma entera para que cada bloque caiga en su compás. Sin fundido, el coro vuelve a su primer cuadro cada 8 compases con un corte seco: un nuevo impacto al empezar la frase.

En el motor: pon la subida en **8 compases**, arrastra los dos archivos y lanza la subida (`4`) en el 1 de la subida de la canción. El resto va solo.

## La otra vía: al cuadro y con tu audio

Si algún día hace falta que cada kick mueva la imagen dentro del propio video, hay modelos abiertos que lo permiten:

- **ComfyUI** con Wan o AnimateDiff, o **Deforum**, en una GPU alquilada (RunPod) aceptan una programación cuadro a cuadro y pueden leer el audio de la canción (por stems).
- **Neural Frames** hace lo mismo como servicio, sin montar un servidor.

Es más trabajo y más caro, y tiene sentido para una pieza única, como el himno del álbum. Para el show, la combinación de arriba (video por compases, corte y motor) da la precisión que hace falta.
