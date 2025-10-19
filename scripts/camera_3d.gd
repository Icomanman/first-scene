extends Camera3D

var pos: Vector3
var _dir: Vector3

func move(dir: Vector3) -> void:
    _dir = dir

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if _dir:
        position.x = - _dir.x
        position.y = _dir.y
        position.z = - _dir.z
