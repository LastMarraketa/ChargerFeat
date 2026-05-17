extends Enemy


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/idle/playback"]
@onready var detection_area: Area2D = $"Detection area"
@onready var fire_timer: Timer = $"fire timer"
@onready var bullet_spawn: Marker2D = $"bullet spawn"
@export var enemy_bullet_scene: PackedScene

#aca se guarda la posicion del jugador mientras esta dentro del area 
var player_ref: Player = null

#usada en _on_player_exited/_on_player_detected para detectar
var player_in_range: bool = false

func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#velocity.y += get_gravity().y * delta
	
	playback.travel("idle")
	move_and_slide()
	

func _ready() -> void:
	
	#estas conectan las señales de las funciones _on_player_detected/_on_player_exited con el area 2D
	detection_area.body_entered.connect(_on_player_detected)
	detection_area.body_exited.connect(_on_player_exited)
	#esta señal maneja el timer de disparo
	fire_timer.timeout.connect(_disparar)
	
	
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
