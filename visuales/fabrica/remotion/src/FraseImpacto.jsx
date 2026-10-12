import {useEffect, useLayoutEffect, useRef, useState} from 'react';
import {AbsoluteFill, Easing, cancelRender, continueRender, delayRender, interpolate, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {MOODS, cuadrosPorTiempo} from './clips.js';

// las mismas tipografías que el motor; «propia» es la tuya (por ejemplo Pirulen), que no se sube al repositorio
const FUENTES = {
  monumental: {familia: 'PR Monumental', archivo: 'fuentes/monumental.woff2', peso: 900},
  brocha: {familia: 'PR Brocha', archivo: 'fuentes/brocha.woff2', peso: 400},
  propia: {familia: 'PR Propia', archivo: 'fuentes/propia.otf', peso: 400},
};

function useFuente(clave) {
  const f = FUENTES[clave] || FUENTES.monumental;
  const [espera] = useState(() => delayRender('Cargando ' + f.familia));
  const [lista, setLista] = useState(false);
  useEffect(() => {
    const ff = new FontFace(f.familia, `url(${staticFile(f.archivo)})`, {weight: String(f.peso)});
    ff.load()
      .then(() => {document.fonts.add(ff); setLista(true);})
      .catch((e) => cancelRender(new Error(`No pude cargar public/${f.archivo}: ${e.message}`)));
  }, [f]);
  useEffect(() => {if (lista) continueRender(espera);}, [lista, espera]);   // después de dibujar el primer cuadro
  return lista ? f : null;
}

export const FraseImpacto = ({texto, bpm, compases, modo, fuente, mood, strobeDesde, whiteout}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const f = useFuente(fuente);
  const lienzo = useRef(null);

  useLayoutEffect(() => {
    if (!f) return;
    const ctx = lienzo.current.getContext('2d');
    const cpt = cuadrosPorTiempo(bpm, fps);
    const tiempo = Math.floor(frame / cpt + 1e-9);          // tiempo (negra) en el que estamos, desde 0
    const enTiempo = frame - tiempo * cpt;                  // cuadros desde que empezó ese tiempo
    const compas = Math.floor(tiempo / 4) + 1;
    const colores = MOODS[mood] || MOODS.perreo;
    const palabras = texto.trim().split(/\s+/);
    const visible = modo === 'palabras' ? palabras[tiempo % palabras.length] : texto;
    const blanco = whiteout && tiempo >= compases * 4 - 1;   // el último tiempo: whiteout con la frase en silueta
    // strobe seguro: como mucho 3 destellos por segundo
    const paso = Math.max(1, Math.ceil(bpm / 60 / 3));
    const destello = !blanco && strobeDesde > 0 && compas >= strobeDesde && tiempo % paso === 0
      ? interpolate(enTiempo, [0, 2, 6], [1, 1, 0], {extrapolateRight: 'clamp'}) : 0;
    // cada palabra entra con un golpe y se asienta; la frase entera late con cada tiempo
    const golpe = interpolate(enTiempo, [0, 8], [modo === 'palabras' ? 1.14 : 1.05, 1],
      {extrapolateRight: 'clamp', easing: Easing.out(Easing.cubic)});

    ctx.globalAlpha = 1;
    ctx.fillStyle = blanco ? '#ffffff' : colores.fondo;
    ctx.fillRect(0, 0, width, height);

    // de lado a lado, sin salirse de la franja central del 50 % de alto (la zona segura del motor)
    ctx.font = `${f.peso} 100px "${f.familia}"`;
    const m = ctx.measureText(visible);
    const tam = Math.min((0.86 * width) / m.width, (0.5 * height) / (m.actualBoundingBoxAscent + m.actualBoundingBoxDescent)) * 100 * golpe;
    ctx.font = `${f.peso} ${tam}px "${f.familia}"`;
    const mm = ctx.measureText(visible);
    ctx.textAlign = 'center';
    ctx.textBaseline = 'alphabetic';
    ctx.globalAlpha = blanco ? 1 : interpolate(enTiempo / cpt, [0, 1], [1, 0.8]);
    ctx.fillStyle = blanco ? '#000000' : colores.texto;
    ctx.fillText(visible, width / 2, height / 2 + (mm.actualBoundingBoxAscent - mm.actualBoundingBoxDescent) / 2);

    if (destello > 0) {
      ctx.globalAlpha = destello;
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(0, 0, width, height);
    }
  }, [f, frame, fps, width, height, texto, bpm, compases, modo, mood, strobeDesde, whiteout]);

  return (
    <AbsoluteFill style={{backgroundColor: '#000000'}}>
      <canvas ref={lienzo} width={width} height={height} style={{width: '100%', height: '100%'}} />
    </AbsoluteFill>
  );
};
