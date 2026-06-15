extends Area3D

# Make sure this matches the group name assigned to your tank
@export var tank_group_name: String = "Player" 

# Path to your win scene (Godot will autocomplete this if you type "res://")
@export_file("*.tscn") var win_scene_path: String = "res://Win.tscn"

func _ready():
	# Connect the signal to detect when the tank enters
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	# Check if the body entering the zone is a player tank
	if body.is_in_group(tank_group_name):
		trigger_win()

func trigger_win():
	# Optional: Pause the current game logic so things stop moving
	get_tree().paused = false # Set to true if you want to freeze the game first
	
	# Switch to the win scene
	var error = get_tree().change_scene_to_file("res://Scenes/Win.tscn")
	
	# Safety check in case the file name doesn't match perfectly
	if error != OK:
		push_error("Failed to load win scene! Double-check your file path.")
