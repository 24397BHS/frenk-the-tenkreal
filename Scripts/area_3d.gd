extends Area3D

@export var speed: float = 50.0
@export var bullet_gravity: float = 9.8 

# Make sure this matches the name of your RayCast3D node in the inspector exactly
@onready var raycast: RayCast3D = $Raycast 
var velocity: Vector3 = Vector3.ZERO

func _ready():
	var direction = -transform.basis.z.normalized()
	velocity = direction * speed
	
	# Ensure the raycast is configured properly via code just in case
	if raycast:
		raycast.enabled = true
		# Exclude the bullet itself from being hit by its own raycast
		raycast.add_exception(self) 

func _physics_process(delta):
	# 1. Apply gravity
	velocity.y -= bullet_gravity * delta
	
	# 2. Update Raycast length dynamically based on frame velocity
	# The ray needs to look ahead exactly as far as the bullet will move this frame
	if raycast:
		var movement_this_frame = velocity * delta
		# Convert global movement into the local coordinates the raycast expects
		raycast.target_position = raycast.to_local(global_position + movement_this_frame)
		
		# Force the raycast to update immediately before we move
		raycast.force_raycast_update()
		
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			handle_collision(collider)
			return # Stop processing movement if we hit something

	# 3. Move the bullet if no raycast collision happened
	global_translate(velocity * delta)
	
	if velocity.length_squared() > 0.001:
		look_at(global_position + velocity, Vector3.UP)

# Helper function to process hits cleanly
func handle_collision(body):
	if body.is_in_group("Player"):
		# body.take_damage(10)
		pass # Replace with your damage code
		
	queue_free()

# Keep this as a backup for slower movements or edge cases
func _on_body_entered(body):
	handle_collision(body)
