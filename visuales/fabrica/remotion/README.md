# Clips por código (Remotion)

[Remotion](https://www.remotion.dev) arma videos con código: cada cuadro se calcula a partir del BPM, así que el clip sale **exacto al cuadro y al compás** sin pasar por `conformar.sh`. Es la ruta para todo lo gráfico del show: frases de impacto, whiteouts, tipografía y, cuando llegue el vector, el logo. Para cine (figuras, humo, criaturas) sigue siendo mejor la IA generativa.

Usa las mismas tipografías y colores que el motor, y nombra cada archivo con su rol, su BPM y sus compases (`coro_lamaquina_95bpm_2c.mp4`), así que el motor lo coloca solo.

## Instalar (una vez, en el Mac)

Hace falta Node 18 o más nuevo (`brew install node`).

```bash
cd visuales/fabrica/remotion
npm install
```

## Ver y retocar

```bash
npm run estudio
```

Se abre en el navegador con todos los clips. Se reproducen a su tempo y en el panel de la derecha se cambian el texto, el BPM, los compases, el mood y los efectos para probar.

## Renderizar

```bash
npm run render                          # todos, para psicoRoom: 2048 × 1024, 60 fps, 40 Mbps
npm run render -- LaMaquina             # solo uno
npm run render -- --perfil master4k     # 3840 × 1920, 60 fps, 80 Mbps
```

Los archivos quedan en `salida/` (no se suben al repositorio). Para Resolume, pásalos por Alley para tenerlos en DXV3. La primera vez Remotion descarga su navegador; en las pruebas, 2 compases a 2048 × 1024 y 60 fps tardaron unos 30 s.

## Los clips

Están en [`src/clips.js`](src/clips.js), uno por línea:

| Clip | Rol | Qué hace |
|---|---|---|
| `LaMaquina` | Coro, 95 BPM, 2 compases | LA · MÁQUINA, una palabra por tiempo; strobe en el compás 2 y whiteout con la frase en silueta en el último tiempo |
| `HowDoYouFeel` | Break, 128 BPM, 4 compases | HOW DO YOU FEEL RIGHT NOW, una palabra por tiempo, en blanco cálido (Sacro) |
| `PeterRomo` | Coro, 128 BPM, 4 compases | PETER ROMO entera, latiendo con cada tiempo, en verde Bio-Hazard; strobe en el compás 4 y whiteout final |

Para uno nuevo, copia una línea y cambia:

| Campo | Qué es |
|---|---|
| `rol` | `intro`, `groove`, `break`, `subida` o `coro` |
| `texto`, `bpm`, `compases` | La frase y su rejilla |
| `modo` | `palabras` (una por tiempo) o `entera` (la frase entera, que late) |
| `fuente` | `monumental`, `brocha` o `propia` |
| `mood` | `perreo` (blanco), `sacro` (blanco cálido) o `biohazard` (verde) |
| `strobeDesde` | Compás desde el que cada tiempo abre con un destello (0 = nunca; nunca más de 3 por segundo) |
| `whiteout` | El último tiempo en blanco con la frase en silueta negra |

**Tu tipografía** (Pirulen u otra): cópiala como `public/fuentes/propia.otf` y pon `fuente: 'propia'`. No se sube al repositorio.

## Dónde tocar

| Qué | Dónde |
|---|---|
| Los clips y sus colores | `src/clips.js` |
| Cómo se dibuja cada cuadro (golpe, strobe, whiteout) | `src/FraseImpacto.jsx` |
| Tamaños, cuadros por segundo y bitrate | `PERFILES` en `src/clips.js` |
| El render por lotes | `renderizar.mjs` |

## Licencias

- **Remotion** es gratis para personas y para empresas de hasta 3 personas; por encima pide licencia de empresa. Las condiciones están en [remotion.dev/license](https://www.remotion.dev/license).
- Las tipografías de `public/fuentes/` son las del motor: **Big Shoulders Display** (OFL) y **Permanent Marker** (Apache 2.0), libres para uso comercial.
