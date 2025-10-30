# CollisionHandler Component
class_name CollisionHandler
extends RefCounted


func handle_collision(_collision_hits: Array[KinematicCollision3D]) -> void:
    var _collider: CollisionObject3D
    for _collision in _collision_hits:
        _collider = _collision.get_collider()
        if _collider:
            print(_collider.name)
            # TODO

func on_collision(hits: Array[KinematicCollision3D]) -> void:
    handle_collision(hits)