extends Node

@export var _char: CharacterBody3D
@export var _camera: Camera3D

var _input_dir: Vector2
var _move_dir: Vector3

func _process(_delta: float) -> void:
    _input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    _move_dir = (_camera.basis.x * Vector3(1, 0, 1)).normalized() * _input_dir.x
    _move_dir += (_camera.basis.z * Vector3(1, 0, 1)).normalized() * _input_dir.y
    _char.move(_move_dir)
