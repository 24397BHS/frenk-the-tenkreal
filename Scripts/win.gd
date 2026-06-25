extends Control


func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_Select.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
