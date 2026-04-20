extends Enemy

@onready var ray_cast_2d: RayCast2D = $Pivot/RayCast2D


func _physics_process(delta: float) -> void:
	var move_input = sign(pivot.scale.x)
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	move_and_slide()
	
	if  ray_cast_2d.is_colliding():
		pivot.scale.x *= -1
