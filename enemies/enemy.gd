class_name Enemy
extends CharacterBody2D

@export var speed = 200
@export var acceleration = 300


@onready var pivot: Node2D = $Pivot
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

func update_animation() -> void:
	if animation_player:
		if abs(velocity.x) > 10:
			if animation_player.current_animation != "walk":
				animation_player.play("walk")
		else:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
