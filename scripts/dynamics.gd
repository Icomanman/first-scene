# 
class_name Dynamics
extends RefCounted

var friction: float = 0.1
var mass: float = 1.0
# 
var _density: float = 1.0
var _volume: float = 1.0

func _init() -> void:
    print("Dynamics initialized")

# methods
func bounce() -> Vector3:
    return Vector3.ZERO

# getters
func get_volume() -> float:
    return _volume

func get_density() -> float:
    return _density

# setters
func set_volume(value: float) -> void:
    _volume = value

func set_density(value: float) -> void:
    _density = value
