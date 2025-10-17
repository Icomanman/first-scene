extends Node

@export var _char: CharacterBody3D
@export var _cam_arm: SpringArm3D

var _input_dir: Vector2
var _char_dir: Vector3

func _process(_delta: float) -> void:
    _input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    _char_dir = (_cam_arm.basis.x * Vector3(1, 0, 1)).normalized() * _input_dir.x
    _char_dir += (_cam_arm.basis.z * Vector3(1, 0, 1)).normalized() * _input_dir.y
    _char.move(_char_dir)
