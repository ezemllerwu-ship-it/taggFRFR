extends Node2D

@onready var room_manager = get_parent()

func _ready() -> void:
	var spawn = $spawn.global_position
	room_manager.set_spawn(spawn)

func _on_leave_body_entered(body: Node2D) -> void:
	room_manager.reset()
	room_manager.spawn_room()


func _on_kill_box_body_entered(body: Node2D) -> void:
	room_manager.kill()
