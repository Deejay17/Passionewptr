# Los cinco roles de un video

Cada video se hace para **un** momento del set. El rol se decide en el guion, manda en el prompt y queda en el nombre del archivo. El motor lo lee del nombre y sabe qué hacer con él, sin tocar nada a mano.

```
guion (rol)  →  prompt con la forma del rol  →  conformar.sh --rol  →  rol_nombre_128bpm_8c.mp4  →  motor
```

## La tabla

| Rol | Momento del tema | Qué hace el motor con él | Largo | Cómo empieza y termina |
|---|---|---|---|---|
| **Intro** | Los primeros compases | Loop. Entra desde su primer cuadro y el logo se dibuja encima durante 4 compases | 4–8 compases | Empieza casi en negro y algo aparece. Termina como empezó, para empalmar |
| **Groove** | El cuerpo del tema, energía estable | Loop que se turna con los otros grooves cada 4, 8 o 16 compases | 4 compases | Movimiento constante, sin clímax: cualquier compás vale como entrada |
| **Break** (break coreable) | Se va el bajo, queda la voz | Loop lento; el motor baja la energía y deja sitio a la letra | 4–8 compases | Casi quieto, mucho negro, una sola luz. **El centro, vacío** para la frase |
| **Subida** (precoro, build-up) | La tensión hacia el coro | Una sola pasada: se estira a lo que dure la subida y su momentum (el blanco final) cae en el drop | Lo mismo que la subida (8) | Empieza en calma, acelera y termina **saturando a blanco** o fundiendo a negro |
| **Coro** (drop físico) | La explosión | Loop que entra en el 1 del drop **desde su primer cuadro**, con flash o whiteout | 8 compases (o 4) | El compás 1 es el **impacto**; los demás sostienen la energía y vuelve al impacto cada 8 |

Aparte están los **temas**: un video para una canción entera, de principio a fin. No es un rol; se lanza con `L` en el 1 de la canción.

## Lo que comparten todos

- Fondo **negro absoluto** y formato **2:1** (2048 × 1024). La luz la ponen el sujeto, las siluetas y los destellos.
- Sin texto incrustado, sin logos ajenos, sin cortes de cámara y sin personajes con dueño.
- Prompt en inglés, con **un bloque de 2 s por compás** (por qué y cómo, en [`subida-y-coro.md`](subida-y-coro.md)).
- Una toma de 8 s son **4 compases a 120–130 BPM** y **3 compases a 90–100 BPM**. Para 8 compases, dos tomas seguidas (la segunda desde el último fotograma de la primera).

## El prompt de cada rol

Primero la [base de prompt](base-de-prompt.md) (el testigo del ritmo y la luz del momentum), luego una línea con el plano, el sujeto y la luz, y después los bloques. El grupo **Prompt para video** del motor arma todo esto solo, con los colores del mood, y te da el nombre del archivo.

**Intro**: aparecer.

```
[00:00-00:02] Pure darkness, a faint glow barely visible.
[00:02-00:04] The light slowly reveals the shape of <sujeto>.
[00:04-00:06] <sujeto> fully visible, fog drifting slowly.
[00:06-00:08] The light dims back toward darkness.
```

**Groove**: moverse sin llegar a ningún sitio.

```
[00:00-00:08] Continuous steady motion: <movimiento>, constant speed, no climax,
the last moment matches the first, seamless loop.
```

**Break**: respirar.

```
[00:00-00:08] Almost still, deep black, a single soft side light, slow fog,
<sujeto> small and to one side, empty space in the center of the frame.
```

**Subida**: acelerar hacia la luz.

```
[00:00-00:02] Calm and almost still, a single light source.
[00:02-00:04] The camera starts moving forward, particles rising.
[00:04-00:06] Faster, the light flickers, wind.
[00:06-00:08] Rushing toward <sujeto>, the frame overexposes to pure white.
```

**Coro**: golpear y sostener.

```
[00:00-00:02] Impact: <sujeto> revealed in full, blinding backlight, a burst outward.
[00:02-00:04] <movimiento amplio y lento>
[00:04-00:06] <movimiento amplio y lento>
[00:06-00:08] Sustained energy, ready to hit again.
```

## Conformar con el rol

`--rol` hace lo que toca para cada uno y pone el rol delante del nombre:

```bash
bash conformar.sh toma.mp4 128 4 --rol groove --perfil psicoroom --nombre bio_pasillo
bash conformar.sh toma1.mp4 128 8 --rol subida --luego toma2.mp4 --perfil psicoroom --nombre sacro
bash conformar.sh coro1.mp4 128 8 --rol coro --luego coro2.mp4 --perfil psicoroom --nombre sacro
# → groove_bio_pasillo_128bpm_4c.mp4 · subida_sacro_128bpm_8c.mp4 · coro_sacro_128bpm_8c.mp4
```

| Rol | Qué hace `conformar.sh` |
|---|---|
| Intro, groove, break | Usa la toma entera y funde el final con el principio durante 1 tiempo |
| Subida | Usa la toma entera, sin fundido: una sola pasada |
| Coro | Usa la toma entera, con corte seco: vuelve al impacto al repetirse |

`precoro` vale como `subida` y `drop` como `coro`. Si el nombre ya lleva el rol (`drop_contencion`), no se repite.

## Si el golpe no cae donde debía

Un generador nunca clava el tiempo: el impacto del coro puede caer en el segundo 0,6 y no en el 0. No hace falta regenerar: en el motor, **Golpes** marca en qué cuadro cae el momentum y los demás golpes (o los encuentra solo con **Detectar por la luz**, si el prompt llevaba la base), y el clip se ajusta solo (detalles en el [README del motor](../README.md#marcar-los-golpes-de-un-video-el-warp)). Para que el archivo ya salga corregido, la misma información va a `conformar.sh --marcas`.

## En el motor

Arrastra la carpeta y listo: cada video va a su sección por el nombre. En la lista de clips se ve y se puede cambiar (tipo Loop o Subida, botones I G B S D).

Si tus videos ya vienen con su color, desmarca **Teñir con la paleta** en *Clips*: si no, el motor los pasa a blanco y negro y los colorea con la paleta del mood.
