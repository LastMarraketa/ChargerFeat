extends Area2D

@export var speed: float = 200.0 #velocidad de la bala
var direction: Vector2 = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Conectamos la señal de colisión con cuerpos físicos (TileMaps, StaticBodies, etc.)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position += direction * speed * delta


func _on_body_entered(body:Node2D)->void:
	if body is Player :
		Debug.log("impacto a jugador ")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Slash:
		Debug.log("bala destruida ")
		
		
			
		queue_free()
