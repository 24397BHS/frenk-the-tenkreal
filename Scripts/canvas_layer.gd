extends CanvasLayer

@onready var player: VehicleBody3D = $".."

@onready var label: Label = $Control/Label


func _process(delta: float) -> void:
	label.text = str(player.ammo) + "/" + str(player.TotAmmo)
