# Passionewptr

Software de **[PRotocolive](PROTOCOLIVE.md)**, el sistema operativo de escenario de Peter Romo: un motor de visuales en vivo hecho a medida (en lugar de Resolume) y la fábrica para producir los clips que lo alimentan. Además guarda un script de arranque para otro proyecto.

| Carpeta | Qué hay | Documentación |
|---|---|---|
| [`PROTOCOLIVE.md`](PROTOCOLIVE.md) | Los cuatro módulos de PRotocolive, qué hay hecho de cada uno y en qué orden seguir | — |
| [`visuales/`](visuales/) | **Motor Visual PR**: visuales en vivo sincronizados con el set (logo PR que late con el kick, moods, clips y temas amarrados al BPM, frases de impacto, pantalla 2:1) | [`visuales/README.md`](visuales/README.md) |
| [`visuales/fabrica/`](visuales/fabrica/) | **Fábrica de loops**: guiones de clips y `conformar.sh`, que deja cualquier video en N compases exactos de un BPM | [`visuales/fabrica/README.md`](visuales/fabrica/README.md) |
| [`scripts/`](scripts/) | Fuera de PRotocolive. `bootstrap_pasion_quito.sh`: extrae, sanea y publica en un repositorio privado de GitHub el código de "Pasión Quito" | Comentarios al principio del script |

## Empezar en 1 minuto

1. Descarga [`visuales/motor-visual-pr.html`](visuales/motor-visual-pr.html) y ábrelo en **Chrome**. No hay que instalar nada y funciona sin internet.
2. Pulsa **Pantalla completa** (arriba a la derecha) para usar toda la interfaz como mesa de control, o **Abrir ventana de salida** para mandar la imagen al proyector o a la pantalla LED.
3. Durante el set: `1`–`5` para las secciones (intro, groove, break, subida, drop), `Espacio` para marcar el 1 del compás y `M` para cambiar de mood.

La lista completa de teclas, la configuración con Traktor y cómo modificar cada parte está en [`visuales/README.md`](visuales/README.md).

## Cómo se documenta este proyecto

- **Un README por carpeta**: qué hace, cómo se usa y dónde tocar el código.
- **[`CHANGELOG.md`](CHANGELOG.md)**: qué cambió en cada commit, explicado para quien usa el motor.
- **Mensajes de commit**: un resumen en la primera línea y la lista de cambios debajo (`git log` para verlos).
- **Comentarios en el código**: en español, explican el porqué de cada bloque.

## Estado

Todo el trabajo está en la rama `claude/relaxed-bell-rk3cqg`; todavía no hay pull request.

Probado en un navegador sin pantalla (Chromium): sincronía con MIDI clock simulado, detección de kick y de secciones con una pista sintética, cortes de clip al compás, temas amarrados al BPM, moods, frases y efectos.

Falta probar con el equipo real:

- [ ] Traktor y la controladora (MIDI clock y eventos de los decks)
- [ ] La pantalla LED de 6 × 3 m y cómo mapea la entrada su procesador
- [ ] Clips MP4 (H.264) en Chrome; en las pruebas se usó WebM
- [ ] Cuadros por segundo con blur y glitch en el Mac del show (hay un contador en la cabecera)

Pendientes que dependen de otras personas o cuentas:

- [ ] Vector oficial del logo PR (para el trazado definitivo y el render 3D en cromo)
- [ ] Servicio para generar los clips (RunPod, Veo u otro)
- [ ] Revisar licencias: Pirulen (Typodermic) y los modelos o servicios de video
