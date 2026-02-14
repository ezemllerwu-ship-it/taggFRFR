extends Node2D
 
@onready var room_manager = get_parent()

func _on_button_pressed() -> void:
	room_manager.reset()
	room_manager.spawn_room()
