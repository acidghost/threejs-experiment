class window.App

  config =
    floor:
      width: 2000
      height: 2000
      color: 'whitesmoke'

  setupThreeJS = ->
    @scene = new THREE.Scene()

    @camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 1, 10000
    camera.position.y = 400
    camera.position.z = 400
    camera.rotation.x = -90 * Math.PI / 180

    @renderer = new THREE.WebGLRenderer antialias: true
    renderer.setSize window.innerWidth, window.innerHeight
    renderer.shadowMapEnabled = true
    document.body.appendChild @renderer.domElement

    @controls = new THREE.VRControls @camera

    @effect = new THREE.VREffect @renderer
    effect.setSize window.innerWidth, window.innerHeight

    @manager = new WebVRManager renderer, effect, hideButton: false

  setupWorld = ->
    @floor = new App.Floor config.floor
    scene.add floor
    scene.fog = floor.getFog()

    @buildings = [0..40].map ->
      x = Math.random() * 200 + 50
      y = Math.random() * 400 + 50
      building = new App.Box x: x, y: y, color: 'green'
      building.position.x = (Math.random() * config.floor.width) - (config.floor.width / 2)
      building.position.z = (Math.random() * config.floor.height) - (config.floor.height / 2)
      scene.add building
      console.log building.position
      building

  setupKibo = ->
    kibo = new Kibo()

  draw = ->
    @manager.render @scene, @camera

  update = ->
    @controls.update()

  setup: ->
    setupThreeJS()
    setupWorld()
    setupKibo()

    (animate = ->
      draw()
      update()
      requestAnimationFrame animate)()

    # Handle window resizes
    onWindowResize = ->
      camera.aspect = window.innerWidth / window.innerHeight
      camera.updateProjectionMatrix()
      @effect.setSize window.innerWidth, window.innerHeight
    window.addEventListener 'resize', onWindowResize, false


jQuery(document).ready ->
  new App().setup()
