# Guion de loop: Perreo · LA MÁQUINA

| | |
|---|---|
| Rol | **Coro** (drop) |
| Archivo final | `coro_lamaquina_95bpm_2c.mp4` |
| BPM de producción | 95 (reguetón) |
| Compases | 2 (a 95 BPM = 5,05 s) |
| Mood | **Perreo** |
| Formato | 2048 × 1024, 60 fps, sin audio |
| Paleta | Fondo `#000000` · blanco `#ffffff` |
| Ruta | **El motor**, en vivo: mood Perreo + frase de impacto (`P`) + strobe. Como archivo (para Resolume o para tenerlo listo): **Remotion** |

## La idea en una frase

Golpe tipográfico callejero: cada tiempo es un portazo.

## Qué se ve

"LA MÁQUINA" en tipografía de brocha, blanca sobre negro, de lado a lado. Una palabra por tiempo con golpe de escala. En el último tiempo, whiteout con el logo en silueta negra.

## Rejilla

| Compás | Qué pasa | En el tiempo |
|---|---|---|
| 1 | LA · MÁQUINA · LA · MÁQUINA | Una palabra por tiempo, golpe que se asienta |
| 2 | Strobe blanco en negras (máximo 3 destellos por segundo) | Último tiempo: whiteout con el logo en silueta |

## En el motor

1. Mood **Perreo** (`M`).
2. En *Frases de impacto*, escribe `LA MÁQUINA` y elige "Una palabra por tiempo".
3. En el drop: `P` para la frase, mantener `S` para el strobe y `F` para el whiteout. O marca "Lanzar la siguiente frase en cada drop" y "Whiteout de 1 compás".

## Como archivo, con Remotion

Ya está programado en [`../remotion/`](../remotion/): una palabra por tiempo, strobe seguro en el compás 2 y whiteout con la frase en silueta en el último tiempo.

```bash
cd ../remotion && npm run render -- LaMaquina
# → salida/coro_lamaquina_95bpm_2c.mp4 (303 cuadros exactos a 60 fps)
```

Si lo grabas de otra forma, confórmalo como coro; el corte seco es parte del golpe:

```bash
bash conformar.sh grabacion_perreo.mp4 95 2 --rol coro --perfil psicoroom --hap --nombre lamaquina
```
