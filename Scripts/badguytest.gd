extends StaticBody3D

@onready var bullet_scene = preload("res://Scenes/badguybullettest.tscn")
@onready var shoot_timer = $ShootTimer
@onready var muzzle = $Muzzle
@onready var detection_zone = $DetectionZone

var player_in_range = false
var player_target = null

@export var rotation_speed: float = 5.0 

# Match this value to your bullet script's speed and gravity!
@export var bullet_speed: float = 100.0
@export var bullet_gravity: float = 9.8

func _ready():
	detection_zone.connect("body_entered", Callable(self, "_on_player_entered"))
	detection_zone.connect("body_exited", Callable(self, "_on_player_exited"))
	shoot_timer.connect("timeout", Callable(self, "_shoot"))

func _physics_process(delta):
	if player_target:
		# 1. Calculate the predicted target position (Leading + Gravity Compensation)
		var predicted_position = get_predicted_shoot_position()
		
		# 2. Smoothly rotate the enemy to face the predicted position
		var target_transform = transform.looking_at(predicted_position, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * delta)
		
		if shoot_timer.is_stopped():
			shoot_timer.start()

# New function to calculate where the enemy should actually aim
func get_predicted_shoot_position() -> Vector3:
	var target_pos = player_target.global_position
	
	# If the player has a velocity property (CharacterBody3D standard), use it.
	# Otherwise, default to Vector3.ZERO
	var player_velocity = Vector3.ZERO
	if "velocity" in player_target:
		player_velocity = player_target.velocity
	elif "linear_velocity" in player_target: # For RigidBody3D
		player_velocity = player_target.linear_velocity

	# Calculate distance and estimate bullet travel time
	var distance = global_position.distance_to(target_pos)
	var travel_time = distance / bullet_speed
	
	# 1. Lead the target based on their current movement velocity
	var lead_aim = target_pos + (player_velocity * travel_time)
	
	# 2. Compensate for bullet drop
	# Formula derived from physics: d = 0.5 * g * t^2
	var drop_compensation = 0.5 * bullet_gravity * (travel_time * travel_time)
	
	# Add the compensation to the Y axis so the enemy aims higher
	lead_aim.y += drop_compensation
	
	return lead_aim

func _shoot():
	if player_target:
		var bullet = bullet_scene.instantiate()
		bullet.global_transform = muzzle.global_transform
		get_tree().root.add_child(bullet)
		shoot_timer.start(1.5)

func _on_player_entered(body):
	if body.is_in_group("Player"):
		player_target = body
		player_in_range = true

func _on_player_exited(body):
	if body == player_target:
		player_target = null
		player_in_range = false
		shoot_timer.stop()
