extends CanvasLayer

const WORLD = preload("res://Scenes/map.tscn")
func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD)



func _on_button_2_pressed() -> void:
	get_tree().quit()
