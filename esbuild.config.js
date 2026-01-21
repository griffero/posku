const esbuild = require('esbuild')
const vuePlugin = require('esbuild-plugin-vue3')

const watch = process.argv.includes('--watch')

const context = esbuild.context({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  format: 'esm',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  plugins: [vuePlugin()],
  loader: {
    '.js': 'jsx',
  },
  define: {
    __VUE_OPTIONS_API__: 'true',
    __VUE_PROD_DEVTOOLS__: 'false',
    __VUE_PROD_HYDRATION_MISMATCH_DETAILS__: 'false'
  }
})

if (watch) {
  context.then(ctx => {
    ctx.watch()
    console.log('Watching for changes...')
  })
} else {
  context.then(ctx => {
    ctx.rebuild()
    ctx.dispose()
    console.log('Build complete')
  })
}
