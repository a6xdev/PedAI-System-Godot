extends SmartObjects
class_name so_ParkBench

@onready var park_bench_event_slot_01: EventSlot = $ParkBench_EventSlot_01
@onready var park_bench_event_slot_02: EventSlot = $ParkBench_EventSlot_02

var so_slots:Array[EventSlot] = []

func _ready() -> void:
	so_slots.append_array([park_bench_event_slot_01, park_bench_event_slot_02])

func get_interaction_tasks(actor:actor_npc) -> Array[PedTask]:
	var slot:EventSlot = get_empty_slot()
	var sequence:Array[PedTask] = []
	
	if slot:
		# Task move to
		actor.current_smart_object = self
		slot.slot_owner = actor
		var t1 = new_task(PedTask.Type.MOVE_TO, slot.global_position)
		var t2 = new_task(PedTask.Type.ROTATE_TO, -slot.global_rotation.y)
		var t3 = new_task(PedTask.Type.WAIT, 2.0)
		var t4 = new_task(PedTask.Type.PLAY_ANIM, true,  "is_sitting")
		var t5 = new_task(PedTask.Type.COLLISION_DISABLED, true)
		
		sequence.append_array([t1, t2, t3, t4, t5])
	return sequence

func get_empty_slot() -> EventSlot:
	var empty_slot:EventSlot = null
	for slot in so_slots:
		if not slot.is_taken:
			slot.is_taken = true
			return slot
	return null
