extends Node

signal coins_changed(value: int)
signal player_died()


var coins: int = 0:
    set = set_coins


func set_coins(value: int) -> void:
    coins = value
    coins_changed.emit(coins)

