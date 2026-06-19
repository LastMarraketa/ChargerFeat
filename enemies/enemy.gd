class_name Enemy
extends CharacterBody2D

@export var speed = 200
@export var acceleration = 300


@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

func _process(_delta: float) -> void:
	if animation_player:
		_update_animation()

func _update_animation() -> void:
	if abs(velocity.x) > 10:
		if animation_player.has_animation("walk"):
			animation_player.play("walk")
		elif animation_player.has_animation("run"):
			animation_player.play("run")
	else:
		animation_player.play("idle")
