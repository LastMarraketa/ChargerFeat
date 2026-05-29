extends Enemy

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/idle/playback"]
@onready var detection_area: Area2D = $"Detection area"
@onready var fire_timer: Timer = $"fire timer"
@onready var spawn_timer: Timer = $"spawn timer"
@onready var bullet_spawn: Marker2D = $"bullet spawn"
@onready var spawn_marker: Marker2D = $"spawn marker"
@onready var health_component: HealthComponent = $HealthComponent

@export var enemy_bullet_scene: PackedScene
@export var chasing_enemy_scene: PackedScene
@export var spawn_interval: float = 4.0
@export var max_spawned_enemies: int = 4

var player_ref: Player = null
var player_in_range: bool = false
var spawned_enemies: Array[Node] = []

func _ready() -> void:
    detection_area.body_entered.connect(_on_player_detected)
    detection_area.body_exited.connect(_on_player_exited)
    fire_timer.timeout.connect(_disparar)
    spawn_timer.timeout.connect(_spawn_enemy)
    health_component.died.connect(_on_died)
    
    spawn_timer.wait_time = spawn_interval

func _physics_process(delta: float) -> void:
    playback.travel("idle")
    move_and_slide()

func _on_player_detected(body: Node2D) -> void:
    if body is Player:
        player_ref = body
        player_in_range = true
        fire_timer.start()
        spawn_timer.start()

func _on_player_exited(body: Node2D) -> void:
    if body is Player:
        player_in_range = false
        player_ref = null
        fire_timer.stop()
        spawn_timer.stop()

func _disparar() -> void:
    if not player_in_range or not is_instance_valid(player_ref):
        return
    var bala = enemy_bullet_scene.instantiate()
    get_parent().add_child(bala)
    bala.global_position = bullet_spawn.global_position
    bala.direction = global_position.direction_to(player_ref.global_position)
    bala.rotation = bala.direction.angle()
    bala.player = player_ref

func _spawn_enemy() -> void:
    if not player_in_range or not is_instance_valid(player_ref):
        return
    
    var active_enemies: Array[Node] = []
    for enemy in spawned_enemies:
        if is_instance_valid(enemy):
            active_enemies.append(enemy)
    spawned_enemies = active_enemies
    
    if spawned_enemies.size() >= max_spawned_enemies:
        return
        
    if chasing_enemy_scene:
        var enemy = chasing_enemy_scene.instantiate()
        get_parent().add_child(enemy)
        enemy.global_position = spawn_marker.global_position
        spawned_enemies.append(enemy)

func _on_died() -> void:
    queue_free()
