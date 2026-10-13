# Fábrica de loops

Cómo pasar de una idea a un clip que encaje solo en el motor (o en Resolume), sincronizado al BPM.

```
guion  →  producción (IA, 3D o grabación)  →  conformar.sh  →  motor / Resolume
```

1. **Guion.** Una ficha por clip con BPM, compases, sección, paleta y qué pasa en cada compás. Plantilla en [`guiones/plantilla.md`](guiones/plantilla.md); los del show del 31 de octubre están en [`guiones/`](guiones/).
2. **Producción.** Se genera el material por la ruta que mejor le vaya a cada clip (ver abajo). No hace falta que salga exacto: el siguiente paso lo encaja.
3. **Conformar.** `conformar.sh` lo deja en N compases exactos del BPM, con un empalme que no se nota, al tamaño de la pantalla y con el BPM en el nombre.
4. **Al motor.** Se arrastra la carpeta: los loops rotan por sección, los temas se amarran al tempo de la sesión y las subidas terminan justo en el drop.

**[Lector de pistas](lector-de-pistas.html)**: ábrelo en Chrome y arrastra una canción. Lee el BPM, el 1 y las secciones (intro, groove, break, subida y drop), y te da los videos que hay que pedir para esa canción, con su prompt, su nombre y el número de tomas de 8 s. Así solo se generan las tomas que el motor va a usar. Las secciones se corrigen a mano si hace falta y todo se rehace solo; la canción no sale de tu ordenador.

Qué lee de la música, sin IA:

- **El espectro** en 24 bandas, en el mapa de la canción, y por sección la **densidad** (cuánto del espectro suena a la vez) y el **brillo**.
- **La tonalidad** (con su número en la rueda Camelot), contando el bajo.
- **El groove**: dónde caen el bombo, la caja y los platillos en las 16 semicorcheas del compás, como en una caja de ritmos, y qué patrón es (dembow, bombo en cada tiempo, backbeat, medio tiempo) y si tiene swing.
- **El coro por repetición**: en las canciones donde la energía casi no cambia (reggaetón, pop), busca la frase de 8 compases que más se repite y más fuerte suena.

Y lo que interpreta Claude: pegas **la letra** (si trae tiempos `[01:23.45]`, cada línea cae en su sección) y con *Interpretar con Claude* te dice de qué trata la canción, cómo cambia del verso al coro, qué mood le va, qué se ve en cada video y las frases de impacto para la pantalla. Funciona en el enlace de claude.ai (la primera vez pide permiso); en el archivo sin internet, *Copiar para Claude* te da el texto para pegarlo en un chat y luego pegas la respuesta.

**Base de prompt** con el testigo del ritmo (un puntito que destella en cada tiempo) y la luz del momentum, para que el motor encaje el clip solo: [`base-de-prompt.md`](base-de-prompt.md).

**Cada video tiene un rol** (intro, groove, break, subida o coro) que se decide en el guion, da forma al prompt y va en el nombre del archivo: [`roles.md`](roles.md). Para que el video se emocione en el coro (prompt por compases, tomas encadenadas, subida que cierra en el drop): [`subida-y-coro.md`](subida-y-coro.md).

## Especificaciones del show (psicoRoom, 31 de octubre)

| | |
|---|---|
| Pantalla | 6 × 3 m, relación **2:1** |
| Resolución | **2048 × 1024** (master 3840 × 1920) |
| Cuadros | **60 fps** |
| Códec | MP4 H.264 a 40 Mbps para el motor; **HAP Q** o **DXV3** para Resolume |
| Fondo | **Negro absoluto `#000000`**: la luz la ponen los objetos, las siluetas y los destellos |
| Texto | Dentro de la **franja central del 50 %** de alto |

## Conformar

Requiere ffmpeg (en Mac: `brew install ffmpeg`).

```bash
# 8 compases a 128 BPM para la pantalla del show, más una copia HAP Q para Resolume
bash conformar.sh humo_monja.mp4 128 8 --perfil psicoroom --hap --nombre sacro_monja
# → sacro_monja_128bpm_8c.mp4  y  sacro_monja_128bpm_8c.mov
```

- Si el video es más largo, se usa el trozo que digas con `--desde SEGUNDOS`.
- Si es más corto (lo normal en video con IA: 5–10 s), se ralentiza interpolando cuadros hasta cubrir los compases. Más de ×3 se nota; mejor pedir una toma más larga o menos compases.
- **`--entero`**: no recorta nada; estira o encoge la toma completa hasta los compases exactos, para que cada bloque del guion caiga en su compás. Es el modo de las subidas y los coros.
- **`--luego TOMA`**: pega otra toma a continuación (se puede repetir). Así una subida de 8 compases sale de dos tomas de 8 s.
- **`--rol intro|groove|break|subida|coro`**: hace lo que toca para cada rol (toma entera, con o sin fundido) y pone el rol delante del nombre.
- **`--marcas 0.62:1,4.40:9`**: en el segundo 0,62 cae el golpe 1 (el momentum) y en el 4,40 el golpe 9; los previos van en negativo (`0:-8` = ocho tiempos antes del momentum). El video se estira o se encoge tramo a tramo para que cada golpe caiga en su sitio y empieza en el momentum. Las marcas se ponen viendo el video en **Golpes** del motor, que da la línea ya escrita.
- **`--tapar id`**: tapa con negro el testigo del ritmo en esa esquina (`si`, `sd`, `ii` o `id`), la misma caja que tapa el motor.
- El empalme funde el final con el principio durante 1 tiempo (`--fundido`). En las pruebas, el salto en el empalme quedó igual que entre dos cuadros normales; con un corte seco era 79 veces mayor.
- A 60 fps, los loops de 4 u 8 compases a 128 BPM o cualquier número de compases a 120 BPM caen en cuadros exactos.
- **DXV3**: ffmpeg no lo genera. Pasa el MP4 por **Resolume Alley** (gratis, viene con Resolume). HAP Q, que también va fino en Resolume, sí sale directo con `--hap`.

## Rutas de producción

| Ruta | Para qué | Ventajas | Pegas |
|---|---|---|---|
| **IA generativa** (texto o imagen a video) | Atmósferas y personajes: la figura colosal, la criatura, humo, velas | Rápida, cinematográfica | Pago por segundo, tomas cortas (5–10 s), resultado variable, revisar licencia comercial del servicio |
| **3D por script** (Blender en una GPU en la nube) | El logo en cromo negro, tipografía 3D, monolitos | Exacto al BPM por construcción, loops perfectos, control total | Necesita el **vector oficial** del logo; coste de GPU por hora |
| **Código** ([Remotion](remotion/)) | Frases de impacto, whiteouts, tipografía y, con el vector, el logo | Exacto al cuadro y al BPM sin conformar, mismas tipografías que el motor, gratis en tu Mac | Solo gráficos: no hace cine |
| **Generativo propio** (este motor) | Partículas, haces, códigos, frases de impacto, whiteouts | Ya funciona en vivo, gratis, se adapta solo | Estética 2D; para Resolume habría que grabarlo a archivo |
| **Grabación** | Humo, fuego, manos, texturas reales | Textura real | Producción física |

Lo práctico para el 31: **IA generativa** para los personajes y atmósferas de cada bloque, **el motor** para la tipografía, los whiteouts y el relleno, **Remotion** para tener esas frases y whiteouts también como archivos (para Resolume o de respaldo), y **3D** para el logo cromo cuando llegue el vector.

## Personajes con dueño

La Monja y Némesis son personajes de franquicias (*The Conjuring* y *Resident Evil*). Para un evento con entrada, mejor no reproducirlos tal cual. Los guiones piden figuras **originales con la misma energía** (una figura monacal colosal sin rostro, una criatura de contención propia), que además serán tuyas.
