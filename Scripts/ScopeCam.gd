extends Camera3D
@export var defult_fov: float = 35.0
@export var zoom_fov: float = 5.0
@export var zoom_speed: float = 10.0

var is_zoomed: bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Zoom"):
		is_zoomed = !is_zoomed
	var target_fov = zoom_fov if is_zoomed else defult_fov
	fov = lerp(fov, target_fov, zoom_speed * delta)
