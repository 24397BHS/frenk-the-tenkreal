extends Area3D

@export var speed: float = 50.0
# Renamed to avoid clashing with Area3D's native gravity property
@export var bullet_gravity: float = 9.8 

var velocity: Vector3 = Vector3.ZERO

func _ready():
	var direction = -transform.basis.z.normalized()
	velocity = direction * speed

func _physics_process(delta):
	# Update the variable name here as well
	velocity.y -= bullet_gravity * delta
	
	global_translate(velocity * delta)
	
	if velocity.length_squared() > 0.001:
		look_at(global_position + velocity, Vector3.UP)

func _on_body_entered(body):
	# 1. If it hits the player, deal damage first
	if body.is_in_group("Player"):
		# body.take_damage(10)
		pass # Replace 'pass' with your damage code when ready
		
	# 2. No matter what it hit (Player, Ground, Wall), destroy the bullet
	queue_free()
