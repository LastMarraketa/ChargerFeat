extends Node2D

@onready var shield_hitbox: CollisionShape2D = $ShieldHitbox/CollisionShape2D
@onready var shield_health: HealthComponent = $ShieldHealth

func _ready() -> void:
	shield_health.died.connect(_disable_shield)
	
func _disable_shield():
	shield_hitbox.set_deferred("disabled", true)
	Debug.log("Escudo deshabilitado")
