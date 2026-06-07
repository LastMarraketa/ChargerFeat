extends TileMapLayer

@onready var health: HealthComponent = $HealthComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.died.connect(_on_died)


func _on_died() -> void:
	queue_free()
