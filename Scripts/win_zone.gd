extends Area3D

# Preload your Win Scene here (adjust the path to match your actual file)

func _ready() -> void:
	# Connect the signal that detects when a body enters the zone
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the body that entered is the player tank
	# (Since your player script extends VehicleBody3D, we can check for that)
	if body is VehicleBody3D:
		# Free the mouse cursor so the player can interact with the win menu
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		
		
