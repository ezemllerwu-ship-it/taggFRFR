extends Node2D

@onready var room_manager = get_parent()
@onready var refill_visual = $dash_refill/can_1 
var refill_timer: Timer

func _ready() -> void:
	room_manager.set_spawn($spawn.global_position)
	
	# Setup the timer
	refill_timer = Timer.new()
	refill_timer.wait_time = 5.0
	refill_timer.one_shot = true
	add_child(refill_timer)
	
	refill_timer.timeout.connect(_on_refill_ready)

func _on_leave_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		room_manager.call_deferred("spawn_room")

func _on_kill_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		room_manager.kill()

func _on_dash_refill_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and refill_timer.is_stopped():
		room_manager.dash_refill()
		refill_timer.start()
		var tween = create_tween()
		tween.tween_property(refill_visual, "modulate:a", 0.0, 0.2)
func _on_refill_ready():
	var tween = create_tween()
	tween.tween_property(refill_visual, "modulate:a", 1.0, 0.5)
