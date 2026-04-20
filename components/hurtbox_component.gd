class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as HitboxComponent
	if hitbox:
		if health_component:
			health_component.health -= hitbox.damage
