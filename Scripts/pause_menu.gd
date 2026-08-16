extends Control
@onready var main = $"../../"


func _on_resume_pressed() -> void:
	main.pauseMenu()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
	Engine.time_scale = 1


func _on_settings_pressed() -> void:
	$MarginContainer2.show()


func _on_button_pressed() -> void:
	$MarginContainer2.hide()
