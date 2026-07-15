
class_name Slash
extends Area2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Puedes definir aquí el daño base si tu HitboxComponent lo requiere
@export var damage: int = 10

func _ready() -> void:
	# Nos aseguramos de que la animación se ejecute inmediatamente al instanciarse.
	
	if animation_player.has_animation("slash"):
		animation_player.play("slash")
	else:
		Debug.log("¡Error: No se encontró la animación 'slash' en el MeleeAttack!")

	# Conectamos la señal por si necesitas detectar cuerpos directamente desde aquí,
	# o puedes delegar esto a tu HitboxComponent/Area2D en el editor.
	body_entered.connect(_on_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	
func _on_animation_finished(anim_name: StringName) -> void:
	queue_free() 
	# Al destruirse este nodo, el Player recibe la señal 'tree_exited' 
	# y cambia 'is_attacking_melee' a false automáticamente.
func _on_body_entered(body: Node2D) -> void:
	# Ejemplo básico de interacción:
	# Si el cuerpo que entró tiene un componente de salud o un método para recibir daño
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
