# Registro de cambios

Qué cambió en cada commit, de lo más nuevo a lo más viejo. Cada entrada lleva el commit corto entre corchetes: con `git show <commit>` se ve el detalle.

## 2026-10-12

### Los cinco roles de un video y Remotion [sin publicar]
- **Roles**: cada video se hace para un momento (intro, groove, break, subida o coro), que se decide en el guion, da forma al prompt y va en el nombre del archivo. Ficha de cada rol con su plantilla de prompt en [`roles.md`](visuales/fabrica/roles.md); los guiones del show tienen ya su rol.
- `conformar.sh --rol`: toma entera, con o sin fundido según el rol, y el rol delante del nombre. `precoro` vale como `subida` y `drop` como `coro`.
- Motor: reconoce `precoro` como subida y `coro`, `chorus` o `estribillo` como drop.
- **Remotion** en [`visuales/fabrica/remotion/`](visuales/fabrica/remotion/): frases de impacto exactas al cuadro y al BPM (LA MÁQUINA, HOW DO YOU FEEL RIGHT NOW, PETER ROMO) con las tipografías del motor, strobe seguro y whiteout final; `npm run render` las deja nombradas por rol.

### Subidas y coros que encajan con la música [64a67ad]
- Clips de tipo **Subida**: recorren la subida entera, a cualquier número de compases y BPM, y su último cuadro cae justo en el drop. Entran así los archivos con `subida`, `build` o `riser` en el nombre.
- Al empezar una sección el clip entra desde su primer cuadro: el impacto del coro cae en el 1 del drop. `coro` y `chorus` en el nombre valen como `drop`.
- `conformar.sh --entero` encaja la toma completa en N compases sin recortar el final; `--luego` encadena varias tomas.
- Guía [`subida-y-coro.md`](visuales/fabrica/subida-y-coro.md): cómo escribir el prompt por compases (un bloque de 2 s por compás), con un ejemplo completo de Sacro.

### El proyecto pasa a ser parte de PRotocolive [1a25cfd]
- `PROTOCOLIVE.md`: los cuatro módulos de PRotocolive (Screen Mapper, Briefing Exprés, Cue Sheet y Playbook de momentos), qué hace ya el motor en cada uno, qué falta y en qué orden seguir.
- Los README presentan el motor y la fábrica como software de PRotocolive.

### Documentación y pantalla completa de la interfaz [7d43b59]
- **Pantalla completa de toda la interfaz** (botón arriba a la derecha o `Mayús` + `Enter`): la mesa de control ocupa la pantalla, el monitor crece y los ajustes se desplazan en su columna. `Enter` sigue poniendo a pantalla completa solo la salida.
- README en la raíz del repositorio y este registro de cambios.

### Blur y glitch de tensión [1a968f4]
- **Blur** que crece con la tensión, respira con cada tiempo y se limpia de golpe en el drop.
- **Glitch** con el redoble de la subida (aberración de color y franjas corridas); `G` para dispararlo a mano.
- Contador de cuadros por segundo de la salida en la cabecera.

### Tipografía propia [38fcac5]
- Cargar cualquier TTF, OTF, WOFF o WOFF2 (por ejemplo Pirulen) y usarla en las frases de impacto y en el texto de la capa 2. Se recuerda en el navegador y no se sube al repositorio.
- La silueta del whiteout usa las mismas tipografías también en la ventana de salida.

### El logo se aparta de los videos grandes [d61fed6]
- Cada clip elige el logo **encima**, **en la esquina** u **oculto**, con fundido suave. Los temas vienen con el logo oculto.
- `O` apaga o enciende el logo al instante.

### Fábrica de loops y show de psicoRoom [4dbb3f4]
- `conformar.sh`: cualquier video a N compases exactos de un BPM, con empalme invisible, perfiles `psicoroom` (2048 × 1024, 60 fps, 40 Mbps) y `master4k`, y copia HAP Q para Resolume.
- Guías y guiones de los bloques del show: Sacro, Bio-Hazard, Perreo (LA MÁQUINA) y logo PR en cromo.
- Motor: formato 2:1 para la pantalla de 6 × 3 m con zona segura de texto; moods Sacro, Bio-Hazard y Perreo con fondo negro absoluto; frases de impacto monumentales (`P`); whiteout de 1 tiempo o 1 compás en el drop con silueta negra; acabado cromo del logo; carga de logo SVG.

### Moods e invert [670d8dc]
- **Moods**: looks completos intercambiables con `M`. El primer motor quedó como mood **Líneas**; además, **Escenario** y **Pared LED**. Cada mood recuerda su paleta y sus paneles.
- Opción de pasar al siguiente mood en cada drop.
- **Invert** mientras se mantiene `I`.

### Temas amarrados al BPM y looks de escenario [1dfa0de]
- Clips de tipo **Tema**: videos largos que se lanzan en el 1 (`L`), alineados al último «Marcar el 1», con la velocidad y la posición amarradas al tempo; corrección de ±1 compás y vuelta al relleno al terminar.
- Loops con BPM también amarrados a la rejilla de compases.
- Fondos nuevos sacados de las referencias: partículas, haces de luz y lavado de color con el logo en silueta. Paneles LED verticales y texto con letras espaciadas. Paleta Arena (azul, blanco y rojo).

### Clips de video [8144e9f]
- Banco de clips desde carpeta, selector o arrastrar y soltar; asignación a secciones por nombre de archivo.
- Cortes al compás (cada 4, 8 o 16), acelerados en la subida; el clip siguiente queda preparado para que el drop corte sin retraso.
- Tinte con la paleta, velocidad según la sección y brillo con el kick.

### Motor visual propio [b1cf2d0]
- Un solo HTML que funciona sin internet: logo PR redibujado con su onda de kick animada y un fondo generativo, en dos capas.
- Narrativa por secciones (intro, groove, break, subida, drop) con subida automática, blackout antes del drop y drop con flash.
- Sincronía con Traktor por MIDI clock, tap tempo y «Marcar el 1»; detección de kick y modo auto de secciones por audio; mapeo MIDI con aprendizaje; ventana de salida para el proyector; strobe seguro.

## 2026-10-10

### Script de arranque de Pasión Quito [eb7d621]
- `scripts/bootstrap_pasion_quito.sh`: extrae, sanea e inicializa en un repositorio privado de GitHub el código de "Pasión Quito", con escaneo de secretos antes de publicar.
