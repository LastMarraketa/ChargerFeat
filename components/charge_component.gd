class_name ChargeComponent
extends Node

signal charge_changed(value: int)
signal full_charge()

@export var charge: int = 0:
	set(value):
		charge = clamp(value, 0, max_charge)
		charge_changed.emit(charge)
		if charge == 0:
			full_charge.emit()
@export var max_charge: int = 6
