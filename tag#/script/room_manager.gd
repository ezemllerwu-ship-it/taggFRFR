extends Node2D

var player = load("res://scene/player.tscn")

var room_1 = load("res://scene/room_1.tscn")
var room_2 = load("res://scene/room_2.tscn")

var spawn_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_room_1()
	spawn_player()

#func reset():
	#var child = get_children()
	#if child :
		#print("done")
		#else 

func spawn_room_1():
	var room = room_1.instantiate()
	add_child(room)

func spawn_player():
	var spawned_player = player.instantiate()
	spawn_position.add_child(spawned_player)

func set_spawn(spawn):
	spawn_position = spawn


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
