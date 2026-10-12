# PRotocolive

**PRotocolive** es el sistema operativo de escenario de Peter Romo: un centro de mando para el día del show, pensado para que 1 o 2 personas conviertan cualquier recinto en un show sensorial. Este repositorio guarda su parte de software; los riders y la matriz de tolerancia viven en la nota de PRotocolive (directorio de software: `Tecnologia Romo/PRotocolive/`).

## Los cuatro módulos y en qué punto están

| Módulo | Qué pide PRotocolive | Qué hay hoy | Qué falta |
|---|---|---|---|
| **1. Visual Auto-Scaler & Screen Mapper** | Adaptarse a cualquier pantalla LED (ultra-wide, 16:9, columnas, paneles laterales) a partir de su resolución y disposición, sin recortar ni deformar los textos | **Parcial.** El [motor](visuales/) tiene formato libre o 2:1 con anclaje al centro o arriba, zona segura para el texto y paneles verticales que imitan columnas. La [fábrica](visuales/fabrica/) entrega 2048 × 1024 (psicoRoom) y 3840 × 1920 | Escribir cualquier resolución y elegir la disposición; columnas con los huecos reales medidos; paneles laterales como salidas aparte; una vista del mapa para el técnico de la pantalla |
| **2. Briefing Exprés** (luces y FX) | Página ligera para el celular del técnico local: modo 1 penumbra y silueta lateral en los breaks, modo 2 máxima potencia en el drop, modo 3 niebla continua sin cegadoras frontales | **Nada todavía** | Todo el módulo |
| **3. Visual Cue Sheet & Timeline** | Mapa del set en tiempo real: Break Coreable → Build-up → Drop Físico | **Parcial.** Secciones intro, groove, break, subida y drop con su look; subida medida en compases con drop automático, blackout en el último tiempo y flash o whiteout en el drop; modo auto que reconoce break, subida y drop por el audio | Una lista de cues por canción preparada antes del show (mood, frase, clip y efecto de cada momento) y una vista de línea de tiempo |
| **4. Playbook de Momentos Virales** | 3 o 4 hitos programados al milímetro | **Piezas sueltas:** frases de impacto (`P`), whiteout con silueta, temas amarrados al BPM (`L`) y moods por bloque (`M`) | Guardar cada momento como una receta de un botón (mood + frase + tema + whiteout) y dispararla desde Traktor o la controladora |

## Los principios sensoriales, dentro del motor

| Principio de PRotocolive | Cómo lo hace el motor | Pendiente |
|---|---|---|
| **Shadow Crafting** (silueta en alto contraste) | Whiteout con la silueta negra del logo o la frase sobre blanco; fondo «lavado» con el logo en silueta | — |
| **Dinámica de blackout** (silencio visual y detonación) | Blackout en el último tiempo de la subida y flash o whiteout en el drop; `B` para apagar a mano; moods con negro absoluto | El break baja la energía pero no apaga la pantalla. Falta una opción de **break en penumbra** al 100 % |
| **Tipografía emocional** (letras gigantes para corear) | Frases de impacto monumentales, palabra a palabra o enteras, con tipografía propia (Pirulen) | Plantillas tipográficas para el álbum *Para mis ex* que se adapten a cada pantalla (depende del módulo 1) |
| **Audio somático** (vaciado y entrada del sub-grave) | Lo hace la mezcla; el motor lo sigue: la caída del sub-grave lo lleva al break y el kick marca el pulso | — |

## Orden propuesto

1. **Briefing Exprés**: es el único módulo en cero y el que más riesgo quita en un recinto ajeno (el técnico que dispara humo o luces a destiempo). Es una página aparte que se abre en el celular.
2. **Screen Mapper**: el primer paso de I+D de la nota y la base de las plantillas tipográficas del álbum.
3. **Playbook de momentos** y **cue sheet por canción**, dentro del motor.
