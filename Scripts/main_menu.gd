extends Control

var button_type = null

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_Select.tscn")




func _on_quit_pressed() -> void:
	get_tree().quit()
