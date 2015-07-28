class App.Floor extends THREE.Mesh

  defaults =
    width: 2000
    height: 2000
    color: 0x9db3b5

  constructor: (opts) ->
    @opts = _.merge defaults, opts

    geo = new THREE.PlaneGeometry @opts.width, @opts.height, 40, 40
    mat = new THREE.MeshPhongMaterial color: @opts.color, overdraw: true
    super geo, mat
    @rotation.x = -0.5 * Math.PI
    @receiveShadow = true

  getFog: ->
    new THREE.FogExp2 @opts.color, 0.002
