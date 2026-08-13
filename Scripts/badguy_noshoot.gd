extends StaticBody3D

@onready var shoot_timer = $ShootTimer

# Assign in the Inspector (or let Godot auto-find via path)
@export var barrel: Node3D 
@export var muzzle: Node3D 

# Base rest rotation for your barrel mesh (180 degrees on Z)
const DEFAULT_Z_ROT_DEG: float = 180.0



# ---- HEALTH CONFIGURATION ----
@export var max_health: int = 100
@export var health: int = 100

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health remaining: ", health)
	if health <= 0:
		die()

func die() -> void:
	print("Enemy destroyed!")
	Global.can += 30
	queue_free()
