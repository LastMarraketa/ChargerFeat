extends Enemy

enum State {
	PATROL,
	CHASE
}

var state: State = State.PATROL
var player: Player = null

@onready var detection_area: Area2D = $DetectionArea
@onready var health_component: HealthComponent = $HealthComponent
@onready var time_to_kill_area_chasing_enemy: Area2D = $"time to kill area chasing enemy"

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	time_to_kill_area_chasing_enemy.body_exited.connect(_on_time_to_kill_chasing_enemy)
	health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if state == State.CHASE and is_instance_valid(player):
		var direction = sign(player.global_position.x - global_position.x)
		if direction != 0:
			pivot.scale.x = direction
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
	
	move_and_slide()
	update_animation()

func _on_time_to_kill_chasing_enemy(body: Node2D) -> void:
	if (body is Player) and ( body.is_dashing_to_kill == true ):
		queue_free() 


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		state = State.CHASE

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		state = State.PATROL

func _on_died() -> void:
	queue_free()
