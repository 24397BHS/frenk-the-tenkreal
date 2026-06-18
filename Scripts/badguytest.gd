extends StaticBody3D

@onready var bullet_scene = preload("res://Scenes/badguybullettest.tscn")
@onready var shoot_timer = $ShootTimer
@onready var muzzle = $Muzzle
@onready var detection_zone = $DetectionZone

var player_in_range = false
var player_target = null

@export var rotation_speed: float = 2.0 

# Match this value to your bullet script's speed and gravity!
@export var bullet_speed: float = 250.0
@export var bullet_gravity: float = 9.8

# ---- CHANCE TO HIT CONFIGURATION ----
@export_range(0.0, 1.0) var hit_chance: float = 0.1
var current_aim_offset: Vector3 = Vector3.ZERO
var offset_wobble_timer: float = 0.0

func _ready():
	detection_zone.connect("body_entered", Callable(self, "_on_player_entered"))
	detection_zone.connect("body_exited", Callable(self, "_on_player_exited"))
	shoot_timer.connect("timeout", Callable(self, "_shoot"))

func _physics_process(delta):
	if player_target:
		# 1. Calculate the perfect predicted position (Leading + Gravity)
		var predicted_position = get_predicted_shoot_position()
		
		# 2. Update a slowly shifting "wobble" offset so the aim feels organic
		# This stops the enemy from looking like a rigid robot while tracking
		offset_wobble_timer += delta
		var wobble = Vector3(
			sin(offset_wobble_timer * 2.0),
			cos(offset_wobble_timer * 1.5),
			sin(offset_wobble_timer * 1.0)
		) * 0.3 # Small continuous sway
		
		# Combine the miss offset (if any) and the organic wobble
		var final_aim_point = predicted_position + current_aim_offset + wobble

		# 3. Smoothly rotate the enemy to face the final calculated position
		var target_transform = transform.looking_at(final_aim_point, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * delta)
		
		if shoot_timer.is_stopped():
			shoot_timer.start()

# Calculates where the enemy should ideally aim
func get_predicted_shoot_position() -> Vector3:
	var target_pos = player_target.global_position
	
	var player_velocity = Vector3.ZERO
	if "velocity" in player_target:
		player_velocity = player_target.velocity
	elif "linear_velocity" in player_target: 
		player_velocity = player_target.linear_velocity

	var distance = global_position.distance_to(target_pos)
	var travel_time = distance / bullet_speed
	
	var lead_aim = target_pos + (player_velocity * travel_time)
	var drop_compensation = 0.5 * bullet_gravity * (travel_time * travel_time)
	lead_aim.y += drop_compensation
	
	return lead_aim

func _shoot():
	if player_target:
		var bullet = bullet_scene.instantiate()
		bullet.global_transform = muzzle.global_transform
		get_tree().root.add_child(bullet)
		
		# ---- NEW: Roll accuracy for the NEXT shot ----
		# This keeps the hit rate exactly at 75% across the whole engagement
		if randf() > hit_chance:
			# Roll a random miss direction
			current_aim_offset = Vector3(
				randf_range(-20, 20),
				randf_range(-05, 15),
				randf_range(-20, 20)
			)
		else:
			# Perfect aim for this shot cycle
			current_aim_offset = Vector3.ZERO
			
		shoot_timer.start(3.0)

func _on_player_entered(body):
	if body.is_in_group("Player"):
		player_target = body
		player_in_range = true
		
		# Roll for the very first shot accuracy immediately
		if randf() > hit_chance:
			current_aim_offset = Vector3(randf_range(-2.0, 2.0), randf_range(-0.5, 1.5), randf_range(-2.0, 2.0))
		else:
			current_aim_offset = Vector3.ZERO

func _on_player_exited(body):
	if body == player_target:
		player_target = null
		player_in_range = false
		shoot_timer.stop()
		current_aim_offset = Vector3.ZERO
		
# ---- ADD THIS TO THE BOTTOM OF YOUR ENEMY CODE ----

@export var max_health: int = 100
@export var health: int = 100

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health remaining: ", health)
	
	if health <= 0:
		die()

func die() -> void:
	print("Enemy destroyed!")
	queue_free() # Removes the enemy from the game scene
