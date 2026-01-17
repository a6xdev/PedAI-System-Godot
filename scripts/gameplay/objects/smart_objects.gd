extends StaticBody3D
class_name SmartObjects

var tasks_queue:Array[PedTask] = []
var slots:Array[ActionSlot] = []

#region GODOT FUNCTIONS
func _ready() -> void:
	NpcManager.smart_objects.append(self)
	start_smart_object()
#endregion

#region SYSTEM CALLS
func start_smart_object() -> void:
	pass
	
func get_default_tasks(actor:actor_npc, slot:ActionSlot) -> Array[PedTask]:
	return []

func get_interaction_tasks(actor:actor_npc) -> Array[PedTask]:
	return []

func get_out_tasks(actor:actor_npc) -> Array[PedTask]:
	return []

func new_task(type:PedTask.Type, target_value:Variant, target_name:String = "") -> PedTask:
	var new_task = PedTask.new()
	new_task.type = type
	new_task.target_name = target_name
	new_task.target_value = target_value
	new_task.is_action = true
	tasks_queue.append(new_task)
	return new_task

func get_empty_slot() -> ActionSlot:
	var empty_slot:ActionSlot = null
	for slot in slots:
		if not slot.is_taken:
			empty_slot = slot
			slot.is_taken = true
			return empty_slot
	return null
#endregion
