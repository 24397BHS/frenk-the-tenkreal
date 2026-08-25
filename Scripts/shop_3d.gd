extends Node3D

@onready var Can: Label = $Control/TextureRect/Label

func _process(delta: float) -> void:
	Can.text = str(Global.can)




func _on_upgun_pressed() -> void:
	if Global.can >= 150 and Global.upgun == false:
		Global.can -= 150
		Global.upgun = true
		$Control/Control/HBoxContainer/Upgun.disabled = true
		$Marker3D/shermanfix.hide()
		$"Marker3D/M4-76".show()


func _on_reduced_pressed() -> void:
	if Global.can >= 100 and Global.Stronk == false:
		Global.can -= 100
		Global.Stronk = true
		$Control/Control/HBoxContainer/Reduced.disabled = true


func _on_moar_pressed() -> void:
	if Global.can >= 50:
		Global.can -= 50
		Global.MaxAmmo += 5


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_Select.tscn")
