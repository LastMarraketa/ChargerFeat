extends Sprite2D

signal bounce

var direction: Vector2
var speed = 600

func _ready() -> void:
	direction = Vector2.from_angle(randf_range(0, 2 * PI))
	


func _process(delta: float) -> void:
	var half_size: Vector2 = get_rect().size * scale / 2
	if (position.x - half_size.x) <= 0 or (position.x + half_size.x) > get_viewport_rect().size.x:
		direction = direction.bounce(Vector2.RIGHT)
		_on_bounce()
	if (position.y - half_size.y) <= 0 or (position.y + half_size.y) > get_viewport_rect().size.y:
		direction = direction.bounce(Vector2.UP)
		_on_bounce()
	if position.x - half_size.x < 0:
		position.x = half_size.x
	if position.x + half_size.x > get_viewport_rect().size.x:
		position.x = get_viewport_rect().size.x - half_size.x
	if position.y - half_size.y < 0:
		position.y = half_size.y
	if position.y + half_size.y > get_viewport_rect().size.y:
		position.y = get_viewport_rect().size.y - half_size.y
	
	position += direction * speed * delta
	
	scale = scale.lerp(Vector2.ZERO, 0.0025)
	
	if scale.length_squared() < 0.001:
		queue_free()

func _on_bounce() -> void:
	bounce.emit()
