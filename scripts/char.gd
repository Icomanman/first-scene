extends CharacterBody3D

const JUMP_VELOCITY: float = 5.0

@export var _walk_speed: float = 15.0
@export var _acc: float = _walk_speed * 2.0
#@export var _decc: float = 4.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _dir: Vector3
var _xz_velocity: Vector3

func move(dir: Vector3) -> void:
    _dir = dir  

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
        _xz_velocity = _xz_velocity.move_toward(_dir * _walk_speed, delta * _acc)
    else:
        _xz_velocity = _xz_velocity.move_toward(Vector3.ZERO, delta * _acc)

    velocity.x = _xz_velocity.x
    velocity.z = _xz_velocity.z
    move_and_slide()
