extends Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var time_to_kill_area_enemy_bullet: Area2D = $"time to kill area enemy bullet"

@export var speed: float = 500.0 #velocidad de la bala
var direction: Vector2 = Vector2.RIGHT
var player: Player = null #importante, guarda la logica de contador de balas destruidas
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Conectamos la señal de colisión con cuerpos físicos (TileMaps, StaticBodies, etc.)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	time_to_kill_area_enemy_bullet.body_entered.connect(_on_time_to_kill_enemy_bullet)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position += direction * speed * delta
	
	animation_player.play("firing")

func _on_time_to_kill_enemy_bullet(body: Node2D) -> void:
	if (body is Player) and ( body.is_dashing_to_kill == true ):
		queue_free() 
		
func _on_body_entered(body:Node2D)->void:
	if body is Player :
		if body.shield_active:
			body.absorb_bullet()
		else:
			Debug.log("impacto a jugador ")
		queue_free()
	elif body is not Enemy:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Slash:
		#ojo, aca la referencia a player no es null como dice arriba
		#la referencia a player es guardada por enemigo torreta cuando
		#cuando este observa que entran a su area, guarda estos datos de player y "comunica"
		if player:
			player.balas_destruidas += 1
			Debug.log("bala destruida " + str(player.balas_destruidas))
		
			
		queue_free()
