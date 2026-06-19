extends Enemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var shield_health: HealthComponent = $Shield/ShieldHealth
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D

func _ready() -> void:
	speed = 600
	health_component.died.connect(_on_enemy_died)
	shield_health.died.connect(_on_shield_died)
	sprite_2d.modulate = Color(0.2, 0.6, 1.0, 1.0)

func _physics_process(delta: float) -> void:
	var move_input = sign(pivot.scale.x)
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	move_and_slide()
	
	if  ray_cast_2d.is_colliding():
		pivot.scale.x *= -1
		

func _on_enemy_died() -> void:
	queue_free()
	Debug.log("murió enemigo :D")

func _on_shield_died() -> void:
	sprite_2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
