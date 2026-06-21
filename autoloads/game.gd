extends Node

signal coins_changed(value: int)
signal player_died()
signal level_completed()
signal charge_changed(new_value, new_max)
signal full_charges_changed(new_value)

var charge: float = 0.0:
	set = _set_charge
var max_charge: float = 6.0
var full_charges: int = 0:
	set = _set_full_charges
var full_charge_limit: int = 1

var coins: int = 0:
	set = set_coins


func set_coins(value: int) -> void:
	coins = value
	coins_changed.emit(coins)
	
func _set_charge(new_value: float) -> void:
	charge = clamp(new_value, 0.0, max_charge)
	charge_changed.emit(charge, max_charge)
	
func _set_full_charges(new_value: int) -> void:
	full_charges = clamp(new_value, 0, full_charge_limit)
	full_charges_changed.emit(full_charges)
