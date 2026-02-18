extends Node2D

@onready var room_manager = get_parent()
const REFILL_TIME := 5.0

var dash_refill_timer := 0.0
var can_refill_dash := true


func _ready() -> void:
	var spawn = $spawn.global_position
	room_manager.set_spawn(spawn)


func _process(delta: float) -> void:
	if not can_refill_dash:
		dash_refill_timer -= delta
		if dash_refill_timer <= 0.0:
			can_refill_dash = true
			print("redey")


func _on_dash_refill_body_entered(body: Node2D) -> void:
	if can_refill_dash == true:
		room_manager.dash_refill()
		can_refill_dash = false
		dash_refill_timer = REFILL_TIME
	print("not redy")
