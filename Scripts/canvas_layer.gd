extends CanvasLayer

@onready var player: VehicleBody3D = $".."

@onready var Ammo: Label = $Control/Label
@onready var Health: ProgressBar = $Control/ProgressBar

func _process(delta: float) -> void:
	Ammo.text = str(player.ammo) + "/" + str(player.TotAmmo)
