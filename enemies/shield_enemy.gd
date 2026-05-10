extends Enemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D
@onready var shield_hitbox: CollisionShape2D = $HitboxComponent/CollisionShape2D
@onready var shield_sprite: Sprite2D = $HitboxComponent/Sprite2D

func _ready() -> void:
	speed = 600

func _physics_process(delta: float) -> void:
	var move_input = sign(pivot.scale.x)
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	move_and_slide()
	
	if  ray_cast_2d.is_colliding():
		pivot.scale.x *= -1
		
func _disable_shield():
	shield_hitbox.set_deferred("disabled", true)
	shield_sprite.set_deferred("modulate", Color(1.0, 1.0, 1.0, 0.0))
	Debug.log("Escudo deshabilitado")
