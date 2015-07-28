path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app:
      name: 'threejs-experiment'
    port: 3000
    db: 'mongodb://localhost/threejs-experiment-development'

  test:
    root: rootPath
    app:
      name: 'threejs-experiment'
    port: 3000
    db: 'mongodb://localhost/threejs-experiment-test'

  production:
    root: rootPath
    app:
      name: 'threejs-experiment'
    port: 3000
    db: 'mongodb://localhost/threejs-experiment-production'

module.exports = config[env]
