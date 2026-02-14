extends Node2D

@onready var room_2 = load("res://scene/room_2.tscn")
@onready var room_manager = get_parent()

func _ready() -> void:
	var spawn = $spawn.global_position
	room_manager.set_spawn(spawn)


func _process(delta: float) -> void:
	pass

func _on_leve_body_entered(body: Node2D) -> void:
	room_manager.reset()
	room_manager.spawn_room()
