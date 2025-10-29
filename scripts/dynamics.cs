
using Godot;
using System;

public class Dynamics : RefCounted
{
    [Export]
    public float Gravity = -9.8f;

    [Export]
    public float Friction = 0.5f;

    public override void _Process(float delta)
    {
        // Apply gravity and friction to all RigidBody nodes in the scene
        foreach (RigidBody body in GetTree().GetNodesInGroup("dynamic_bodies"))
        {
            Vector3 velocity = body.LinearVelocity;

            // Apply gravity
            velocity.y += Gravity * delta;

            // Apply friction
            velocity.x *= (1 - Friction * delta);
            velocity.z *= (1 - Friction * delta);

            body.LinearVelocity = velocity;
        }
    }
}