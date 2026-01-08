extends SmartObjects
class_name so_ParkBench

@onready var park_bench_event_slot_01: EventSlot = $ParkBench_EventSlot_01
@onready var park_bench_event_slot_02: EventSlot = $ParkBench_EventSlot_02

var so_slots:Array[EventSlot] = []

func _ready() -> void:
	so_slots.append_array([park_bench_event_slot_01, park_bench_event_slot_01])

func get_interaction_tasks(actor:actor_npc) -> Array[PedTask]:
	var slot:EventSlot = get_empty_slot()
	var sequence:Array[PedTask] = []
	
	if slot:
		# Task move to
		var t1 = new_task(PedTask.Type.MOVE_TO, slot.global_position)
		var t2 = new_task(PedTask.Type.ROTATE_TO, Vector3(0.0, slot.global_rotation.y, 0.0))
		
		sequence.append_array([t1, t2])
	return sequence

func get_empty_slot() -> EventSlot:
	var empty_slot:EventSlot = null
	for slot in so_slots:
		if not slot.is_taken:
			slot.is_taken = true
			return slot
	return null
