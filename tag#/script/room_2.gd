extends Node2D

@onready var room_manager = get_parent()

func _ready() -> void:
	var spawn = $spawn.global_position
	room_manager.set_spawn(spawn)
