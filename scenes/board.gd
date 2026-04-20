extends Control

@export var rows: int = 4
@export var columns: int = 6

@export var tile_scene: PackedScene

@onready var grid_container: GridContainer = $GridContainer
@onready var panel: Panel = $Panel
@onready var panel_2: Panel = $Panel2


func _ready() -> void:
	grid_container.columns = columns
	if not tile_scene:
		return
	var total = rows * columns
	for i in total:
		var tile_inst = tile_scene.instantiate()
		tile_inst.tile_pressed.connect(_on_tile_pressed.bind(i))
		grid_container.add_child(tile_inst)
	for i in 4:
		var random_index = randi_range(0, total - 1)
		var random_tile = grid_container.get_child(random_index)
		random_tile.simulate_press()
	
	panel.gui_input.connect(_on_panel_gui_input.bind(panel))
	panel_2.gui_input.connect(_on_panel_gui_input.bind(panel_2))


func _on_tile_pressed(index: int) -> void:
	var coords: Vector2i = Vector2i(index / columns, index % columns)
	var neighbors: Array[Vector2i] = [
		Vector2i(0, -1),
		Vector2i(0, 1),
		Vector2i(1, 0),
		Vector2i(-1, 0)
	]
	for neighbor in neighbors:
		var neighbor_coords = coords + neighbor
		var neighbor_index = neighbor_coords.x * columns + neighbor_coords.y
		if neighbor_coords.x >= 0 and neighbor_coords.x < rows and \
			neighbor_coords.y >= 0 and neighbor_coords.y < columns:
			var neighbor_tile = grid_container.get_child(neighbor_index)
			neighbor_tile.toggle()
	check_for_win()


func check_for_win() -> void:
	var won: bool = true
	for child in grid_container.get_children():
		var tile = child as Tile
		if tile and tile.type == Tile.Type.RED:
			won = false
			break
	if won:
		Debug.log("You Win")


func _on_panel_gui_input(event: InputEvent, panel: Control) -> void:
	if event.is_action_pressed("click"):
		Debug.log("click")
		Debug.log(panel.name)
