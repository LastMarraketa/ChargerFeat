extends CharacterBody2D


@export var move_speed = 120.0
@export var accel = 8.0
@export var patrol_radius = 60.0
@export var patrol_speed = 50.0

enum State {PATROL, CHASE}
var state: State = State.PATROL

var player: Node2D = null
var patrol_origin: Vector2
var patrol_target: Vector2

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detect_area: Area2D = $DetectionArea
@onready var pivot: Node2D = $Pivot
@onready var sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox: HitboxComponent = $HitboxComponent

func _ready() -> void:
	patrol_origin = global_position
	_pick_patrol_target()
	
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 16.0
	
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)
	
	health_component.died.connect(_on_enemy_died)
	sprite.play("default")
	
func _physics_process(delta: float) -> void:
	match state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
			
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _do_patrol(delta: float) -> void:
	nav_agent.target_position = patrol_target
	
	if nav_agent.is_navigation_finished():
		_pick_patrol_target()
		return
		
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_pos - global_position).normalized()
	velocity = velocity.lerp(direction * patrol_speed, accel * delta)
	move_and_slide()
	
func _pick_patrol_target() -> void:
	var angle: float = randf_range(0.0, TAU)
	var radius: float = randf_range(patrol_radius * 0.3, patrol_radius)
	patrol_target = patrol_origin + Vector2(cos(angle), sin(angle)) * radius
	
func _do_chase(delta: float) -> void:
	if not is_instance_valid(player):
		_enter_patrol()
		return
		
	nav_agent.target_position = player.global_position
	
	if nav_agent.is_navigation_finished():
		return
		
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_pos - global_position).normalized()
	velocity = velocity.lerp(direction * move_speed, accel * delta)
	move_and_slide()
	
func _enter_chase(target: Node2D) -> void:
	player = target
	state = State.CHASE
	
func _enter_patrol() -> void:
	player = null
	state = State.PATROL
	patrol_origin = global_position
	_pick_patrol_target()
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_enter_chase(body)
	
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_enter_patrol()

func _on_enemy_died() -> void:
	queue_free()
	Debug.log("murió enemigo :D")
