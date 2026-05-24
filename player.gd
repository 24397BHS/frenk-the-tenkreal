extends VehicleBody3D

const ENGINE_POWER =1500
var SENS: float = 0.0002
var ELEV: float = 0.0001
var look: = 0.003
var turret_rot = 0
var TotAmmo = 25
var ammo = 1
@onready var left_wheels = [$Leftwheel1, $Leftwheel2, $Leftwheel3, $Leftwheel4, 
							$Leftwheel5, $Leftwheel6, $Leftwheel7]
@onready var right_wheels = [$Rightwheel1, $Rightwheel2, $Rightwheel3, $Rightwheel4, 
							$Rightwheel5, $Rightwheel6, $Rightwheel7]
 
@onready var right_tread = $Body/RightTread
@onready var left_tread = $Body/LeftTread
@onready var camera = $"Body/Сombat_Tower/neck/Camera3D"
@onready var neck = $"Body/Сombat_Tower/neck"
@onready var turret = $"Body/Сombat_Tower"
@onready var manlet = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))"

var target_yaw: float = 0.0

var is_free_looking: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Freelook"):
		is_free_looking = true
		
	if Input.is_action_just_released("Freelook"):
		is_free_looking = false
		neck.rotation = Vector3.ZERO
		





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var steer = Input.get_axis("right", "left")
	var move_dir = Input.get_axis("down", "up")
	if steer != 0 and move_dir !=0:
		for wheel in left_wheels:
			wheel.engine_force = ENGINE_POWER * (move_dir - steer)
		for wheel in right_wheels:
			wheel.engine_force = ENGINE_POWER * (move_dir + steer)
	if steer != 0:
		for wheel in left_wheels:
			wheel.engine_force = ENGINE_POWER * -steer *2
		for wheel in right_wheels:
			wheel.engine_force = ENGINE_POWER * steer *2
		left_tread.get_active_material(0).uv1_offset += $Leftwheel3.get_rpm() * Vector3(-0.002, 0, 0)
		right_tread.get_active_material(0).uv1_offset += $Rightwheel3.get_rpm() * Vector3(-0.002, 0, 0)
	else:
		for wheel in left_wheels:
			wheel.engine_force = ENGINE_POWER * move_dir
		for wheel in right_wheels:
			wheel.engine_force = ENGINE_POWER * move_dir
		left_tread.get_active_material(0).uv1_offset += $Leftwheel3.get_rpm() * Vector3(-0.001, 0, 0)
		right_tread.get_active_material(0).uv1_offset += $Rightwheel3.get_rpm() * Vector3(-0.001, 0, 0)
