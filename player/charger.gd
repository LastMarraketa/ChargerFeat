class_name Charger
extends TextureProgressBar

signal full_charge()

@export var border_charge: Color = Color("004649")
@export var border_full: Color = Color("00AFB0")
@export var charge_color: Color = Color("ffd500")
@export var full_color: Color = Color("32E024")

func _ready() -> void:
	tint_progress = charge_color
	tint_over = border_charge
	value_changed.connect(on_value_changed)
	
func on_value_changed(new_value: float) -> void:
	if new_value >= max_value:
		tint_progress = full_color
		tint_over = border_full
		full_charge.emit()
	else:
		tint_progress = charge_color
		tint_over = border_charge
