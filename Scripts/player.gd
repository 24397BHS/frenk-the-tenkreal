extends VehicleBody3D


const ShellAP = preload("res://Scenes/ShellAp.tscn")
const ENGINE_POWER =1500
var SENS: float = 0.0002
var ELEV: float = 0.0001
var look: = 0.0003
var turret_rot = 0





var TotAmmo = 25
var ammo = 1
var Maxhealth = 100
var health = 100




var is_scoping: bool = false
@onready var left_wheels = [$Leftwheel1, $Leftwheel2, $Leftwheel3, $Leftwheel4, 
							$Leftwheel5, $Leftwheel6, $Leftwheel7]
@onready var right_wheels = [$Rightwheel1, $Rightwheel2, $Rightwheel3, $Rightwheel4, 
							$Rightwheel5, $Rightwheel6, $Rightwheel7]
 
@onready var right_tread = $Body/RightTread
@onready var left_tread = $Body/LeftTread
@onready var camera = $"Body/Сombat_Tower/neck/Camera3D"
@onready var scope = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))/Camera3D"
@onready var neck = $"Body/Сombat_Tower/neck"
@onready var turret = $"Body/Сombat_Tower"
@onready var manlet = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))"
@onready var barrel: Node3D = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))/gunpoint_mlya)))/Bulletspawn"
@onready var timer = $CooldownTimer

var target_yaw: float = 0.0

var is_free_looking: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if camera:
		camera.current = true
		scope.current = false
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("scope"):
		# Toggle the boolean variable (true becomes false, false becomes true)
		is_scoping = !is_scoping
		
		# Call the function to update the cameras based on that variable
		update_cameras()
func update_cameras() -> void:
	if camera and scope:
		if is_scoping:
			scope.current = true
			camera.current = false
		else:
			camera.current = true
			scope.current = false
func _Damage(Damage: float) -> void:
	health -= Damage 




func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Freelook"):
		is_free_looking = true
		
	if Input.is_action_just_released("Freelook"):
		is_free_looking = false
		neck.rotation = Vector3.ZERO
		
		
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
		
		
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_free_looking:
			neck.rotate_y(-event.relative.x * look)
			camera.rotate_z(-event.relative.y * look)
			camera.rotation.z = clamp(neck.rotation.z, deg_to_rad(-15), deg_to_rad(30))
		else:
			turret.rotate_y(-event.relative.x * SENS)
			manlet.rotate_z(-event.relative.y * ELEV)
			manlet.rotation.z = clamp(manlet.rotation.z, deg_to_rad(-10), deg_to_rad(15))
			camera.rotation.x = manlet.rotation.z
			neck.rotation.y = 0
	
	elif event is InputEventMouseButton or InputEventKey:
		if Input.is_action_just_pressed("fire")and timer.is_stopped() and TotAmmo > 0:
			fire()
		
	if timer.is_stopped() and TotAmmo > 0:
		ammo = 1

func fire() :
	var new_shell:AP = ShellAP.instantiate()
	get_tree().current_scene.add_child(new_shell)
	new_shell.initialize(barrel.global_position,barrel.global_basis.x, 800.0)
	ammo -= 1
	TotAmmo -= 1
	timer.start()
