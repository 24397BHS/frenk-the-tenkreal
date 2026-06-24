extends Control

func _ready() -> void:
	$Fade_transition/AnimationPlayer.play("Fade_out")
