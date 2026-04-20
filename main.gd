extends Node2D

@onready var area_2d: Area2D = $Area2D
@export var main_3d: PackedScene
@export var meh: bool = true

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("retry"):
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_level"):
		Debug.log("hello")
		get_tree().change_scene_to_file("res://main_3d.tscn")

func _on_body_entered(body: Node2D) -> void:
	Debug.log(body.name)
	if body is CharacterBody2D:
		if main_3d:
			get_tree().change_scene_to_packed(main_3d)
