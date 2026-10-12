# Guion de loop: NOMBRE

| | |
|---|---|
| Archivo final | `seccion_nombre_120bpm_8c.mp4` |
| BPM de producción | 120 (el motor lo ajusta al BPM real de la sesión) |
| Compases | 8 (a 120 BPM = 16 s) |
| Tipo | Loop (rota por sección) o Tema (se lanza en el 1 y suena entero) |
| Sección / mood | Groove · Escenario |
| Formato | 2048 × 1024, 60 fps, sin audio |
| Paleta | Fondo `#000000` · base · tensión · acento |
| Ruta | IA generativa / 3D por script / motor / grabación |

## La idea en una frase

Qué tiene que sentir la gente cuando aparece.

## Qué se ve

Plano, cámara, sujeto, luz, textura. Dónde está el negro (la pantalla no puede iluminar la sala).

## Rejilla

| Compás | Qué pasa | En el tiempo |
|---|---|---|
| 1–2 | | |
| 3–4 | | |
| 5–6 | | |
| 7–8 | Vuelve al estado del compás 1 para que el loop empalme | |

## Prompt (video con IA)

```
(en inglés: los generadores lo entienden mejor)
```

Evitar: texto incrustado, logos ajenos, fondos claros, cortes de cámara bruscos.

## Conformar

```bash
bash conformar.sh toma.mp4 120 8 --perfil psicoroom --hap --nombre seccion_nombre
```
