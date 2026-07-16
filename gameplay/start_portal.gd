extends AnimatedSprite2D

@export var max_loops: int = 3
var finished_loops: int = 0

func _ready() -> void:
	animation_finished.connect(_on_loop_finished)
	play("default")
	
func _on_loop_finished() -> void:
	finished_loops += 1
	
	if finished_loops >= max_loops:
		queue_free()
		
	else:
		play("default")
