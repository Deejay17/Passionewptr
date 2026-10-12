# Guion de loop: Perreo · LA MÁQUINA

| | |
|---|---|
| Archivo final | `drop_lamaquina_95bpm_2c.mp4` |
| BPM de producción | 95 (reguetón) |
| Compases | 2 (a 95 BPM = 5,05 s) |
| Tipo | Loop de impacto |
| Sección / mood | Drop · **Perreo** |
| Formato | 2048 × 1024, 60 fps, sin audio |
| Paleta | Fondo `#000000` · blanco `#ffffff` |
| Ruta | **El motor**, en vivo: mood Perreo + frase de impacto (`P`) + strobe. Para Resolume se graba a archivo |

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

## Conformar (si se graba para Resolume)

```bash
bash conformar.sh grabacion_perreo.mp4 95 2 --perfil psicoroom --hap --fundido 0 --nombre drop_lamaquina
```

`--fundido 0`: en un clip de impacto el corte seco es parte del golpe.
