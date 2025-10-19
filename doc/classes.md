## Classes
```mermaid
classDiagram
    Node <|-- Camera
    Node <|-- Character
    Node <|-- Player
    Node <|-- Registry
    Node <|-- SpringArm3D
    Player o-- Character
    Character o-- SpringArm3D
    SpringArm3D o-- Camera
    class Node {
    }
    class Player {
        +CharacterBody3D _char
        +SpringArm3D _cam_arm
        -_input_dir: Vector2
        -_char_dir: Vector3
    }
    class Camera {
        +Vector3 position
        +pan(): void
        +rotate(): void
        +zoom(): void
    }
    class Character {
        +SpringArm3D _cam_arm
        +string name
        +walk_speed: float
        +acc: float
        +dec: float

        -gravity: float
        -_dir: Vector3
        -_xz_velocity: Vector3

        +move(Vector3 dir): void
        +jump(): void
    }
    class SpringArm3D {
        +length: float
    }

    class Registry {
        +static instance: Registry
        +get_instance(): Registry
        +register_player(player: Player): void
        +get_player(): Player
    }
```