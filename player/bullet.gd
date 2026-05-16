extends Area2D

#notas de la mecanica
#se asigna la layer 5 como "terrenobala"
#aca se asigna la dinamica jugador/enemigos/terrenoscreados
#activar en jugador mask 1 y 5 (terreno y terrenobala)
#desactivar en el enemigo la mask 5 y solo dejar la 1 (terreno) (con esto enemigos no se suben al terrenobala)


@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var mark: Marker2D = $Marker2D
@onready var bullet_timer = $Timer


@export var speed: float = 2000.0 #velocidad de la bala
var esta_pegado: bool = false  #variable de si esta pegado a algo, por defecto es falso

func _ready() -> void:
	# Conectamos la señal de colisión con cuerpos físicos (TileMaps, StaticBodies, etc.)
	body_entered.connect(_on_body_entered)
	#el CollisionShape2D hijo de StaticBody2D es el terreno creado por la bala
	#por defecto si la bala no esta pegada a nada (en el aire o siendo disparada), no debe tener collision
	#por eso se establece como desactivado
	$StaticBody2D/CollisionShape2D.disabled = true 
	bullet_timer.timeout.connect(on_timer_reached)
	
	
	
func _physics_process(delta: float) -> void:
	
	#se crea una variable "direction" 
	#global_transform.x (por como se define en player) va a ser la direccion en donde estaba el mouse cuando se instancia
	var direction = global_transform.x 
	if not esta_pegado: 
		global_position += direction * speed * delta #si no esta pegado, se acelera en esa dirección
	if ray_cast_2d.is_colliding():
		var objeto = $RayCast2D.get_collider()
		_pegarse(objeto)
		ray_cast_2d.enabled = false
	
func _on_body_entered(body:Node2D)->void:
	if body is Player or esta_pegado:
		return  #si el collisionShape2D detecta a un jugador (mask1) o otra bala (mask5) las ignoro
	
	#en cualquier otro caso, hago _pegarse(body) 
	
	#_pegarse(body) 
	call_deferred("_pegarse", body)
	
func _pegarse(target: Node2D) -> void:
	#cambio el estado a True
	esta_pegado = true
	
	
	#guardo la info antes de pegarse para que no haga cosas raras al hacerse hijo de otros nodos
	var escala_global_original = global_scale
	var posicion_actual = global_position
	var rotacion_actual = global_rotation
	
	#Detenemos el monitoreo de colisiones para optimizar
	#set_deferred("monitoring", false)
	#set_deferred("monitorable", false)
	
	# Cambiamos el nodo padre de la bala al objeto al que se pegó para que se mueva con él  
	get_parent().remove_child(self)
	target.add_child(self)
	target.get_parent().find_child("Player").target_marker = mark
	
	# luego actualizo las variables de la bala, para que se mantenga donde quedó y sepa en todo momento 
	#si no actualizo la posicion, la bala muere al impactar
	#si no actualizo la escala, la bala adopta la escala del objeto al que se pegó (si es terreno se agranda mucho)
	
	global_position = posicion_actual
	global_rotation = rotacion_actual
	global_scale = escala_global_original
	
	#activo el terreno para que el jugador camine
	#edit: cuando no pegue a enemigo
	#esto podría cambiar si queremos que para algún enemigo si se active
	if target is not Enemy:
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)

func on_timer_reached() -> void:
	if not esta_pegado:
		Debug.log("Lanza despawneada")
		queue_free()
