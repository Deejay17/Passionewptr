# Guion de loop: NOMBRE

| | |
|---|---|
| Archivo final | `seccion_nombre_120bpm_8c.mp4` |
| BPM de producción | 120 (el motor lo ajusta al BPM real de la sesión) |
| Compases | 8 (a 120 BPM = 16 s) |
| Tipo | Loop (rota por sección), Tema (se lanza en el 1 y suena entero) o Subida (recorre la subida y acaba en el drop) |
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

En inglés (los generadores lo entienden mejor), con un bloque de 2 s por compás. Detalles en [`../subida-y-coro.md`](../subida-y-coro.md).

```
Descripción general del plano, la luz y el fondo negro.
[00:00-00:02] compás 1
[00:02-00:04] compás 2
[00:04-00:06] compás 3
[00:06-00:08] compás 4
```

Evitar: texto incrustado, logos ajenos, fondos claros, cortes de cámara bruscos.

## Conformar

```bash
bash conformar.sh toma.mp4 120 8 --perfil psicoroom --hap --nombre seccion_nombre
# subida o coro: la toma entera encajada en los compases, y la segunda toma a continuación
bash conformar.sh toma1.mp4 120 8 --entero --luego toma2.mp4 --perfil psicoroom --nombre seccion_subida
```
