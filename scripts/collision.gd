# CollisionHandler Component
class_name CollisionHandler
extends RefCounted


# ***************
# member methods
# ***************
func on_collision(char_obj: CharEntity, hits: Array[KinematicCollision3D]) -> void:
    var _valid_collsions: Array[KinematicCollision3D] = []
    var body = char_obj.dynamics.body
    print("Collision detected for: %s" % body.name)
    for hit in hits:
        if hit:
            var collider = hit.get_collider()
            print("Collision with: %s" % collider.name)
            if collider == body:
                print(" - Ignored self-collision.")
            else:
                print(" - Valid collision.")
            _valid_collsions.append(hit)
    # handle_collision(hits)


func handle_collision(_collision_hits: Array[KinematicCollision3D]) -> void:
    var _collider: CollisionObject3D
    for _collision in _collision_hits:
        _collider = _collision.get_collider()
        if _collider:
            print(_collider.name)
            # TODO