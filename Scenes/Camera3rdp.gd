extends Camera3D

@export var noise: FastNoiseLite
@export var noise_speed: float = 30.0

@export var max_pitch: float = 0.1  # Up/Down rotation max (radians)
@export var max_yaw: float = 0.1    # Left/Right rotation max (radians)
@export var max_roll: float = 0.1   # Tilting rotation max (radians)

@export var decay: float = 2.0       # How fast the shake stops

var trauma: float = 0.0              # Current shake intensity (0.0 to 1.0)
var time: float = 0.0
var initial_rotation: Vector3

func _ready() -> void:
	initial_rotation = rotation
	
	# Automatically generate noise settings if none are assigned in inspector
	if not noise:
		noise = FastNoiseLite.new()
		noise.seed = randi()
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		noise.frequency = 0.05

func add_shake(amount: float) -> void:
	# Clamping trauma to 1.0 caps the maximum shake angle
	trauma = min(trauma + amount, 1.0)

func _process(delta: float) -> void:
	if trauma > 0.0:
		# Decay trauma over time
		trauma = max(trauma - decay * delta, 0.0)
		
		# Progress time through the noise landscape
		time += delta * noise_speed
		
		# Squash curve (trauma^2) makes low trauma values smoother
		var shake_strength = trauma * trauma
		
		# Sample different regions of the noise generator using arbitrary offsets
		var shake_pitch = max_pitch * shake_strength * noise.get_noise_2d(time, 0.0)
		var shake_yaw = max_yaw * shake_strength * noise.get_noise_2d(0.0, time)
		var shake_roll = max_roll * shake_strength * noise.get_noise_2d(time, time)
		
		# Apply rotational adjustments to initial values
		rotation.x = initial_rotation.x + shake_pitch
		rotation.y = initial_rotation.y + shake_yaw
		rotation.z = initial_rotation.z + shake_roll
	else:
		# Return to exactly default look rotation when done
		rotation = initial_rotation
