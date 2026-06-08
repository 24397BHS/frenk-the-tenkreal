extends Node3D
class_name AP

var bullet_velocity: Vector3 = Vector3.ZERO
var speed: float = 800.0
var lifetime: float = 3.0
var age: float = 0.0
var shot_direction: Vector3 = Vector3.ZERO
var gravity: Vector3
@onready var raycast: RayCast3D = $Raycast

# Reference to the UI node, passed from the player script when firing
var ui_reference: CanvasLayer = null 

func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")

func initialize(start_position: Vector3, direction: Vector3, inital_speed: float) -> void:
	global_position = start_position
	shot_direction = direction.normalized()
	bullet_velocity = shot_direction * inital_speed
	speed = inital_speed

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
		
	# Apply drop over time
	bullet_velocity += gravity * delta
	
	var movement_distance = bullet_velocity.length() * delta
	
	# Update Raycast length dynamically based on frame velocity
	raycast.target_position = bullet_velocity.normalized() * movement_distance
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		
		# Check if the object we hit can take damage
		if collider and collider.has_method("take_damage"):
			var damage_amount = 50
			
			# Check if this hit will kill the enemy BEFORE applying damage
			var enemy_will_die = false
			if "health" in collider:
				if collider.health <= damage_amount:
					enemy_will_die = true
			
			# Call UI method and pass whether the target was completely destroyed
			if ui_reference and ui_reference.has_method("show_hit_message"):
				ui_reference.show_hit_message(enemy_will_die)
			
			# Apply damage to the target
			collider.take_damage(damage_amount)
		
		# Move to exact impact position and delete bullet
		global_position = collision_point
		queue_free()
		return
		
	# Continue regular movement path if no collision
	global_position += bullet_velocity * delta
