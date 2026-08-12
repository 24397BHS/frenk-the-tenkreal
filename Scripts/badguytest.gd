extends StaticBody3D

# ---- NODE REFERENCES ----
@onready var bullet_scene = preload("res://Scenes/badguybullettest.tscn")
@onready var shoot_timer = $ShootTimer
@onready var detection_zone = $DetectionZone
@onready var enemyShootingAudioStream = $AudioStreamPlayer_Badfire

# Assign in the Inspector (or let Godot auto-find via path)
@export var barrel: Node3D 
@export var muzzle: Node3D 

# ---- TARGETING & ROTATION ----
var player_in_range: bool = false
var player_target: Node3D = null

@export var rotation_speed: float = 5.0 

# Base rest rotation for your barrel mesh (180 degrees on Z)
const DEFAULT_Z_ROT_DEG: float = 180.0

# ---- ELEVATION LIMITS (IN DEGREES) ----
@export var max_elevation_deg: float = 15.0  # Aiming UP
@export var max_depression_deg: float = 5.0   # Aiming DOWN

# ---- BULLET PHYSICS CONFIGURATION ----
# Match these values to your bullet script's speed and gravity!
@export var bullet_speed: float = 250.0
@export var bullet_gravity: float = 9.8

# ---- CHANCE TO HIT CONFIGURATION ----
@export_range(0.0, 1.0) var hit_chance: float = 1.0
var current_aim_offset: Vector3 = Vector3.ZERO
var offset_wobble_timer: float = 0.0

# ---- HEALTH CONFIGURATION ----
@export var max_health: int = 100
@export var health: int = 100

func _ready():
	# Auto-assign muzzle/barrel if they weren't assigned in the Inspector
	if muzzle == null and has_node("Barrel/Muzzle"):
		muzzle = $Barrel/Muzzle
	elif muzzle == null and has_node("Muzzle"):
		muzzle = $Muzzle

	if barrel == null and has_node("Barrel"):
		barrel = $Barrel

	# Signal Connections
	if detection_zone:
		detection_zone.body_entered.connect(_on_player_entered)
		detection_zone.body_exited.connect(_on_player_exited)
	else:
		push_warning("DetectionZone node missing!")

	if shoot_timer:
		shoot_timer.timeout.connect(_shoot)
	else:
		push_warning("ShootTimer node missing!")

func _physics_process(delta):
	if is_instance_valid(player_target):
		# 1. Calculate target point (Lead Aim + Gravity Compensation)
		var predicted_position = get_predicted_shoot_position()
		
		# 2. Add organic wobble (Only if hit_chance is less than 100%)
		var wobble = Vector3.ZERO
		if hit_chance < 1.0:
			offset_wobble_timer += delta
			wobble = Vector3(
				sin(offset_wobble_timer * 2.0),
				cos(offset_wobble_timer * 1.5),
				sin(offset_wobble_timer * 1.0)
			) * 0.3
		
		var final_aim_point = predicted_position + current_aim_offset + wobble

		# 3. Rotate Body (Yaw / Left & Right)
		aim_body_at_target(final_aim_point, delta)
		
		# 4. Rotate Barrel (Pitch / Up & Down on Z-axis)
		if barrel:
			aim_barrel_at_target(final_aim_point, delta)

# Rotates enemy body horizontally on the Y axis
func aim_body_at_target(target_pos: Vector3, delta: float) -> void:
	var yaw_target = Vector3(target_pos.x, global_position.y, target_pos.z)
	
	if yaw_target.distance_squared_to(global_position) > 0.001:
		var target_transform = transform.looking_at(yaw_target, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * delta)

# Rotates barrel on local Z-axis using world-space geometry to avoid transform axis flips
func aim_barrel_at_target(target_pos: Vector3, delta: float) -> void:
	var barrel_pos = barrel.global_position
	
	# Get horizontal distance
	var flat_target = Vector3(target_pos.x, barrel_pos.y, target_pos.z)
	var horizontal_dist = barrel_pos.distance_to(flat_target)
	
	# Get vertical height difference
	var height_diff = target_pos.y - barrel_pos.y
	
	# Calculate pitch angle in degrees
	var pitch_deg = rad_to_deg(atan2(height_diff, max(horizontal_dist, 0.001)))
	
	# Clamp pitch (+15° elevation up, -5° depression down)
	var clamped_pitch = clamp(pitch_deg, -max_depression_deg, max_elevation_deg)
	
	# Apply pitch to default 180° Z rotation
	# (Note: If aiming UP causes the barrel to tilt DOWN, change '+' to '-' below)
	var target_z_rad = deg_to_rad(DEFAULT_Z_ROT_DEG + clamped_pitch)
	
	barrel.rotation.z = lerp_angle(barrel.rotation.z, target_z_rad, rotation_speed * delta)

# Calculates predicted lead position from muzzle location
func get_predicted_shoot_position() -> Vector3:
	var target_pos = player_target.global_position
	var start_pos = muzzle.global_position if muzzle else global_position
	
	var player_velocity = Vector3.ZERO
	if "velocity" in player_target:
		player_velocity = player_target.velocity
	elif "linear_velocity" in player_target: 
		player_velocity = player_target.linear_velocity

	var distance = start_pos.distance_to(target_pos)
	var travel_time = distance / max(bullet_speed, 1.0)
	
	var lead_aim = target_pos + (player_velocity * travel_time)
	var drop_compensation = 0.5 * bullet_gravity * (travel_time * travel_time)
	lead_aim.y += drop_compensation
	
	return lead_aim

func _shoot():
	if is_instance_valid(player_target):
		if bullet_scene and muzzle:
			var bullet = bullet_scene.instantiate()
			bullet.global_transform = muzzle.global_transform
			get_tree().root.add_child(bullet)
			enemyShootingAudioStream.play()
		else:
			print("Cannot shoot: Check if bullet_scene and muzzle are assigned!")
		
		# Roll accuracy offset for next shot
		if randf() > hit_chance:
			current_aim_offset = Vector3(
				randf_range(-15, 15),
				randf_range(-5, 10),
				randf_range(-15, 15)
			)
		else:
			current_aim_offset = Vector3.ZERO

func _on_player_entered(body):
	if body.is_in_group("Player"):
		player_target = body
		player_in_range = true
		
		# Set initial accuracy offset
		if randf() > hit_chance:
			current_aim_offset = Vector3(randf_range(-2.0, 2.0), randf_range(-0.5, 1.5), randf_range(-2.0, 2.0))
		else:
			current_aim_offset = Vector3.ZERO
			
		# Shoot immediately upon detection, then start looping timer
		_shoot()
		if shoot_timer:
			shoot_timer.start()

func _on_player_exited(body):
	if body == player_target:
		player_target = null
		player_in_range = false
		if shoot_timer:
			shoot_timer.stop()
		current_aim_offset = Vector3.ZERO

func take_damage(amount: int) -> void:
	health -= amount
	Global.can += 15
	print("Enemy hit! Health remaining: ", health)
	if health <= 0:
		die()

func die() -> void:
	print("Enemy destroyed!")
	queue_free()
