extends Node2D

@export var stand_by_sprite_scene: PackedScene

var direction: Vector2
var speed = 500

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var stand_by_sprite: Sprite2D = $StandBySprite

func _ready() -> void:
	stand_by_sprite.bounce.connect(_on_bounce.bind(stand_by_sprite))


func _on_bounce(node_2d: Node2D) -> void:
	if get_child_count() > 1000:
		return
	if not stand_by_sprite_scene:
		return
	var stand_by_sprite_inst = stand_by_sprite_scene.instantiate()
	stand_by_sprite_inst.global_position = node_2d.global_position
	add_child(stand_by_sprite_inst)
	move_child(stand_by_sprite_inst, 0)
	await get_tree().create_timer(0.2).timeout
	stand_by_sprite_inst.bounce.connect(_on_bounce.bind(stand_by_sprite_inst))
	
	
	
