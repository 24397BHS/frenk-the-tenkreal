extends CanvasLayer
const MainMenu = preload("res://Scenes/main_menu.tscn")



func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_packed(MainMenu)


func _on_button_pressed() -> void:
	pass # Replace with function body.
