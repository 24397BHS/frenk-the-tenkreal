extends Node3D
class_name AP

var bullet_velocity: Vector3 = Vector3.ZERO
var speed: float = 800.0
var lifetime: float = 3.0
var age: float = 0.0
var shot_direction: Vector3 = Vector3.ZERO
var gravity:Vector3
@onready var raycast: RayCast3D = $Raycast

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")
func initialize(start_position: Vector3, direction: Vector3, inital_speed: float) -> void:
	global_position = start_position
	shot_direction = direction.normalized()
	bullet_velocity = shot_direction * inital_speed
	speed = inital_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.



func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
		
	bullet_velocity += gravity * delta
	
	var movement_distance = bullet_velocity.length() * delta
	
	raycast.target_position = bullet_velocity.normalized() * movement_distance
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		global_position = collision_point
		queue_free()
		return
	global_position += bullet_velocity * delta
