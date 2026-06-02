extends StaticBody3D

# Load your bullet scene
@onready var bullet_scene = preload("res://Scenes/badguybullettest.tscn")
@onready var shoot_timer = $ShootTimer
@onready var muzzle = $Muzzle
@onready var detection_zone = $DetectionZone

var player_in_range = false
var player_target = null

# How fast the enemy aims at the player
@export var rotation_speed: float = 5.0 

func _ready():
	# Connect signals for detection
	detection_zone.connect("body_entered", Callable(self, "_on_player_entered"))
	detection_zone.connect("body_exited", Callable(self, "_on_player_exited"))
	shoot_timer.connect("timeout", Callable(self, "_shoot"))

func _physics_process(delta):
	if player_target:
		# Smoothly rotate the enemy to face the player
		var target_transform = transform.looking_at(player_target.global_position, Vector3.UP)
		transform = transform.interpolate_with(target_transform, rotation_speed * delta)
		
		# Start shooting if the timer isn't running
		if shoot_timer.is_stopped():
			shoot_timer.start()

func _shoot():
	if player_target:
		# 1. Instantiate the bullet
		var bullet = bullet_scene.instantiate()
		
		# 2. Set the bullet's position and direction based on the Muzzle
		bullet.global_transform = muzzle.global_transform
		
		# 3. Add to the main scene (assuming 'World' is the root node)
		get_tree().root.add_child(bullet)
		
		# 4. Reset the shoot timer for the next shot
		shoot_timer.start(1.5)

func _on_player_entered(body):
	# Make sure you set your Player's collision layer/group appropriately!
	if body.is_in_group("Player"):
		player_target = body
		player_in_range = true

func _on_player_exited(body):
	if body == player_target:
		player_target = null
		player_in_range = false
		shoot_timer.stop()
