extends Node2D

@onready var room_manager = get_parent()

func _ready() -> void:
	var spawn = $spawn.global_position
	room_manager.set_spawn(spawn)


func _on_dash_refill_body_entered(body: Node2D) -> void:
	room_manager.ha
