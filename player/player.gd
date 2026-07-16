class_name Player
extends CharacterBody2D

enum State {
	MOVE,
	WALL_JUMP
}

var state = State.MOVE

@export var speed = 500
@export var jump_speed = 600
@export var acceleration = 300
@onready var jump_timer: Timer = $JumpTimer
@export var propulsion = 900 
#No se está usando, borrar?
#@export var has_bullet = true
@export var has_spear = true
# que tan rápido debe moverse el jugador para activar el daño por impulso
@export var impact_threshold = 1400
@export var melee_attack_scene: PackedScene # <-- Asigna aquí la escena del SLASH
var is_attacking_melee: bool = false        # <-- Nueva variable de control visual para SLASH
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
var game_over_scene: PackedScene = preload("res://ui/game_over_menu.tscn")
var level_complete_scene: PackedScene = preload("res://ui/level_complete_menu.tscn")




var is_dashing_to_kill: bool = false   #variable para manejar el dash poderoso 
#var dash_origin: Vector2 = Vector2.ZERO #estas 2 variables limitan el dash attack
#var dash_distance: float = 1000.0 #esto ajusta hasta donde se llega
@onready var dashtimer: Timer = $dashtimer
@onready var dash_particles: GPUParticles2D = $"Pivot/dash particles"
@onready var charge_particles: GPUParticles2D = $"Pivot/charge particles"


var dash_ready: bool = false #maneja cuando el dash es usable (con carga completa)




#esta instancia es la raiz del sistema de disparo
#se usa en la funcion fire(), la cual instancia el nodo bullet (la bala) en esta escena
#crea una copia denominada bala_viva, a la cual se le aplican las acciones de teleportar y disparar
#el proceso de teleportar hacia la bala esta en move()
#
@export var bullet_scene: PackedScene

var max_health = 30
var health = 30
var _was_on_floor: bool = false
#var ammo: bool = true
var bala_viva = null
var gas: bool = false #para impulsarse en el aire
var moving = false
#balas absorbidas ahoras lo debería ver el Charger
#var balas_destruidas = 0
var shield_active: bool = false
var shield_cooldown: bool = false
var absorbed_bullets: int = 0
@export var max_absorbed_bullets: int = 6
@export var shield_duration: float = 300.0
@export var shield_cooldown_time: float = 5.0
var shield_duration_timer: Timer
var shield_cooldown_timer: Timer
@onready var camera_2d: Camera2D = $Camera2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var pivot: Node2D = $Pivot

@onready var slash_stream_player: AudioStreamPlayer = $SlashStreamPlayer
@onready var dash_stream_player: AudioStreamPlayer = $DashStreamPlayer
@onready var whoosh_stream_player: AudioStreamPlayer = $whooshStreamPlayer


@onready var hitbox_component: HitboxComponent = $Pivot/HitboxComponent
@onready var bullet_spawn_marker: Marker2D = $Pivot/BulletSpawnMarker
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_component: HealthComponent = $HealthComponent
var target_marker: Marker2D = null
@onready var charger: Charger = $Charger # barra de carga, maneja las balas absorbidas

#variables del full dash 
@export var full_dash_hold_time: float = 2
var full_dash_charging: bool = false
var full_dash_hold_timer: float = 0.0
var full_dash_meter_spent: float= 0.0
var just_full_dashed: bool=false
@onready var charge_stream_player: AudioStreamPlayer = $chargeStreamPlayer
@onready var fullcharge_stream_player: AudioStreamPlayer = $fullchargeStreamPlayer
@onready var escudo: AnimatedSprite2D = $escudo

@onready var ground_jump_stream_player: AudioStreamPlayer = $GroundJumpStreamPlayer
@onready var air_jump_stream_player: AudioStreamPlayer = $airJumpStreamPlayer




#signal free_marker

func _ready() -> void:
	
	hitbox_component.damage_dealt.connect(_on_damage_dealt)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_player_died)
	health_bar.max_value = health_component.max_health
	_on_health_changed(health_component.health)
	#free_marker.connect(func(): target_marker = null)
	dashtimer.timeout.connect(_on_time_to_kill_timeout)
	shield_duration_timer = Timer.new()
	shield_duration_timer.one_shot = true
	shield_duration_timer.wait_time = shield_duration
	shield_duration_timer.timeout.connect(_on_shield_timeout)
	add_child(shield_duration_timer)
	
	shield_cooldown_timer = Timer.new()
	shield_cooldown_timer.one_shot = true
	shield_cooldown_timer.wait_time = shield_cooldown_time
	shield_cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(shield_cooldown_timer)
	
	charger.full_charge.connect(_on_full_charge)
	_setup_level_ui()


	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		LevelManager.next_level()

func _physics_process(delta: float) -> void:
	match state:
		State.MOVE:
			_move(delta)
		State.WALL_JUMP:
			_wall_jump(delta)
	
	camera_2d.offset= (get_global_mouse_position()-global_position)/15

func _wall_jump(_delta: float) -> void:
	pass

func _move(delta: float) -> void:
	######################
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	else:
		# Si tocamos el suelo, recuperamos gas (impulso aereo)
		gas = true
	#######################
	if not is_on_floor() and _was_on_floor:
		coyote_timer.start()
	######################
	if (is_on_floor() or not coyote_timer.is_stopped()) and Input.is_action_just_pressed("jump") and jump_timer.is_stopped():
		jump_timer.start()
		ground_jump_stream_player.play()
		
	elif not is_on_floor() and Input.is_action_just_pressed("jump") and gas:
		
		air_jump_stream_player.play()
		var move_input = Input.get_axis("move_left", "move_right")
		var vertical_input = Input.get_axis("move_up", "move_down")
		var propulsion_dir = Vector2(move_input, vertical_input)
		# Si estamos cayendo, cancelamos la velocidad vertical para que el impulso sea limpio
		
		
		if propulsion_dir != Vector2.ZERO:
			propulsion_dir = propulsion_dir.normalized()
			velocity = propulsion_dir * propulsion
		else:
			# Sin ninguna dirección presionada: impulso puramente vertical hacia arriba
			velocity.y = -propulsion
			velocity.x = 0
		
		gas = false
		
		
	if Input.is_action_just_released("jump"):
		jump_timer.stop()
	if not jump_timer.is_stopped():
		#velocity.y = -jump_speed * (jump_timer.time_left / jump_timer.wait_time)
		velocity.y = -jump_speed
	
	
	#proceso de teleportación hacia la bala
	if has_spear and Input.is_action_just_pressed("secondary_fire"): 
		if is_instance_valid(bala_viva):
			global_position = bala_viva.global_position + Vector2(0, -60)
			#si se quiere que se pare en seco (eliminar momentum) cada vez que se teleporte 
			#entonces descomentar lo de abajo ->>
			#velocity = Vector2.ZERO                       
			
	
	
			
			
	if Input.is_action_just_pressed("move_toward"):
		if is_instance_valid(target_marker):
			moving = not moving
	#Proceso de movimiento hacia bala
	if target_marker and moving:
		var marker_direction = global_position.direction_to(target_marker.global_position)
		velocity = marker_direction * 3 * speed
		
		#if global_position.distance_to(target_marker.global_position) < 70:
			#moving = false

	var move_input = Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	_was_on_floor = is_on_floor()
	
	move_and_slide()
	
	### Cambiar estado de hitbox basado en velocidad 
	var current_speed = velocity.length()
	
	
	if current_speed >= impact_threshold:
		hitbox_component.monitorable = true
	else:
		hitbox_component.monitorable = false
	###
	
	var firing = animation_tree["parameters/fire/active"]
	
#################################################################################
#################################################################################
#################################################################################
	#sistema de disparo: 
	#agrego la opcion para revisar si tiene municion
	#var ammo: bool = true (la pegué más arriba)
	#si no esta disparando y acaba de presionar para hacerlo
	#si tiene municion y quiere disparar , dispara (y no hace nada más, la perdida de municion esta en fire() ) 
	#si no tiene municion (ammo==false) y quiere disparar, elimina el terrenobala existente y recarga
	
	if has_spear and not firing and not is_attacking_melee and Input.is_action_just_pressed("fire"):
		#if ammo==true:
			whoosh_stream_player.play()
			animation_tree["parameters/fire/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			pivot.scale.x = sign(get_global_mouse_position().x - global_position.x)
		#else:
			#if is_instance_valid(bala_viva):
				#free_marker.emit()
				#bala_viva.queue_free()
			#Debug.log("acabo de recargar")
			#ammo=true
			#moving = false
			
	if not is_instance_valid(bala_viva):
		target_marker = null
		#ammo = true
	
#################################################################################
#################################################################################
#################################################################################
#SISTEMA DE SLASH (ataque melee) 
#esta es la accion de ataque slash
	if Input.is_action_just_pressed("slash") and not is_attacking_melee:
		_execute_melee_attack()
		var mouse_dir_counter = global_position.direction_to(get_global_mouse_position())
		velocity = mouse_dir_counter * 50
	if Input.is_action_just_pressed("dash_to_kill") and not is_attacking_melee and dash_ready:
		_execute_dash_attack()
	if Input.is_action_just_pressed("toggle_shield") and not shield_active and not shield_cooldown:
		_activate_shield()
	if move_input and not is_attacking_melee:
		pivot.scale.x = sign(move_input)
	#esto checkea todo el tiempo si se esta presionando para hacer full dash
	_check_full_dash_hold(delta)
	

	#if move_input:
		#pivot.scale.x = sign(move_input)
	################################################################################
	################################################################################
	################################################################################
	# animation
	if is_on_floor():
		if abs(velocity.x) > 10 or move_input:
			playback.travel("run")
		else:
			playback.travel("idle")
	else:
		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("fall")


func _on_damage_dealt() -> void:
	Debug.log("I made damage")
	
#################################################################################
#################################################################################
#################################################################################

#crea una bala_viva, 
func fire() -> void:
	if not bullet_scene:
		Debug.log("me olvido poner la bala · 0 ·)>")
		
	if is_instance_valid(bala_viva): #esto elimina toda bala al disparar
		bala_viva.queue_free() #asi no hay que recargar pero siempre hay 1 sola bala viva
		
	bala_viva = bullet_scene.instantiate() #instancia desde otra escena (copia temporal en esta escena) 
	get_parent().add_child(bala_viva) #añade bala_viva como hijo del jugador
	bala_viva.global_position = bullet_spawn_marker.global_position #la posiciona en un punto (spawn)
	#establece que esa posicion donde spawnea la bala_viva es en direccion del mouse
	var mouse_direction = bullet_spawn_marker.global_position.direction_to(get_global_mouse_position()) 
	bala_viva.global_rotation = mouse_direction.angle()
	#establece que se gasto la municion en crear la bala_viva (parte del loop)
	#ammo=false
	
	Debug.log("disparo realizado, municion agotada")
#################################################################################
#################################################################################	
#################################################################################
#################################################################################	
#################################################################################	
#################################################################################
#################################################################################
#SISTEMA DE SLASH (ataque melee) la funcion que llama al melee atack

func _execute_melee_attack() -> void:
	if not melee_attack_scene:
		Debug.log("¡Te olvidaste de asignar la escena del ataque Melee!")
		return
		
	is_attacking_melee = true
	gas=true
	
	# 1. Obtenemos la dirección exacta hacia el mouse
	var mouse_pos = get_global_mouse_position()
	var attack_direction = global_position.direction_to(mouse_pos)
	
	# 2. READABILITY: Forzamos al pivot a mirar al mouse (Izquierda o Derecha) en este frame
	if attack_direction.x != 0:
		pivot.scale.x = sign(attack_direction.x)
		
	# 3. Instanciamos el tajo en el mundo
	var ataque = melee_attack_scene.instantiate()
	#get_parent().add_child(ataque) #este mantiene el ataque en la escena (posiblemente util si se quiere cambiar más adelante) 
	add_child(ataque)
	# Lo posicionamos ligeramente al frente del jugador en la dirección del mouse
	ataque.global_position = global_position + (attack_direction * 30)
	
	# Rotación omnidireccional (360°) exacta hacia el mouse
	ataque.global_rotation = attack_direction.angle()
	slash_stream_player.play()
	
	# 4. Cuando el tajo termine y se destruya, el jugador puede volver a voltearse libremente
	ataque.tree_exited.connect(func(): is_attacking_melee = false)
#################################################################################
#################################################################################
#################################################################################
#################################################################################	
#################################################################################
#################################################################################


#SISTEMA DE DASH_ATTACK (ataque melee) la funcion que llama al melee atack
func _execute_dash_attack() -> void:
	is_dashing_to_kill = true
	hurtbox_component.set_deferred("monitoring", false)
	pivot.modulate = Color(0.3, 0.7, 1.0, 0.7)
	var mouse_dir = global_position.direction_to(get_global_mouse_position())
	velocity = mouse_dir * 5000
	dashtimer.start()
	dash_particles.emitting = true
	Game.charge = 0.0
	get_tree().create_timer(0.1).timeout.connect(_consume_one_charge)
	dash_ready = false
	moving=false
	dash_stream_player.play()
	
func _execute_full_dash_attack() -> void:
	is_dashing_to_kill = true
	just_full_dashed=true
	hurtbox_component.set_deferred("monitoring", false)
	pivot.modulate = Color(0.3, 0.7, 1.0, 0.7)
	var mouse_dir = global_position.direction_to(get_global_mouse_position())
	velocity = mouse_dir * 10000
	dashtimer.start()
	dash_particles.emitting = true
	Game.charge = 0.0
	get_tree().create_timer(0.1).timeout.connect(_reset_full_charges)
	get_tree().create_timer(0.2).timeout.connect(_destroy_terrain_turn_off)
	dash_ready = false
	moving=false
	fullcharge_stream_player.play()


	

func _check_full_dash_hold(delta: float) -> void:
	if Input.is_action_pressed("full_dash") and not is_attacking_melee and dash_ready:
		full_dash_charging = true
		full_dash_hold_timer += delta
		velocity = Vector2.ZERO
		charge_particles.emitting = true
		escudo.play("electric_shield")
		escudo.visible = true
		gas=true
		
		hurtbox_component.set_deferred("monitoring", false)
		pivot.modulate = Color(0.3, 0.7, 1.0, 0.7)
		health_component.health += 200 * delta
		if not charge_stream_player.playing:
			charge_stream_player.play()
		move_and_slide()
		
		if full_dash_hold_timer >= full_dash_hold_time:
			_execute_full_dash_attack()
			full_dash_charging = false
			full_dash_hold_timer = 0.0
			charge_particles.emitting = false
			escudo.stop()
			escudo.visible = false
			charge_stream_player.stop()
			
	else:
		full_dash_charging = false
		full_dash_hold_timer = 0.0
		charge_particles.emitting = false
		escudo.stop()
		escudo.visible = false
		charge_stream_player.stop()
		hurtbox_component.set_deferred("monitoring", true)
		pivot.modulate = Color(1.0, 1.0, 1.0, 1.0) 
		
	
func _on_time_to_kill_timeout() -> void:
	is_dashing_to_kill = false
	velocity = Vector2.ZERO
	hurtbox_component.set_deferred("monitoring", true)
	pivot.modulate = Color(1.0, 1.0, 1.0, 1.0)
	dash_particles.emitting = false
	dash_stream_player.stop()

func _destroy_terrain_turn_off() -> void:
	just_full_dashed=false

func _reset_full_charges() -> void:
	Game.full_charges = 0
func _consume_one_charge() -> void:
	if Game.full_charges > 0:
		Game.full_charges -= 1
	# si aún quedan pilas llenas, se puede volver a hacer dash sin esperar otra
	dash_ready = Game.full_charges > 0
	
#################################################################################
#################################################################################	
#################################################################################
#################################################################################
func _on_health_changed(value: int) -> void:
	health_bar.value = value


func _on_player_died() -> void:
	hide()
	set_physics_process(false)
	set_process_unhandled_input(false)
	Game.player_died.emit()



func _activate_shield() -> void:
	shield_active = true
	shield_duration_timer.start()
	pivot.modulate = Color(0.3, 0.7, 1.0, 0.7)
	hurtbox_component.set_deferred("monitoring", false)

func _on_shield_timeout() -> void:
	shield_active = false
	pivot.modulate = Color(1.0, 1.0, 1.0, 1.0)
	shield_cooldown = true
	shield_cooldown_timer.start()
	hurtbox_component.set_deferred("monitoring", true)

func _on_cooldown_timeout() -> void:
	shield_cooldown = false


func absorb_bullet() -> void:
	if absorbed_bullets < max_absorbed_bullets:
		absorbed_bullets += 1
		
	
func _on_full_charge() -> void:
	dash_ready = true


func _setup_level_ui() -> void:
	var canvas_layer = get_parent().find_child("CanvasLayer", true, false)
	if canvas_layer:
		var game_over_instance = game_over_scene.instantiate()
		canvas_layer.add_child(game_over_instance)
		var level_complete_instance = level_complete_scene.instantiate()
		canvas_layer.add_child(level_complete_instance)
	else:
		var new_canvas = CanvasLayer.new()
		get_parent().add_child(new_canvas)
		var game_over_instance = game_over_scene.instantiate()
		new_canvas.add_child(game_over_instance)
		var level_complete_instance = level_complete_scene.instantiate()
		new_canvas.add_child(level_complete_instance)
