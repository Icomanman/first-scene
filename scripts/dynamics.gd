# 
class_name Dynamics
extends RefCounted

var friction: float = 0.1
# 
var _density: float = 1.0
var _volume: float = 1.0

func _init() -> void:
    print("Dynamics initialized")

# helper: rotational contribution for a direction d (n or tangent)
func _rot_term(r: Vector3, d: Vector3, invI: float) -> float:
    # returns scalar d · ( (invI * (r x d)) x r )
    if invI == 0.0:
        return 0.0
    var tmp = r.cross(d) * invI
    return d.dot(tmp.cross(r))

# methods
# Primary collision response entry point.
# Parameters expected (common billiard-style collisions between two bodies):
# - pA: position of contact on body A (Vector3)
# - vA: linear velocity of body A (Vector3)
# - mA: mass of body A (float)
# - pB: position of contact on body B (Vector3)
# - vB: linear velocity of body B (Vector3)
# - mB: mass of body B (float)
# - normal: contact normal pointing from A to B (Vector3, normalized)
# - restitution: coefficient of restitution (0..1), higher -> more bouncy
# - mu: coefficient of friction (0..inf), affects tangential impulse
# Returns a Dictionary with impulse vectors to apply to A and B and
# the post-collision relative velocity along normal.
func bounce(pA: Vector3, vA: Vector3, mA: float, pB: Vector3, vB: Vector3, mB: float, normal: Vector3, restitution: float = 0.9, mu: float = 0.02) -> Dictionary:
    # guard: ensure normal is normalized
    var n = normal
    if n.length() == 0:
        n = (pB - pA).normalized()
    else:
        n = n.normalized()

    # relative velocity at contact (for pure translation bodies)
    var rv = vB - vA

    # relative velocity along the normal
    var vel_along_normal = rv.dot(n)

    # If velocities are separating, no impulse is needed
    if vel_along_normal > 0:
        return {
            "impulse_A": Vector3.ZERO,
            "impulse_B": Vector3.ZERO,
            "vel_along_normal_post": vel_along_normal
        }

    # compute effective mass for two-body linear collision along the normal
    # For pure translation, reduced mass = 1 / (1/mA + 1/mB)
    var inv_mA = 0.0
    var inv_mB = 0.0
    if mA > 0.0:
        inv_mA = 1.0 / mA
    if mB > 0.0:
        inv_mB = 1.0 / mB

    var reduced_mass = 0.0
    if inv_mA + inv_mB > 0.0:
        reduced_mass = 1.0 / (inv_mA + inv_mB)
    else:
        # both immovable? no impulse
        return {
            "impulse_A": Vector3.ZERO,
            "impulse_B": Vector3.ZERO,
            "vel_along_normal_post": vel_along_normal
        }

    # scalar impulse magnitude for normal (elastic/inelastic via restitution)
    var j = - (1.0 + clamp(restitution, 0.0, 1.0)) * vel_along_normal * reduced_mass

    # normal impulse vector (applied to B positive along n, to A negative)
    var impulse_n = j * n

    # now compute frictional (tangential) impulse using Coulomb model
    # tangential relative velocity
    var vt = rv - (vel_along_normal * n)
    var tangent = Vector3.ZERO
    var jt = 0.0
    if vt.length() > 0.0:
        tangent = vt.normalized()
        # magnitude of tangential impulse for sticking (idealized)
        # approximate using reduced mass too (pure translation)
        # try to remove tangential relative velocity (impulse to zero it)
        var jt_nominal = - vt.length() * reduced_mass
        # clamp by Coulomb friction: |jt| <= mu * |j|
        var max_jt = mu * abs(j)
        jt = clamp(jt_nominal, -max_jt, max_jt)
    
    var impulse_t = jt * tangent

    # total impulse applied to B is normal + tangential; A gets opposite
    var impulse_B = impulse_n + impulse_t
    var impulse_A = - impulse_B

    # compute post-collision relative normal velocity for reporting
    var vel_along_normal_post = (rv + impulse_B * inv_mB - impulse_A * inv_mA).dot(n)

    return {
        "impulse_A": impulse_A,
        "impulse_B": impulse_B,
        "vel_along_normal_post": vel_along_normal_post,
        "reduced_mass": reduced_mass,
        "restitution": restitution,
        "friction_impulse": impulse_t
    }


# Rotational collision response (adds spin/torque)
# Assumptions: both bodies are solid spheres (moment of inertia = 2/5 m r^2).
# API:
# - cA, vA, wA, mA, radA : center pos, linear vel, angular vel, mass, radius of A
# - cB, vB, wB, mB, radB : same for B
# - contact_point: point of contact in world coords
# - normal: contact normal (A -> B). If zero, computed from centers->contact.
# - restitution, mu: as in `bounce` (defaults chosen for billiard-like feel)
# Returns: dict with impulses and delta linear & angular velocities for both bodies.
func spin(cA: Vector3, vA: Vector3, wA: Vector3, mA: float, radA: float, cB: Vector3, vB: Vector3, wB: Vector3, mB: float, radB: float, contact_point: Vector3, normal: Vector3, restitution: float = 0.9, mu: float = 0.02) -> Dictionary:
    var n = normal
    if n.length() == 0:
        n = (cB - cA).normalized()
    else:
        n = n.normalized()

    var rA = contact_point - cA
    var rB = contact_point - cB

    # relative velocity at contact including rotational component
    var velA_contact = vA + wA.cross(rA)
    var velB_contact = vB + wB.cross(rB)
    var rv = velB_contact - velA_contact

    var vel_along_normal = rv.dot(n)
    if vel_along_normal > 0.0:
        return {
            "impulse_A": Vector3.ZERO,
            "impulse_B": Vector3.ZERO,
            "delta_vA": Vector3.ZERO,
            "delta_vB": Vector3.ZERO,
            "delta_wA": Vector3.ZERO,
            "delta_wB": Vector3.ZERO,
            "vel_along_normal_post": vel_along_normal
        }

    # inverse masses
    var inv_mA = 0.0
    var inv_mB = 0.0
    if mA > 0.0:
        inv_mA = 1.0 / mA
    if mB > 0.0:
        inv_mB = 1.0 / mB

    # inverse inertia for solid sphere: I = 2/5 m r^2 -> invI = 5/(2 m r^2)
    var invI_A = 0.0
    var invI_B = 0.0
    if mA > 0.0 and radA > 0.0:
        invI_A = 5.0 / (2.0 * mA * radA * radA)
    if mB > 0.0 and radB > 0.0:
        invI_B = 5.0 / (2.0 * mB * radB * radB)


    # effective mass (denominator) for normal
    var k_normal = inv_mA + inv_mB + _rot_term(rA, n, invI_A) + _rot_term(rB, n, invI_B)
    if k_normal == 0.0:
        return {
            "impulse_A": Vector3.ZERO,
            "impulse_B": Vector3.ZERO,
            "delta_vA": Vector3.ZERO,
            "delta_vB": Vector3.ZERO,
            "delta_wA": Vector3.ZERO,
            "delta_wB": Vector3.ZERO,
            "vel_along_normal_post": vel_along_normal
        }

    # normal impulse magnitude
    var j = - (1.0 + clamp(restitution, 0.0, 1.0)) * vel_along_normal / k_normal
    var impulse_n = j * n

    # friction (tangential) impulse using Coulomb with rotational terms
    var vt = rv - vel_along_normal * n
    var tangent = Vector3.ZERO
    var jt = 0.0
    var impulse_t = Vector3.ZERO
    if vt.length() > 0.0:
        tangent = vt.normalized()
        var k_t = inv_mA + inv_mB + _rot_term(rA, tangent, invI_A) + _rot_term(rB, tangent, invI_B)
        if k_t != 0.0:
            var jt_nom = - vt.dot(tangent) / k_t
            var max_jt = mu * abs(j)
            jt = clamp(jt_nom, -max_jt, max_jt)
            impulse_t = jt * tangent

    var total_impulse = impulse_n + impulse_t

    # linear changes
    var delta_vA = - total_impulse * inv_mA
    var delta_vB = total_impulse * inv_mB

    # angular changes: delta_w = invI * (r x impulse)
    var torqueA = rA.cross(-total_impulse)
    var torqueB = rB.cross(total_impulse)
    var delta_wA = Vector3.ZERO
    var delta_wB = Vector3.ZERO
    if invI_A != 0.0:
        delta_wA = torqueA * invI_A
    if invI_B != 0.0:
        delta_wB = torqueB * invI_B

    # compute post-collision normal velocity for reporting
    var vel_along_normal_post = (rv + delta_vB + delta_wB.cross(rB) - delta_vA - delta_wA.cross(rA)).dot(n)

    return {
        "impulse_A": - total_impulse,
        "impulse_B": total_impulse,
        "delta_vA": delta_vA,
        "delta_vB": delta_vB,
        "delta_wA": delta_wA,
        "delta_wB": delta_wB,
        "normal_j": j,
        "tangential_j": jt,
        "vel_along_normal_post": vel_along_normal_post
    }

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
