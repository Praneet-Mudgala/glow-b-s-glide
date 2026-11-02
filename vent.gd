extends Area2D

@export var safe_time: float = 1.0
@export var deadly_time: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var switch_timer: Timer = $SwitchTimer

var is_deadly: bool = false

func _ready() -> void:
	switch_timer.timeout.connect(_on_switch_timer_timeout)
	trigger_safe_state()
	
func _on_switch_timer_timeout() -> void:
	is_deadly = not is_deadly
	if is_deadly:
		trigger_deadly_state()
	else:
		trigger_safe_state()
		
func trigger_safe_state() -> void:
	is_deadly = false
	animated_sprite.play("Safe")
	collision_polygon.set_deffered("disabled", true)
	switch_timer.start(safe_time)

func trigger_deadly_state() -> void:
	is_deadly = true
	animated_sprite.play("Active")
	collision_polygon.set_deffered("disabled", false)
	switch_timer.start(deadly_time)





# Old code
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
