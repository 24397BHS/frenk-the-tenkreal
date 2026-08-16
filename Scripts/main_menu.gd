extends Control

var button_type = null

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")




func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")
