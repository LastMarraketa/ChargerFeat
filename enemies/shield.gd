extends Node2D

@onready var shield_hitbox: CollisionShape2D = $ShieldHitbox/CollisionShape2D
@onready var shield_sprite: Sprite2D = $ShieldHitbox/Sprite2D
@onready var shield_health: HealthComponent = $ShieldHealth

func _ready() -> void:
	shield_health.died.connect(_disable_shield)
	
func _disable_shield():
	shield_hitbox.set_deferred("disabled", true)
	shield_sprite.set_deferred("modulate", Color(0.1, 1.0, 0.8, 0.5))
	shield_sprite.set_deferred("flip_v", true)
	Debug.log("Escudo deshabilitado")
