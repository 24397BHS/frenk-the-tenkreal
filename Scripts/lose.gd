extends Control




func _on_try_again_pressed() -> void:
	if Global.level == 0:
		get_tree().change_scene_to_file("res://Scenes/Tutorialmap.tscn")
	elif Global.level == 1:
		get_tree().change_scene_to_file("res://Scenes/map.tscn")
	elif Global.level ==2:
		get_tree().change_scene_to_file("res://Scenes/Map 2.tscn")



func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
