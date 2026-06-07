extends CanvasLayer
@onready var button: Button = $Button
const Player = preload("res://Scenes/Player.tscn")
@onready var spawn_point = $"../Spawnpoint"

func _on_button_pressed() -> void:
	button.visible = false
	var player_instance = Player.instantiate()
	player_instance.global_position = spawn_point.global_position
	add_child(player_instance)
