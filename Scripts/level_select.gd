extends Control



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorialmap.tscn")


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/map.tscn")


func _on_level_2_pressed() -> void:
	pass # Replace with function body.


func _on_level_3_pressed() -> void:
	pass # Replace with function body.
