extends Enemy


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/idle/playback"]
@onready var detection_area: Area2D = $"Detection area"
@onready var fire_timer: Timer = $"fire timer"
@onready var bullet_spawn: Marker2D = $"bullet spawn"
@export var enemy_bullet_scene: PackedScene
@onready var time_to_kill_area_turret: Area2D = $"time to kill area turret"

@export var flying_mini_scene: PackedScene
@export var full_charge_requirement: int
@onready var spawn_timer: Timer = $"spawn timer"

#aca se guarda la posicion del jugador mientras esta dentro del area 
var player_ref: Player = null

#usada en _on_player_exited/_on_player_detected para detectar
var player_in_range: bool = false

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#velocity.y += get_gravity().y * delta
	
	playback.travel("idle")
	move_and_slide()
	

func _ready() -> void:
	
	#estas conectan las señales de las funciones _on_player_detected/_on_player_exited con el area 2D
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_exited)
	time_to_kill_area_turret.body_entered.connect(_on_time_to_kill_turret)
	#esta señal maneja el timer de disparo
	fire_timer.timeout.connect(_disparar)
	spawn_timer.timeout.connect(_spawn)
	
	
func _spawn() -> void:
	#if not flying_mini_scene:
	if not flying_mini_scene or not player_in_range or not is_instance_valid(player_ref):
		return
	animation_tree["parameters/spawn/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	var spawn_mini = flying_mini_scene.instantiate()
	get_parent().add_child(spawn_mini)
	spawn_mini.global_position = global_position
	
	
func _on_time_to_kill_turret(body: Node2D) -> void:
	if (body is Player) and ( body.is_dashing_to_kill == true ) :
		Game.full_charge_limit += 1
		Game.charger_tint_request.emit()
		Game.update_destructible_terrain.emit()
		fire_timer.stop()
		spawn_timer.stop()
		Debug.log("Nuevo límite de cargas completas: "+str(Game.full_charge_limit))
		animation_tree["parameters/death/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		await animation_tree.animation_finished
		queue_free() 
		
		
		
		
		
#le dice al area 2D que un jugador entro en su rango
func _on_player_detected(body: Node2D) -> void:
	if body is Player:
		player_ref = body   #se guarda referencia al jugador
		fire_timer.start()
		player_in_range = true
		Debug.log("entró")

#le dice al area 2D que un jugador salio de su rango
func _on_player_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		player_ref = null        # limpiar referencia
		fire_timer.stop() 
		Debug.log("salió")

func _disparar() -> void:
	if not player_in_range or not is_instance_valid(player_ref):
		return
	var bala = enemy_bullet_scene.instantiate()
	get_parent().add_child(bala)
	bala.global_position = bullet_spawn.global_position
	bala.direction = global_position.direction_to(player_ref.global_position)
	bala.rotation = bala.direction.angle()
	bala.player = player_ref
