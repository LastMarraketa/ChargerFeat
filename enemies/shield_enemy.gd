extends Enemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	speed = 600
	health_component.died.connect(_on_enemy_died)

func _physics_process(delta: float) -> void:
	var move_input = sign(pivot.scale.x)
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	move_and_slide()
	
	if  ray_cast_2d.is_colliding():
		pivot.scale.x *= -1
		

func _on_enemy_died() -> void:
	queue_free()
	Debug.log("murió enemigo :D")
