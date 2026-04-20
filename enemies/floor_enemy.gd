extends Enemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	var move_input = sign(pivot.scale.x)
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	move_and_slide()
	
	if is_on_floor() and not ray_cast_2d.is_colliding():
		pivot.scale.x *= -1
