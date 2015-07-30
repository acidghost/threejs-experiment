class App.Rover extends App.Box

  @SPEED = 200
  @RADIUS = 20
  defaults =
    x: 100
    y: 20
    z: 150
    color: 0x0000FF

  constructor: (opts) ->
    opts = _.merge defaults, opts
    super opts

    @rotation.order = 'YXZ'
    @_aggregateRotation = new THREE.Vector3
    # Public properties
    @cameraHeight = 150
    @constrainVerticalLook = true
    @inverseLook = new THREE.Vector3(-1, -1, -1)
    @mouseSensitivity = new THREE.Vector3(0.25, 0.25, 0.25)
    @velocity = new THREE.Vector3
    @acceleration = new THREE.Vector3(0, -150, 0)
    @ambientFriction = new THREE.Vector3(-10, 0, -10)
    @moveDirection =
      FORWARD: false
      BACKWARD: false

  update: do ->
    halfAccel = new THREE.Vector3
    scaledVelocity = new THREE.Vector3
    (delta) ->
      # Compute look vector
      r = @_aggregateRotation.multiply(@inverseLook).multiply(@mouseSensitivity).multiplyScalar(delta).add(@rotation)
      if @constrainVerticalLook
        r.x = Math.max(Math.PI * -0.5, Math.min(Math.PI * 0.5, r.x))
      # Thrust
      if @moveDirection.FORWARD
        @velocity.z -= Rover.SPEED
      if @moveDirection.BACKWARD
        @velocity.z += Rover.SPEED
      # Move
      halfAccel.copy(@acceleration).multiplyScalar delta * 0.5
      @velocity.add halfAccel
      squaredManhattanVelocity = @velocity.x * @velocity.x + @velocity.z * @velocity.z
      if squaredManhattanVelocity > Rover.SPEED * Rover.SPEED
        scalar = Rover.SPEED / Math.sqrt(squaredManhattanVelocity)
        @velocity.x *= scalar
        @velocity.z *= scalar
      scaledVelocity.copy(@velocity).multiplyScalar delta
      @translateX scaledVelocity.x
      @translateZ scaledVelocity.z
      @position.y += scaledVelocity.y
      @velocity.add halfAccel
      # Ambient forces
      @velocity.add scaledVelocity.multiply(@ambientFriction)
      # Look
      @rotation.set r.x, r.y, r.z
      @_aggregateRotation.set 0, 0, 0
      return

  rotate: (x, y, z) ->
    @_aggregateRotation.x += x
    @_aggregateRotation.y += y
    @_aggregateRotation.z += z
    return

  collideFloor: (floorY) ->
    if @position.y - (@cameraHeight) <= floorY and @position.y - (@cameraHeight * 0.5) > floorY
      @velocity.y = Math.max(0, @velocity.y)
      @position.y = @cameraHeight + floorY
      return true
    false
