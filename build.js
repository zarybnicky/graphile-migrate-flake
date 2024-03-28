const esbuild = require('esbuild');
const fs = require('node:fs');
const childProcess = require('node:child_process');

(async () => {
  await esbuild.build({
    entryPoints: ['./index.js'],
    external: ['fsevents'],
    bundle: true,
    platform: "node",
    outdir: './dist',
  })
})()
