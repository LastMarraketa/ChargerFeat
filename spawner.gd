extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_radius: int = 100
@export var timer_duration: float = 2.5
@onready var timer: Timer = $Timer
@onready var detection_area: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var player = null

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = timer_duration
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	sprite.play("default")
	
func _on_body_entered(body):
	if body is Player:
		player = body
		timer.start()

func _on_body_exited(body):
	if body is Player:
		player = null
		timer.stop() # Stop spawning when player leaves the area

func _on_timer_timeout():
	if player != null:
		spawn_enemy()

func spawn_enemy():
	if enemy_scene == null:
		return
		
	var enemy = enemy_scene.instantiate()
	
	var distancia = spawn_radius
	var angulo = randf() * PI * 2
	var offset = Vector2(cos(angulo), sin(angulo)) * distancia
	
	enemy.global_position = global_position + offset
	
	# Add the enemy as a child of the main scene (or spawner)
	get_tree().current_scene.add_child(enemy)
