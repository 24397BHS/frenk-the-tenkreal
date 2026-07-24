extends CanvasLayer

@onready var player: VehicleBody3D = $".."

@onready var Ammo: Label = $Control/Label
@onready var Health: ProgressBar = $Control/ProgressBar
@onready var HitTarget: Label = $Control/Label2
var fade_tween: Tween

func _ready() -> void:
	HitTarget.modulate.a = 0.0

func _process(delta: float) -> void:
	Ammo.text = str(player.ammo) + "/" + str(player.TotAmmo)
	Health.value = player.health
	

# ---- UPDATED: Accepts an 'is_destroyed' true/false check ----
func show_hit_message(is_destroyed: bool = false) -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
	
	# Change text depending on whether the enemy died
	if is_destroyed:
		HitTarget.text = "TARGET DESTROYED!"
	else:
		HitTarget.text = "HIT!"
	
	# Instantly show text, then wait 2 seconds and fade out
	HitTarget.modulate.a = 1.0
	fade_tween = create_tween()
	fade_tween.tween_interval(2.0)
	fade_tween.tween_property(HitTarget, "modulate:a", 0.0, 0.5)
