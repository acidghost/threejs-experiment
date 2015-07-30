path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    tmp: "#{rootPath}/.tmp"
    app:
      name: 'threejs-experiment'
    port: 3000
    db: 'mongodb://localhost/threejs-experiment-development'

  test:
    root: rootPath
    tmp: "#{rootPath}/.tmp"
    app:
      name: 'threejs-experiment'
    port: 3000
    db: 'mongodb://localhost/threejs-experiment-test'

  production:
    root: rootPath
    tmp: "#{rootPath}/.tmp"
    app:
      name: 'threejs-experiment'
    port: 3000
    db: 'mongodb://localhost/threejs-experiment-production'

module.exports = config[env]
