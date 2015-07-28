class App.Box extends THREE.Mesh

  material = geometry = undefined
  defaults =
    x: 100
    y: 100
    z: 100
    color: 0x000000
    wireframe: false
    wireframeLineWidth: 50

  constructor: (opts) ->
    opts = _.merge defaults, opts

    geometry = new THREE.BoxGeometry opts.x, opts.y, opts.z
    geometry.applyMatrix new THREE.Matrix4().makeTranslation(0, 0.5 * opts.y, 0)
    material = new THREE.MeshBasicMaterial color: opts.color, wireframe: opts.wireframe, wireframeLineWidth: opts.wireframeLineWidth
    super geometry, material
