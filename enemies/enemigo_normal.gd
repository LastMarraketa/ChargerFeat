extends CharacterBody2D




#@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/idle/playback"]



@export var enemy_bullet_scene: PackedScene
@onready var time_to_kill_area_turret: Area2D = $"time to kill area turret"

######################################################################
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var detection_area: Area2D = $"Detection area"
@onready var fire_timer: Timer = $"fire timer"
@onready var sprite_2d: Sprite2D = $Sprite2D


@onready var bullet_spawn: Marker2D = $"bullet spawn"
@onready var time_to_kill_area_normal_volador: Area2D = $"time to kill area normal volador"


#aca se guarda la posicion del jugador mientras esta dentro del area 
var player_ref: Player = null

#usada en _on_player_exited/_on_player_detected para detectar
var player_in_range: bool = false


func _physics_process(delta: float) -> void:
	if not player_in_range or not is_instance_valid(player_ref):
		return
	sprite_2d.flip_h = player_ref.global_position.x > global_position.x
	#playback.travel("idle")
	move_and_slide()
	

func _ready() -> void:
	
	#estas conectan las señales de las funciones _on_player_detected/_on_player_exited con el area 2D
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_exited)
	time_to_kill_area_normal_volador.body_entered.connect(_on_time_to_kill_turret)
	#esta señal maneja el timer de disparo
	fire_timer.timeout.connect(_disparar)

	
	

	
func _on_time_to_kill_turret(body: Node2D) -> void:
	if (body is Player) and ( body.is_dashing_to_kill == true ):
		fire_timer.stop()
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
	var balav = enemy_bullet_scene.instantiate()
	get_parent().add_child(balav)
	balav.global_position = bullet_spawn.global_position
	balav.direction = global_position.direction_to(player_ref.global_position)
	balav.rotation = balav.direction.angle()
	balav.player = player_ref
	animation_tree["parameters/fire/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
