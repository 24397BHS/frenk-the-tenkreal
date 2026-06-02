extends Area3D

@export var speed: float = 20.0
var direction: Vector3 = Vector3.ZERO

func _ready():
	# Let the bullet know which direction to travel based on the Muzzle's basis
	direction = -transform.basis.z.normalized()

func _physics_process(delta):
	# Move the bullet forward
	global_translate(direction * speed * delta)

func _on_body_entered(body):
	# Deal damage here
	if body.is_in_group("Player"):
		# body.take_damage(10)
		queue_free() # Destroy bullet after hitting player
