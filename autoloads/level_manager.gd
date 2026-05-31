extends Node

@export var main_menu_scene: PackedScene
@export var credits_scene: PackedScene
@export var levels: Array[PackedScene]

var current_level = 0

func playdemo() -> void:
	current_level = 2
	get_tree().change_scene_to_packed(levels[2])

func start() -> void:
	current_level = 0
	if not levels.is_empty():
		get_tree().change_scene_to_packed(levels[0])


func next_level() -> void:
	current_level += 1
	if current_level < levels.size() - 1:
		get_tree().change_scene_to_packed(levels[current_level])
	else:
		credits()


func has_next_level() -> bool:
	return current_level + 1 < levels.size() - 1



func main_menu() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func credits() -> void:
	get_tree().call_deferred("change_scene_to_packed",credits_scene)
