// Renderiza los clips de src/clips.js a salida/, con el rol, el BPM y los compases en el nombre.
//
//   node renderizar.mjs                       todos, para la pantalla de psicoRoom (2048 × 1024, 60 fps, 40 Mbps)
//   node renderizar.mjs LaMaquina             solo ese
//   node renderizar.mjs --perfil master4k     3840 × 1920, 60 fps, 80 Mbps
//
// La primera vez Remotion descarga su navegador. Para usar otro: REMOTION_CHROME=/ruta/al/navegador
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {bundle} from '@remotion/bundler';
import {renderMedia, selectComposition} from '@remotion/renderer';
import {CLIPS, PERFILES, nombreArchivo} from './src/clips.js';

const aqui = path.dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const iPerfil = args.indexOf('--perfil');
const perfil = iPerfil >= 0 ? args[iPerfil + 1] : 'psicoroom';
const ids = args.filter((a, i) => !a.startsWith('--') && !(iPerfil >= 0 && i === iPerfil + 1));
if (!PERFILES[perfil]) {
  console.error(`Perfil desconocido: ${perfil} (hay ${Object.keys(PERFILES).join(' y ')})`);
  process.exit(2);
}
const elegidos = CLIPS.filter((c) => !ids.length || ids.includes(c.id));
if (!elegidos.length) {
  console.error(`No hay ningún clip con ese nombre. Los que hay: ${CLIPS.map((c) => c.id).join(', ')}`);
  process.exit(2);
}

const browserExecutable = process.env.REMOTION_CHROME || null;
const serveUrl = await bundle({entryPoint: path.join(aqui, 'src/index.jsx')});
for (const c of elegidos) {
  const inputProps = {...c, perfil};
  const composition = await selectComposition({serveUrl, id: c.id, inputProps, browserExecutable});
  const archivo = nombreArchivo(c);
  await renderMedia({
    composition, serveUrl, inputProps, browserExecutable,
    codec: 'h264', pixelFormat: 'yuv420p', videoBitrate: PERFILES[perfil].bitrate,
    outputLocation: path.join(aqui, 'salida', archivo),
    onProgress: ({progress}) => process.stdout.write(`\r${c.id}: ${Math.round(progress * 100)} %   `),
  });
  console.log(`\rListo: salida/${archivo} (${composition.durationInFrames} cuadros a ${composition.fps} fps)`);
}
