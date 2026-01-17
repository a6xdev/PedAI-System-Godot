extends CharacterBody3D
class_name actor_npc

@onready var mesh: Node3D = $mesh
@onready var collision: CollisionShape3D = $collision
@onready var head_look_at: LookAtModifier3D = $mesh/Rig/Skeleton3D/HeadLookAt
@onready var head_target: Node3D = $mesh/Rig/Skeleton3D/HeadLookAt/HeadTarget
@onready var flow_ai_agent: FlowAIAgent3D = $FlowAIAgent3D
@onready var stimulus_controller: ped_stimulus_controller = $core/stimulus_controller
@onready var mannequin_mesh: MeshInstance3D = $mesh/Rig/Skeleton3D/Mannequin
@onready var animation_player: AnimationPlayer = $mesh/AnimationPlayer
@onready var animation_tree: AnimationTree = $mesh/AnimationTree

# Debug Meshes
@onready var d_movement_target: MeshInstance3D = $debug/DMovementTarget

enum PedType {
	WANDER,
	SCENARIO,
}

enum PathType {
	DEFAULT,
	EVENT,
}

enum TurnType {
	FORWARD,
	BACKWARD,
	LEFT,
	RIGHT
}

@export_group("Character Settings")
@export var ped_walk_speed:float = 2.0
@export var ped_run_speed:float = 5.0
@export var ped_rotation_speed:float = 8.0

@export_subgroup("Flags")
@export var ped_can_move:bool = true
@export var ped_can_rotate_body:bool = true

@export_group("Avoidance")
@export var avoidance_radius: float = 3.0
@export var avoidance_strength: float = 1.5 if is_following_group_leader else 3.0
@export var avoidance_side_weight: float = 0.6

var is_stopped:bool = false
var is_walking:bool = false
var is_running:bool = false
var is_dancing:bool = false
var is_talking:bool = false
var is_sitting:bool = false
var is_fixing_kneeling:bool = false
var is_leaning_wall_back:bool = false
var is_in_group:bool = false
var in_on_event:bool = false
var is_on_action:bool = false
var is_going_to_event_slot:bool = false
var is_stopped_on_event:bool = false
var is_following_group_leader:bool = false
var has_movement_task:bool = false

# Tasks:
var task_is_moving_to_local:bool = false
var cancel_current_task:bool = false
var wait_timer:float = 0.0

var want_socialize:bool = false
var want_sit:bool = false

var current_ped_type:PedType = PedType.WANDER
var current_event:Event = null
var current_speed:float = 0.0
var current_group:PedGroupManager = null
var current_task:PedTask
var current_smart_object:SmartObjects = null
var current_action_slot:ActionSlot = null

var rotation_action_target:float = 0.0
var look_current_path_target := Vector3.ZERO
var look_current_event_target := Vector3.ZERO
var look_current_group_center_target := Vector3.ZERO
var look_current_target := Vector3.ZERO

var tasks_queue:Array[PedTask] = []

var nearby_bodies:Array[CharacterBody3D] = []
var nearby_smart_objects:Array[SmartObjects] = []

signal task_finished(task_type:PedTask.Type)

#region GODOT FUNCTIONS
func _ready() -> void:
	randomize()
	var material_0 := StandardMaterial3D.new()
	var material_1 := StandardMaterial3D.new()
	
	material_0.albedo_color = get_random_color()
	material_1.albedo_color = get_random_color()
	
	mannequin_mesh.set_surface_override_material(0, material_0)
	mannequin_mesh.set_surface_override_material(1, material_1)

func _process(delta: float) -> void:
	match current_ped_type:
		PedType.WANDER:
			current_speed = ped_walk_speed
		PedType.SCENARIO:
			current_speed = 0.0
	
	process_tasks()

func _physics_process(delta: float) -> void:
	animation_controller()
	movement_controller(delta)
	orientation_controller(delta)
	social_controller()
	
	if Input.is_action_just_pressed("d_action_01"):
		if not nearby_smart_objects.is_empty():
			var tasks_sequence = nearby_smart_objects.pick_random().get_interaction_tasks(self)
			for task in tasks_sequence:
				if task: tasks_queue.append(task)
	
	if not is_on_floor() and is_in_group and is_following_group_leader:
		velocity.y -= 9.8 * delta
#endregion

#region CONTROLLER
func animation_controller() -> void:
	if velocity.length() < 0.1:
		is_stopped = true
		is_walking = false
		is_running = false
	elif velocity.length() > ped_walk_speed + 0.5:
		is_stopped = false
		is_walking = false
		is_running = true
	else:
		is_stopped = false
		is_walking = true
		is_running = false
	
func movement_controller(delta:float) -> void:
	if ped_can_move and not is_stopped_on_event and not is_talking and not is_sitting and not is_leaning_wall_back:
		if flow_ai_agent.is_navigation_finished(): # Native Pathfinding
			if is_going_to_event_slot:
				is_going_to_event_slot = false
				is_stopped_on_event = true
				
		if flow_ai_agent.is_path_complete() and not is_going_to_event_slot: # FlowAI
			# TODO: Look for any action near it
			flow_ai_agent.get_random_path()
		
		var crowd_target:Vector3 = flow_ai_agent.get_next_pathnode_position()
		var pathfinding_target:Vector3 = flow_ai_agent.get_next_path_position()
		var target:Vector3 = Vector3.ZERO
		
		if is_following_group_leader and current_group and current_group.ped_group_owner and current_group.ped_group_owner != self and current_group.peds_group_slots.size() > 1:
			var gop = current_group.ped_group_owner.global_position # group_owner_position
			var idx = current_group.peds_in_group.find(self)
			var spacing = 1.5
			var row = idx / 3
			var col = idx % 3
			var offset = Vector3((col - 1) *  spacing, 0, row * spacing + 1.5)
			target = gop + offset
		elif is_going_to_event_slot:
			target = pathfinding_target
		else:
			target = crowd_target
		
		if not has_movement_task and not is_on_action:
			# When the Ped finish your action. The Smart Object is responsible for the Ped return to Flow AI movement. For now...
			var target_pos = flow_ai_agent.get_next_pathnode_position()
			var task = new_task(PedTask.Type.MOVE_TO, target_pos)
			has_movement_task = true
		
		move_and_slide()
	else:
		velocity = Vector3.ZERO
	
func orientation_controller(delta:float) -> void:
	var body_target_rot = rotation.y
	
	if ped_can_rotate_body and not is_sitting and not is_leaning_wall_back:
		if current_group and current_group.current_group_state == current_group.GroupState.TALKING:
			var to_target = (current_group.global_position - global_position).normalized()
			if to_target:
				body_target_rot = atan2(to_target.x, to_target.z)
		else:
			if is_stopped and is_on_action:
				body_target_rot = rotation_action_target
			elif not is_stopped_on_event:
				var to_target = (look_current_path_target - global_position).normalized()
				if to_target:
					body_target_rot = atan2(to_target.x, to_target.z)
			else:
				var to_target = (look_current_event_target - global_position).normalized()
				if to_target:
					body_target_rot = atan2(to_target.x, to_target.z)
					
		rotation.y = lerp_angle(rotation.y, body_target_rot, ped_rotation_speed * delta)
	
	if in_on_event and current_event:
		head_look_at.active = true
		head_target.top_level = true
		head_target.global_position = current_event.global_position
	else:
		head_look_at.active = false
		head_target.top_level = false
		head_target.position = Vector3(0.0, 1.3, 1.0)

func social_controller() -> void:
	if current_group:
		is_in_group = true
		match current_group.current_group_state:
			current_group.GroupState.CONFUSED:
				is_talking = false
			current_group.GroupState.TALKING:
				if current_group.peds_in_group.size() > 1:
					is_talking = true
			current_group.GroupState.WALKING:
				is_following_group_leader = true
				is_talking = false
	else:
		is_in_group = false
		is_following_group_leader = false
		is_talking = false

func process_tasks() -> void:
	if tasks_queue.is_empty(): return
	
	if wait_timer > 0:
		wait_timer -= get_physics_process_delta_time()
		return
	
	current_task = tasks_queue[0]
	var task_finished:bool = false
	
	if current_task:
		is_on_action = true if current_task.is_action else false
		
		match current_task.type:
			PedTask.Type.MOVE_TO:
				if task_move_to(current_task.target_value, is_on_action):
					has_movement_task = false
					task_finished = true
			PedTask.Type.ROTATE_TO:
				task_finished = task_rotate_to(current_task.target_value)
			PedTask.Type.PLAY_ANIM:
				task_play_anim(current_task.target_name, current_task.target_value)
				task_finished = true
			PedTask.Type.WAIT:
				wait_timer = current_task.target_value
				task_finished = true
			PedTask.Type.COLLISION_DISABLED:
				collision.disabled = current_task.target_value
				task_finished = true
		
		if task_finished:
			tasks_queue.pop_front()
#endregion

#region TASKS
func task_move_to(local:Vector3, use_pathfinding:bool = false) -> bool:
	var dist:float = global_position.distance_to(local)
	var dist_min = 1.5
	
	if use_pathfinding and flow_ai_agent.target_position != local:
		flow_ai_agent.target_position = local
	
	draw_debug_movement_target(local, dist)
	
	var target_pos = flow_ai_agent.get_next_path_position() if use_pathfinding else local
	var avoidance_force:Vector3 = get_avoidance_force()
	var direction:Vector3 = (target_pos - global_position).normalized()
	var final_dir:Vector3 = direction
	
	# this shit arrived
	if dist <= dist_min or cancel_current_task:
		# Verify if the next task is a MOVE_TO. If not, stop of moving.
		if tasks_queue.size() > 1 and not tasks_queue[1].type == PedTask.Type.MOVE_TO: velocity = Vector3(0.0, velocity.y, 0.0)
		if use_pathfinding: global_position = Vector3(target_pos.x, global_position.y, target_pos.z)
		return true
	
	if avoidance_force != Vector3.ZERO and not is_following_group_leader and not is_on_action:
		final_dir = (direction + avoidance_force * avoidance_side_weight).normalized()
	
	velocity = final_dir * current_speed
	look_current_path_target = (global_position + final_dir)
	return false

func task_rotate_to(value:float) -> bool:
	rotation_action_target = value
	return true

func task_play_anim(target_name:String, value:bool) -> bool:
	self.set(target_name, value)
	return true
#endregion

#region DEBUG CALLS
func draw_debug_movement_target(pos:Vector3, dist:float) -> void:
	d_movement_target.global_position = Vector3(pos.x, 1.0, pos.z)
	$debug/DMovementTarget/dist_label.text = "Dist: " + str(int(dist)) + " m"
#endregion

#region CALLS
func new_task(type:PedTask.Type, value:Variant) -> PedTask:
	var new_task = PedTask.new()
	new_task.type = type
	new_task.target_value = value
	tasks_queue.append(new_task)
	return 

func get_avoidance_force() -> Vector3:
	var avoidance_force := Vector3.ZERO
	
	for body in nearby_bodies:
		if not is_instance_valid(body): 
			continue
			
		var to_body:Vector3 = body.global_position - global_position
		var d: float = to_body.length()
		var away = (global_position - body.global_position).normalized()
		var strength = (avoidance_radius - d) / avoidance_radius
		
		avoidance_force += away * strength * avoidance_strength
			
	return avoidance_force
	
func navigation_set_event_path(path_type:PathType, position:Vector3) -> void:
	flow_ai_agent.set_target_position(position)
	match path_type:
		PathType.DEFAULT:
			pass
		PathType.EVENT:
			is_going_to_event_slot = true

func ped_reset():
	look_current_path_target = Vector3.ZERO
	look_current_group_center_target = Vector3.ZERO
	look_current_event_target = Vector3.ZERO
	global_rotation = Vector3.ZERO
	current_group = null
	is_in_group = false
	is_following_group_leader = false
	ped_can_move = true
	ped_can_rotate_body = true
	is_sitting = false
	is_leaning_wall_back = false
	is_dancing = false
	animation_tree.get("parameters/playback").start("Idle")
	if current_action_slot:
		current_action_slot.is_taken = false
		current_action_slot.slot_owner = null

func get_random_color() -> Color:
	return Color(randf(), randf(), randf(), 1.0)
#endregion

#region SIGNALS
func _on_detect_nearby_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		if not nearby_bodies.has(body):
			nearby_bodies.append(body)

func _on_detect_nearby_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if nearby_bodies.has(body):
			nearby_bodies.erase(body)

func _on_detect_nearby_smart_objects_body_entered(body: Node3D) -> void:
	if body is SmartObjects:
		nearby_smart_objects.append(body)

func _on_detect_nearby_smart_objects_body_exited(body: Node3D) -> void:
	if body is SmartObjects:
		nearby_smart_objects.erase(body)
#endregion
