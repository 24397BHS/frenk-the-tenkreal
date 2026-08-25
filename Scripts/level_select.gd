extends Control
@onready var Can: Label = $Label

func _process(delta: float) -> void:
	Can.text = str(Global.can)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tutorialmap.tscn")
	Global.level = 0


func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/map.tscn")
	Global.level = 1


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Map 2.tscn")
	Global.level = 2


func _on_level_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/map_3.tscn")
	Global.level = 3


func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://shop3d.tscn")
