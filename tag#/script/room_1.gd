extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var spawn = $spawn.global_position
	print("yippe")
	var room_manager = get_parent()
	room_manager.set_spawn($spawn)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_leve_body_entered(body: Node2D) -> void:
	var room_manager = get_parent()
	
