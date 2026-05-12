extends Node2D

@onready var shield_hitbox: CollisionShape2D = $ShieldHitbox/CollisionShape2D
@onready var shield_sprite: Sprite2D = $ShieldHitbox/Sprite2D
@onready var shield_health: HealthComponent = $ShieldHealth

func _ready() -> void:
	shield_health.died.connect(_disable_shield)
	
func _disable_shield():
	shield_hitbox.set_deferred("disabled", true)
	shield_sprite.set_deferred("modulate", Color(1.0, 1.0, 1.0, 0.0))
	Debug.log("Escudo deshabilitado")
