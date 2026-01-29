extends CharacterBody3D
class_name ActorGoapPed

@onready var flow_ai_agent: FlowAIAgent3D = $FlowAIAgent3D
@onready var goal_selector: GOAPGoalSelector = $core/GOAP/GoalSelector
@onready var action_planer: GOAPActionPlanner = $core/GOAP/ActionPlaner

enum SpeedType {
	WALK,
	RUN
}

var move_dir:Vector3 = Vector3.ZERO
var look_dir:Vector3 = Vector3.ZERO

@export var world_state:Dictionary[String, Variant] = {}

@export_group("Character Settings")
@export var ped_walk_speed:float = 2.0
@export var ped_run_speed:float = 5.0
@export var ped_rotation_speed:float = 8.0

@export_subgroup("Flags")
@export var ped_can_move:bool = true
@export var ped_can_rotate_body:bool = true
@export var can_despawn:bool = true

@export_group("Avoidance")
@export var avoidance_radius: float = 3.0
@export var avoidance_strength: float = 1.5
@export var avoidance_side_weight: float = 0.6

var is_stopped:bool = false
var is_walking:bool = false
var is_running:bool = false
var is_walking_around:bool = false

var nearby_bodies:Array[ActorGoapPed] = []

var current_speed_type:SpeedType = SpeedType.WALK
var current_target_position:Vector3 = Vector3(10.0, 0.0, 0.0)
var goap_current_plan:Array = []
var goap_current_action:GOAPAction = null

#region GODOT CALLS
func _ready() -> void:
	world_state = {
		"ai_at_target_location": false,
		"ai_walked_around": false,
		
		"ai_target_position": Vector3(10, 0, 0)
	}

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("d_action_01"):
		goap_current_plan = action_planer.make_plan(self, goal_selector.get_best_goal(self))

func _physics_process(delta: float) -> void:
	animation_controller()
	movement_controller()
	goap_controller()
#endregion

#region CONTROLLERS
func animation_controller() -> void:
	pass

func movement_controller() -> void:
	if ped_can_move:
		var avoidance_force = _get_avoidance_force()
		var final_dir = move_dir
		
		if avoidance_force != Vector3.ZERO:
			final_dir = (move_dir + avoidance_force * avoidance_side_weight).normalized()
		
		velocity = final_dir * _get_current_speed()
		move_and_slide()
	else:
		velocity = Vector3.ZERO

func orientation_controller() -> void:
	pass

func goap_controller() -> void:
	if goap_current_action == null and not goap_current_plan.is_empty():
		var action = goap_current_plan.pop_front()
		action.init(self)
		goap_current_action = action
	
	if goap_current_action:
		var finished = goap_current_action.execute(self)
		if finished:
			goap_current_action.exit(self)
			goap_current_action = null
		
#endregion

#region CALLS
func _get_avoidance_force() -> Vector3:
	var avoidance_force := Vector3.ZERO
	
	for body in nearby_bodies:
		if not is_instance_valid(body): 
			continue
			
		var to_body:Vector3 = body.global_position - global_position
		var d: float = to_body.length()
		var away = (global_position - body.global_position).normalized()
		var strength = (avoidance_radius - d) / avoidance_radius
		var side_step = away.cross(Vector3.UP) * 0.2
		
		avoidance_force += (away + side_step) * strength * avoidance_strength
			
	return avoidance_force

func _get_current_speed() -> float:
	match current_speed_type:
		SpeedType.WALK:
			return ped_walk_speed
		SpeedType.RUN:
			return ped_run_speed
	return 0.0
#endregion

#region SIGNALS
#endregion
