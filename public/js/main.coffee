class window.App

  INV_MAX_FPS = 1 / 100
  config =
    resolution: 100
    floor:
      width: 300
      height: 300
      color: 0x222222
    buildings:
      n: 400

  scale = (n) -> n * config.resolution

  deg2Rad = (deg) -> deg * (Math.PI / 180)

  setupThreeJS = ->
    @scene = new THREE.Scene()

    @camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 0.3, 10000
    @camera.position.set 0, scale(1), 0

    @renderer = new THREE.WebGLRenderer antialias: true
    @renderer.setPixelRatio window.devicePixelRatio
    @renderer.shadowMapEnabled = true
    document.body.appendChild @renderer.domElement

    @effect = new THREE.VREffect @renderer
    @effect.setSize window.innerWidth, window.innerHeight

    @controls = new THREE.VRControls @camera

    @manager = new WebVRManager @renderer, @effect, hideButton: false

  handleDeviceType = (callback) ->
    @manager.getHMD_().then (hmd) ->
      @isVR = if hmd? then true else false
      console.log 'Is'.green + if @isVR then ' ' else ' not '.red + 'VR'.green
      callback()
      setupSockets()
      if @isVR
        jQuery('#info-panel').hide()
      else
        setupKibo()
        initGUI() if DEBUG_MODE

  setupSockets = ->
    @socket = io()
    if @isVR
      window.setInterval =>
        lookAtVector = new THREE.Vector3(0,0, -1);
        lookAtVector.applyQuaternion(@camera.quaternion)
        @socket.emit 'camera', lookAtVector
      , 100
      @socket.on 'move', (direction) =>
        switch direction
          when 'forward'
            @rover.moveDirection.FORWARD = true
          when 'backward'
            @rover.moveDirection.BACKWARD = true
          when 'right'
            @rover.rotateOnAxis new THREE.Vector3(0, 1, 0), deg2Rad -1
          when 'left'
            @rover.rotateOnAxis new THREE.Vector3(0, 1, 0), deg2Rad 1
          when 'stop'
            @rover.moveDirection.FORWARD = @rover.moveDirection.BACKWARD = false
    else
      @socket.on 'camera', (vector) =>
        lookAt = new THREE.Vector3(vector.x, vector.y, vector.z).add(@camera.position)
        @camera.lookAt lookAt

  setupKibo = ->
    kibo = new Kibo()

    kibo.down 'i', =>
      @rover.moveDirection.FORWARD = true
      @socket.emit 'move', 'forward' unless @isVR
    kibo.down 'k', =>
      @rover.moveDirection.BACKWARD = true
      @socket.emit 'move', 'backward' unless @isVR

    kibo.up 'i', =>
      @rover.moveDirection.FORWARD = false
      @socket.emit 'move', 'stop' unless @isVR
    kibo.up 'k', =>
      @rover.moveDirection.BACKWARD = false
      @socket.emit 'move', 'stop' unless @isVR

    kibo.down 'j', =>
      @rover.rotateOnAxis new THREE.Vector3(0, 1, 0), deg2Rad 1
      @socket.emit 'move', 'left' unless @isVR
    kibo.down 'l', =>
      @rover.rotateOnAxis new THREE.Vector3(0, 1, 0), deg2Rad -1
      @socket.emit 'move', 'right' unless @isVR

  initGUI = ->
    gui = new dat.GUI()

    gui.add(window, 'CARDBOARD_DEBUG').name('Cardboard').onChange =>
      jQuery('canvas').remove()
      jQuery(@manager.button.button).remove()
      setupThreeJS()
      setupWorld()

    camera = gui.addFolder 'Camera'
    camera.add(@camera.position, 'y', scale(1), scale(30)).name 'Pos Y'

    camera.open()

  setupWorld = ->
    @floor = new App.Floor width: scale(config.floor.width), height: scale(config.floor.height), color: config.floor.color
    @scene.add @floor
    @scene.fog = @floor.getFog()

    spotLight = new THREE.SpotLight( 0xffffff, 4, scale(40) )
    @camera.add spotLight
    spotLight.position.set 0, scale(1), scale(2)
    spotLight.castShadow = true
    spotLight.shadowMapWidth = 1024
    spotLight.shadowMapHeight = 1024
    spotLight.shadowCameraNear = 500
    spotLight.shadowCameraFar = 4000
    spotLight.shadowCameraFov = 30
    spotLight.target = @camera

    @rover = new App.Rover
    @rover.position.set 0, scale(1), 0
    @rover.add @camera
    @scene.add @rover

    @map = [1..config.floor.width].map (row) -> [1..config.floor.height].map (col) -> new App.MapCell row, col, ' '
    XOFFSET = scale config.floor.width / 2
    ZOFFSET = scale config.floor.height / 2

    @buildings = [1..config.buildings.n].map ->
      y = Math.random() * 30 + 5
      building = new App.Box y: scale(y), color: 0x00FF00
      px = scale(Math.random() * config.floor.width) - XOFFSET
      pz = scale(Math.random() * config.floor.height) - ZOFFSET
      building.position.x = px
      building.position.z = pz
      @scene.add building
      console.log 'added building in', building.position if DEBUG_MODE

      px = Math.round (px + XOFFSET) / config.resolution
      pz = Math.round (pz + ZOFFSET) / config.resolution
      @map[px % config.floor.width][pz % config.floor.height] = new App.MapCell px, pz, 'X', building
      building

  mapCellFromPosition = (position, cell) ->
    cell = cell or new App.MapCell
    XOFFSET = scale config.floor.width / 2
    ZOFFSET = scale config.floor.height / 2
    mapRow = Math.round (position.x + XOFFSET) / config.resolution % config.floor.width
    mapCol = Math.round (position.z + ZOFFSET) / config.resolution % config.floor.height
    char = @map[mapRow][mapCol].char
    mesh = @map[mapRow][mapCol].mesh
    cell.set mapRow, mapCol, char, mesh

  moveOutside = (meshPosition, roverPosition) ->
    mw = config.floor.width
    md = config.floor.height
    mx = meshPosition.x - (mw * 0.5)
    mz = meshPosition.z - (md * 0.5)
    px = roverPosition.x
    pz = roverPosition.z
    if px > mx and px < mx + mw and pz > mz and pz < mz + md
      xOverlap = if px - mx < mw * 0.5 then px - mx else px - mx - mw
      zOverlap = if pz - mz < md * 0.5 then pz - mz else pz - mz - md
      if Math.abs(xOverlap) > Math.abs(zOverlap)
        roverPosition.x -= xOverlap
      else
        roverPosition.z -= zOverlap

  checkRoverCollision = ->
    cell = new App.MapCell
    @rover.collideFloor @floor.position.y
    mapCellFromPosition @rover.position, cell
    switch cell.char
      when ' '
        break
      when 'X'
        console.log 'found building!'.red.bold if DEBUG_MODE
        moveOutside cell.mesh.position, @rover.position

  draw = ->
    @manager.render @scene, @camera

  update = (delta) ->
    checkRoverCollision()
    @rover.update delta
    @controls.update() if @isVR

  setup: ->
    Console.attach()
    Console.styles.attach()
    Console.styles.register
      bold: 'font-weight: bold'
    console.log 'Starting...'.darkorange.bold if DEBUG_MODE

    setupThreeJS()
    handleDeviceType ->
      setupWorld()
      (animate = ->
        update INV_MAX_FPS
        draw()
        requestAnimationFrame animate)()

    # Handle window resizes
    onWindowResize = ->
      @camera.aspect = window.innerWidth / window.innerHeight
      @camera.updateProjectionMatrix()
      @effect.setSize window.innerWidth, window.innerHeight
    window.addEventListener 'resize', onWindowResize, false


window.onload = ->
  window.CARDBOARD_DEBUG = false
  new App().setup()
