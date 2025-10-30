extends CharacterBody3D

const JUMP_VELOCITY: float = 5.0

@export var walk_speed: float = 10.0
@export var acc: float = walk_speed * 2.0
@export var dec: float = walk_speed * 2.5

var collsion_handler: CollisionHandler
var dynamics: Dynamics
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _collided: bool
var _collisions_arr: Array[KinematicCollision3D]
var _dir: Vector3
var _xz_velocity: Vector3

# var _target_rot: Vector3
# var _target_dist: float
# var _mouse_motion: InputEventMouseMotion
# var _pitch: float
# var _yaw: float

signal collision_event(Array)


func move(dir: Vector3) -> void:
    _dir = dir

func _get_collisions() -> Array[KinematicCollision3D]:
    var _collisions: Array[KinematicCollision3D] = []
    var _collision_count: int = get_slide_collision_count()
    for i in range(_collision_count):
        _collisions.append(get_slide_collision(i))
    return _collisions

# Built-in process function.

func _process(_delta: float) -> void:
    # arm logic
    # _mouse_motion = InputEventMouseMotion()
    pass

func _physics_process(delta: float) -> void:
    # Add the gravity.
    if not is_on_floor():
        # velocity += get_gravity() * delta
        velocity.y -= gravity * delta

    # Set horizontal velocity.
    _xz_velocity = Vector3(velocity.x, 0, velocity.z)

    # Handle jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Apply movement.(horizontal)
    if _dir:
        _xz_velocity = _xz_velocity.move_toward(_dir * walk_speed, delta * acc)
    else:
        _xz_velocity = _xz_velocity.move_toward(Vector3.ZERO, delta * dec)

    velocity.x = _xz_velocity.x
    velocity.z = _xz_velocity.z

    _collided = move_and_slide()
    if _collided:
        _collisions_arr = _get_collisions()
        emit_signal("collision_event", _collisions_arr)
    else:
        _collisions_arr = []

func _ready() -> void:
    collsion_handler = CollisionHandler.new()
    dynamics = Dynamics.new()
    _dir = Vector3.ZERO
    _xz_velocity = Vector3.ZERO
    # 
    collision_event.connect(collsion_handler.on_collision)
