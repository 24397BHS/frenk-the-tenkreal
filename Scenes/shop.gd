extends Control

@onready var Can: Label = $Label

func _process(delta: float) -> void:
	Can.text = str(Global.can)




func _on_purchase_76_sherman_pressed() -> void:
	if Global.can >= 150 and Global.upgun == false:
		Global.can -= 150
		Global.upgun = true
		$"purchase 76 sherman".disabled = true

func _on__ammo_pressed() -> void:
	if Global.can >= 50:
		Global.can -= 50
		Global.MaxAmmo += 10


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_Select.tscn")
