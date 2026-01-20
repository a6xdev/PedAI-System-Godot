extends SmartObjects
class_name so_ParkBench

@onready var park_bench_event_slot_01: ActionSlot = $ParkBench_EventSlot_01
@onready var park_bench_event_slot_02: ActionSlot = $ParkBench_EventSlot_02

@export var sit_rotation_y:float = 0.0

func start_smart_object() -> void:
	slots.append_array([park_bench_event_slot_01, park_bench_event_slot_02])

func set_start_state(actor:actor_npc, slot:ActionSlot) -> void:
	if slot:
		actor.current_smart_object = self
		actor.current_action_slot = slot
		slot.slot_owner = actor
		actor.task_rotate_to(sit_rotation_y)
		actor.task_play_anim("is_sitting", true)
		actor.task_disable_collision(true)

func get_interaction_tasks(actor:actor_npc) -> Array[PedTask]:
	var slot:ActionSlot = get_empty_slot()
	var sequence:Array[PedTask] = []
	
	if slot:
		actor.current_smart_object = self
		actor.current_action_slot = slot
		slot.slot_owner = actor
		var t1 = new_task(PedTask.Type.MOVE_TO, slot.global_position)
		var t2 = new_task(PedTask.Type.ROTATE_TO, sit_rotation_y)
		var t3 = new_task(PedTask.Type.WAIT, 2.0)
		var t4 = new_task(PedTask.Type.PLAY_ANIM, true,  "is_sitting")
		var t5 = new_task(PedTask.Type.COLLISION_DISABLED, true)
		
		sequence.append_array([t1, t2, t3, t4, t5])
	return sequence

func get_out_tasks(actor:actor_npc) -> Array[PedTask]:
	var slot = actor.current_action_slot
	var sequence:Array[PedTask] = []
	
	if slot:
		actor.current_smart_object = self
		slot.slot_owner = actor
		var t1 = new_task(PedTask.Type.PLAY_ANIM, false,  "is_sitting")
		var t2 = new_task(PedTask.Type.COLLISION_DISABLED, false)
		
		sequence.append_array([t1, t2])
	return sequence
