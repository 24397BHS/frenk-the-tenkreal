extends VehicleBody3D
const ShellAP = preload("res://Scenes/ShellAp.tscn")
const ENGINE_POWER = 500
const MAX_SPEED = 100
var SENS: float = 0.0002
var ELEV: float = 0.0001
var look: float = 0.0003
var turret_rot = 0

var ammo = 1
var MaxAmmo = 25 + Global.MaxAmmo
@export var Maxhealth = 100
@export var health = 100

var is_scoping: bool = false

@onready var left_wheels = [$LeftWheel1, $LeftWheel2, $LeftWheel3, $LeftWheel4, 
							$LeftWheel5, $LeftWheel6, $LeftWheel7]
@onready var right_wheels = [$RightWheel1, $RightWheel2, $RightWheel3, $RightWheel4, 
							$RightWheel5, $RightWheel6, $RightWheel7]
 
@onready var right_tread = $RightTread
@onready var left_tread = $LeftTread
@onready var camera = $"Body/Сombat_Tower/neck/Up down/Camera3D"
@onready var scope = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))/Camera3D"
@onready var neck = $"Body/Сombat_Tower/neck"
@onready var turret = $"Body/Сombat_Tower"
@onready var manlet = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))"
@onready var barrel: Node3D = $"Body/Сombat_Tower/Rolling_ Armour_Mlya))/gunpoint_mlya)))/Bulletspawn"
@onready var timer = $CooldownTimer
@onready var sight = $CanvasLayer/Control/TextureRect
@onready var playerShootAudioStream = $AudioStreamPlayer_Fire
@onready var playerIdleAudioStream = $AudioStreamPlayer_idle
@onready var playerHitAudioStream = $AudioStreamPlayer_Hit
@onready var pause_menu  = $CanvasLayer/PauseMenu
@onready var updownview = $"Body/Сombat_Tower/neck/Up down"


var paused = false

var target_yaw: float = 0.0
var is_free_looking: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if camera:
		camera.current = true
		scope.current = false
	playerIdleAudioStream.play()
	if Global.Stronk == true:
		timer.wait_time = 1.5

	if Global.upgun ==true:
		$"Body/Сombat_Tower/Rolling_ Armour_Mlya))/gunpoint_mlya)))2".show()
		$"Body/Сombat_Tower/Rolling_ Armour_Mlya))/gunpoint_mlya)))".hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("scope"):
		is_scoping = !is_scoping
		update_cameras()

func update_cameras() -> void:
	if camera and scope:
		if is_scoping:
			scope.current = true
			camera.current = false
			sight.show()
			
		else:
			camera.current = true
			scope.current = false
			sight.hide()
			
	
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Freelook"):
		is_free_looking = true
		
	if Input.is_action_just_released("Freelook"):
		is_free_looking = false
		neck.rotation = Vector3.ZERO
		
	var steer = Input.get_axis("right", "left")
	var move_dir = Input.get_axis("down", "up")
	
	if steer != 0 and move_dir != 0:
		for wheel in left_wheels:
			wheel.engine_force = ENGINE_POWER * (move_dir - steer)
		for wheel in right_wheels:
			wheel.engine_force = ENGINE_POWER * (move_dir + steer)
		
	if steer != 0:
		for wheel in left_wheels:
			wheel.engine_force = ENGINE_POWER * -steer * 1.2
		for wheel in right_wheels:
			wheel.engine_force = ENGINE_POWER * steer * 1.2
		left_tread.get_active_material(0).uv1_offset += $LeftWheel3.get_rpm() * Vector3(-0.002, 0, 0)
		right_tread.get_active_material(0).uv1_offset += $RightWheel3.get_rpm() * Vector3(-0.002, 0, 0)
	else:
		for wheel in left_wheels:
			wheel.engine_force = ENGINE_POWER * move_dir
		for wheel in right_wheels:
			wheel.engine_force = ENGINE_POWER * move_dir
		left_tread.get_active_material(0).uv1_offset += $LeftWheel3.get_rpm() * Vector3(-0.001, 0, 0)
		right_tread.get_active_material(0).uv1_offset += $RightWheel3.get_rpm() * Vector3(-0.001, 0, 0)
	#calculating sound or smt idk
	var pitch_increase_speed = 20.0
	var max_pitch = 20.0
	var engine_sound = linear_velocity.length() / MAX_SPEED * pitch_increase_speed +1
	engine_sound = min(engine_sound, max_pitch)
	playerIdleAudioStream.pitch_scale = engine_sound
	
	#Pause Menu
	if Input.is_action_just_pressed("Escape"):
		pauseMenu()
		
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		pause_menu.show()
		Engine.time_scale = 0
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	paused = !paused

	
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_free_looking:
			neck.rotate_y(-event.relative.x * look)
			updownview.rotate_z(-event.relative.y * look)
			updownview.rotation.z = clamp(updownview.rotation.z, deg_to_rad(-15), deg_to_rad(30))
		else:
			turret.rotate_y(-event.relative.x * SENS)
			manlet.rotate_z(-event.relative.y * ELEV)
			manlet.rotation.z = clamp(manlet.rotation.z, deg_to_rad(-10), deg_to_rad(15))
			updownview.rotation.z = manlet.rotation.z
			neck.rotation.y = 0
	
	elif event is InputEventMouseButton or InputEventKey:
		if Input.is_action_just_pressed("fire") and timer.is_stopped() and MaxAmmo > 0 and ammo and paused == false:
			fire()
		
	if timer.is_stopped() and MaxAmmo > 0:
		ammo = 1

func fire():
	var new_shell: AP = ShellAP.instantiate()
	get_tree().current_scene.add_child(new_shell)
	new_shell.initialize(barrel.global_position, barrel.global_basis.x, 800.0)
	playerShootAudioStream.play()
	# Find the UI CanvasLayer node attached to the player and give it to the bullet
	var my_ui = find_child("CanvasLayer", true, false) 
	if my_ui:
		new_shell.ui_reference = my_ui
	
	# Prevent the bullet from hitting yourself immediately out of the barrel
	if new_shell.has_node("Raycast"):
		new_shell.get_node("Raycast").add_exception(self)
		
	ammo -= 1
	MaxAmmo -= 1
	timer.start()

# Consolidated damage tracking function
func take_damage(amount: float) -> void:
	health -= amount
	playerHitAudioStream.play()
	camera.add_shake(1.2)
	scope.add_shake(1.0)
	if health <= 0:
		die()
		
func die() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/lose.tscn")
	
