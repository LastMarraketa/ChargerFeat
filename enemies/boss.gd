extends Enemy

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/idle/playback"]
@onready var detection_area: Area2D = $"Detection area"
@onready var fire_timer: Timer = $"fire timer"
@onready var spawn_timer: Timer = $"spawn timer"
@onready var bullet_spawn: Marker2D = $"bullet spawn"
@onready var spawn_marker: Marker2D = $"spawn marker"


@export var enemy_bullet_scene: PackedScene
@export var chasing_enemy_scene: PackedScene
@export var spawn_interval: float = 4.0
@export var max_spawned_enemies: int = 4

var player_ref: Player = null
var player_in_range: bool = false
var spawned_enemies: Array[Node] = []

enum Phase {PHASE_1,PHASE_2,PHASE_3,DEFEATED}
var current_phase: Phase = Phase.PHASE_1
var is_vulnerable: bool = false   # solo true cuando el timer de fase termina
@export var full_dash_charges_requirement: int = 3
@export var phase_duration: float = 15.0   # cuánto dura cada fase antes de volverse vulnerable
@onready var phase_area: Area2D = $phase_area

@onready var phase_timer: Timer = $phase_timer # nuevo Timer en el editor

@onready var boss_shield: AnimatedSprite2D = $boss_shield
@onready var phase_2_sprite: AnimatedSprite2D = $phase2_sprite

@onready var phase_3_sprite: AnimatedSprite2D = $phase3_sprite


func _ready() -> void:
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_exited)
	fire_timer.timeout.connect(_disparar)
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.wait_time = spawn_interval
	phase_timer.timeout.connect(_phase_change_window)
	
	#sistema de fases
	phase_area.body_entered.connect(_phase_transition_hit)
	phase_timer.wait_time = phase_duration
	phase_timer.one_shot = true
	phase_timer.start()

func _physics_process(delta: float) -> void:
	playback.travel("idle")
	move_and_slide()
	
func _on_died() -> void:
	queue_free()
	
func _on_player_detected(body: Node2D) -> void:
	if body is Player:
		player_ref = body
		player_in_range = true
		boss_shield.play("boss_shield")
		fire_timer.start()
		spawn_timer.start()

func _on_player_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		player_ref = null
		fire_timer.stop()
		spawn_timer.stop()

func _disparar() -> void:
	if not player_in_range or not is_instance_valid(player_ref):
		return
	var bala = enemy_bullet_scene.instantiate()
	get_parent().add_child(bala)
	bala.global_position = bullet_spawn.global_position
	bala.direction = global_position.direction_to(player_ref.global_position)
	bala.rotation = bala.direction.angle()
	bala.player = player_ref

func _spawn_enemy() -> void:
	if not player_in_range or not is_instance_valid(player_ref):
		return
	
	var active_enemies: Array[Node] = []
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			active_enemies.append(enemy)
	spawned_enemies = active_enemies
	
	if spawned_enemies.size() >= max_spawned_enemies:
		return
		
	if chasing_enemy_scene:
		var enemy = chasing_enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.global_position = spawn_marker.global_position
		spawned_enemies.append(enemy)
		
#sistema de fases

func _phase_change_window() -> void:
	is_vulnerable = true
	boss_shield.visible=false
	phase_2_sprite.visible=false
	phase_3_sprite.visible=false
	Debug.log("¡Jefe vulnerable! Fase actual: " + str(current_phase))
	
func _phase_transition_hit(body: Node2D) -> void:
	var player = body as Player
	if not player or not is_vulnerable or not (player.is_dashing_to_kill and player.just_full_dashed):
		return
	
	if (player.is_dashing_to_kill and player.just_full_dashed) and Game.full_charges >= full_dash_charges_requirement:
		if current_phase != Phase.PHASE_3:
			var knockback_dir = sign(player.global_position.x - global_position.x)
			player.velocity.x = knockback_dir * 1000
		_advance_phase()
		
func _advance_phase() -> void:
	is_vulnerable = false   # vuelve a ser invulnerable hasta el próximo timer
	
	match current_phase:
		Phase.PHASE_1:
			current_phase = Phase.PHASE_2
			_enter_phase_2()
		Phase.PHASE_2:
			current_phase = Phase.PHASE_3
			_enter_phase_3()
		Phase.PHASE_3:
			current_phase = Phase.DEFEATED
			_on_died()
			return   # no reiniciar el timer, ya murió
	
	phase_timer.start()   # arranca el timer de la nueva fase

func _enter_phase_2() -> void:
	boss_shield.visible=true
	phase_2_sprite.visible=true
	phase_2_sprite.play("phase2")
	fire_timer.wait_time = 1.5
	spawn_interval = 3.0
	spawn_timer.wait_time = spawn_interval
	max_spawned_enemies = 6

func _enter_phase_3() -> void:
	boss_shield.visible=true
	phase_2_sprite.visible=true
	phase_3_sprite.visible=true
	phase_2_sprite.play("phase2")
	phase_3_sprite.play("phase3")
	fire_timer.wait_time = 0.8
	spawn_interval = 2.0
	spawn_timer.wait_time = spawn_interval
	max_spawned_enemies = 8
