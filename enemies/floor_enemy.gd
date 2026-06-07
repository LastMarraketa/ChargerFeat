extends Enemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	health_component.died.connect(_on_enemy_died)
	speed = 500
	acceleration = 2000

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	var move_input = sign(pivot.scale.x)
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	move_and_slide()
	
	if is_on_floor() and not ray_cast_2d.is_colliding():
		pivot.scale.x *= -1

func _on_enemy_died() -> void:
	queue_free()
	Debug.log("murió enemigo :D")
