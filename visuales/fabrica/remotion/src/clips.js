// Los clips que salen de Remotion. Cada uno lleva su rol, su BPM y sus compases: el nombre del
// archivo se arma con eso (coro_lamaquina_95bpm_2c.mp4) y el motor lo coloca solo.
//
// modo:      'palabras' = una palabra por tiempo · 'entera' = la frase entera, que late con cada tiempo
// strobeDesde: compás desde el que cada tiempo abre con un destello blanco (0 = nunca)
// whiteout:  el último tiempo se queda en blanco con la frase en silueta negra
// mood:      colores del bloque del show (perreo, sacro, biohazard)

export const CLIPS = [
  {id: 'LaMaquina', rol: 'coro', nombre: 'lamaquina', texto: 'LA MÁQUINA', bpm: 95, compases: 2,
    modo: 'palabras', fuente: 'monumental', mood: 'perreo', strobeDesde: 2, whiteout: true},
  {id: 'HowDoYouFeel', rol: 'break', nombre: 'howdoyoufeel', texto: 'HOW DO YOU FEEL RIGHT NOW', bpm: 128, compases: 4,
    modo: 'palabras', fuente: 'monumental', mood: 'sacro', strobeDesde: 0, whiteout: false},
  {id: 'PeterRomo', rol: 'coro', nombre: 'peterromo', texto: 'PETER ROMO', bpm: 128, compases: 4,
    modo: 'entera', fuente: 'monumental', mood: 'biohazard', strobeDesde: 4, whiteout: true},
];

export const PERFILES = {
  psicoroom: {width: 2048, height: 1024, fps: 60, bitrate: '40M'},
  master4k: {width: 3840, height: 1920, fps: 60, bitrate: '80M'},
};

export const MOODS = {
  perreo: {fondo: '#000000', texto: '#ffffff'},
  sacro: {fondo: '#000000', texto: '#fff0d0'},
  biohazard: {fondo: '#000000', texto: '#39ff14'},
};

// la rejilla: un tiempo dura fps × 60 / BPM cuadros (a 95 BPM y 60 fps, 37,89 cuadros)
export const cuadrosPorTiempo = (bpm, fps) => (fps * 60) / bpm;
export const duracionEnCuadros = (bpm, compases, fps) => Math.round(compases * 4 * cuadrosPorTiempo(bpm, fps));

const formato = (n) => String(Math.round(n * 1000) / 1000);
export const nombreArchivo = (c) => `${c.rol}_${c.nombre}_${formato(c.bpm)}bpm_${formato(c.compases)}c.mp4`;
