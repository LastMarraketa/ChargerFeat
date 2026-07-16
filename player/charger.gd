class_name Charger
extends TextureProgressBar

signal full_charge()

@export var border_charge: Color = Color("004649")
@export var border_full: Color = Color("00AFB0")
@export var charge_color: Color = Color("ffd500")
@export var full_color: Color = Color("32E024")

func _ready() -> void:
	max_value = Game.max_charge
	value = Game.charge
	Game.charge_changed.connect(on_charge_changed)
	update_tint()
	
func on_charge_changed(new_charge: float, new_max_charge: float) -> void:
	max_value = new_max_charge
	value = new_charge
	if value == max_value:
		Game.full_charges += 1
		if Game.full_charges != Game.full_charge_limit:
			Game.charge = 0.0 #hay que hacer que se resetee la carga cuando se
		# llega a una carga completa, pero sin que se resetee cada vez
		# que se llame a esta función
		
		update_tint()
		full_charge.emit()
		
func update_tint() -> void:
	if Game.full_charges == Game.full_charge_limit:
		tint_progress = full_color
		tint_over = border_full
	else:
		tint_progress = charge_color
		tint_over = border_charge
