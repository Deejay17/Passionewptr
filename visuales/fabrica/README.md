# Fábrica de loops

Cómo pasar de una idea a un clip que encaje solo en el motor (o en Resolume), sincronizado al BPM.

```
guion  →  producción (IA, 3D o grabación)  →  conformar.sh  →  motor / Resolume
```

1. **Guion.** Una ficha por clip con BPM, compases, sección, paleta y qué pasa en cada compás. Plantilla en [`guiones/plantilla.md`](guiones/plantilla.md); los del show del 31 de octubre están en [`guiones/`](guiones/).
2. **Producción.** Se genera el material por la ruta que mejor le vaya a cada clip (ver abajo). No hace falta que salga exacto: el siguiente paso lo encaja.
3. **Conformar.** `conformar.sh` lo deja en N compases exactos del BPM, con un empalme que no se nota, al tamaño de la pantalla y con el BPM en el nombre.
4. **Al motor.** Se arrastra la carpeta: los loops rotan por sección, los temas se amarran al tempo de la sesión y las subidas terminan justo en el drop.

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
