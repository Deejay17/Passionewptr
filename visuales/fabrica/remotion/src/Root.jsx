import {Composition} from 'remotion';
import {FraseImpacto} from './FraseImpacto.jsx';
import {CLIPS, PERFILES, duracionEnCuadros} from './clips.js';

// tamaño, cuadros por segundo y duración salen del perfil y de los compases al BPM del clip
const medidas = ({props}) => {
  const p = PERFILES[props.perfil] || PERFILES.psicoroom;
  return {width: p.width, height: p.height, fps: p.fps, durationInFrames: duracionEnCuadros(props.bpm, props.compases, p.fps)};
};

export const Root = () => (
  <>
    {CLIPS.map((c) => (
      <Composition
        key={c.id}
        id={c.id}
        component={FraseImpacto}
        defaultProps={{...c, perfil: 'psicoroom'}}
        width={2048}
        height={1024}
        fps={60}
        durationInFrames={duracionEnCuadros(c.bpm, c.compases, 60)}
        calculateMetadata={medidas}
      />
    ))}
  </>
);
