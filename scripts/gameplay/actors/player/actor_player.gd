extends CharacterBody3D
class_name Player

@onready var mesh: Node3D = $mesh
@onready var pivot: Node3D = $pivot
@onready var spring_arm: SpringArm3D = $pivot/SpringArm3D
@onready var camera: FreeLookCamera = $pivot/SpringArm3D/camera
@onready var trash_obj: CSGBox3D = $mesh/Rig/Skeleton3D/HandL/trash

const SMALL_TRASH = preload("res://assets/prefabs/objects/small_trash.tscn")

var look_rot = Vector3.ZERO
var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

@export_group("Character Settings")
@export var walk_speed:float = 2.0
@export var run_speed:float = 6.0
@export var crouch_speed:float = 1.0
@export var mouse_sensitivity:float = 0.01
@export var joystick_sensitivity:float = 2.0
@export_subgroup("Flags")
@export var can_move:bool = true
@export var can_run:bool = true
@export var can_move_camera:bool = true

var game_paused:bool = false
var flymode:bool = false
var run_toggle:bool = false

var is_animation_crouch_standing:bool = false
var is_animation_crouch_walking:bool = false

var is_moving:bool = false
var is_stopped:bool = false
var is_walking:bool = false
var is_running:bool = false
var in_the_air:bool = false
var is_crouching:bool = false
var is_dancing:bool = false
var is_dropping:bool = false

var current_speed:float = 0.0

#region GODOT FUNCTIONS
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_move_camera:
		look_rot.y -= event.relative.x * mouse_sensitivity
		look_rot.x -= event.relative.y * mouse_sensitivity
		look_rot.x = clamp(look_rot.x, deg_to_rad(-70.0), deg_to_rad(90.0))
	
	if Input.is_action_just_pressed("d_flymode"):
		flymode = !flymode
		
		if flymode:
			camera.reparent(pivot)
			camera.active = true
			camera.top_level = true
			can_move = false
			can_move_camera = false
		else:
			camera.reparent(spring_arm)
			camera.active = false
			camera.top_level = false
			camera.position = Vector3.ZERO
			camera.rotation = Vector3.ZERO
			can_move = true
			can_move_camera = true
	
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
		if game_paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Lets Dance!!! 🕺💃
	if Input.is_action_just_pressed("a_dance"):
		var new_event := Event.new()
		is_dancing = true
		can_move = false
		
		new_event.event_type = new_event.EventType.DANCE
		new_event.event_lifetime = 10.0
		new_event.event_radius = 5.0
		new_event.event_priority = 2
		
		add_child(new_event)
		new_event.global_position = global_position
		
		new_event.event_finished.connect(_on_event_dance_finished)
	
	if Input.is_action_just_pressed("a_drop"):
		trash_obj.show()
		is_dropping = true

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	animation_controller()
	camera_controller()
	movement_controller(delta)
	
	if not is_on_floor():
		in_the_air = true
		velocity.y -= 9.8 * delta
	else:
		in_the_air = false
#endregion

#region CONTROLLERS
func animation_controller() -> void:
	if velocity.length() < 0.5:
		is_moving = false
		is_stopped = true
		is_walking = false
		is_running = false
	else:
		is_moving = true
		if (Input.get_action_strength("m_sprint") or run_toggle and (can_run and not is_crouching)):
			is_stopped = false
			is_walking = false
			is_running = true
		else:
			is_stopped = false
			is_walking = true
			is_running = false

func camera_controller() -> void:
	if not game_paused and can_move_camera:
		var rel_yaw = look_rot.y - rotation.y
		
		spring_arm.rotation = Vector3(look_rot.x, rel_yaw, 0.0)

func movement_controller(delta:float) -> void:
	if can_move and not is_dropping:
		move_dir = Vector3(
			Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
			0.0,
			Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
		).normalized().rotated(Vector3.UP, look_rot.y)
		
		if is_walking:
			current_speed = walk_speed
		elif is_running:
			current_speed = run_speed
		else:
			current_speed = crouch_speed
		
		if move_dir != Vector3.ZERO and not in_the_air:
			var target_rot = atan2(move_dir.x, move_dir.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rot, 0.2)
		
		if not in_the_air:
			velocity.x = lerp(velocity.x, move_dir.x * current_speed, 30.0 * delta)
			velocity.z = lerp(velocity.z, move_dir.z * current_speed, 30.0 * delta)
		
		move_and_slide()
	else:
		velocity = Vector3.ZERO
#endregion

#region CALLS
func mechanic_DropTrash() -> void:
	var root = get_tree().current_scene.find_child("RuntimeCreatedBodies")
	
	var model = SMALL_TRASH.instantiate()
	root.add_child(model)
	
	model.global_position = trash_obj.global_position
	model.global_rotation = trash_obj.global_rotation
	trash_obj.hide()
#endregion

#region SIGNALS
func _on_event_dance_finished(event:Event):
	is_dancing = false
	can_move = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Interact":
		is_dropping = false
#endregion
