extends StaticBody3D
class_name SmartObjects

var tasks_queue:Array[PedTask] = []
var slots:Array[ActionSlot] = []

#region SYSTEM CALLS
func get_default_tasks(actor:actor_npc, slot:ActionSlot) -> Array[PedTask]:
	return []

func get_interaction_tasks(actor:actor_npc) -> Array[PedTask]:
	return []

func new_task(type:PedTask.Type, target_value:Variant, target_name:String = "") -> PedTask:
	var new_task = PedTask.new()
	new_task.type = type
	new_task.target_name = target_name
	new_task.target_value = target_value
	new_task.is_action = true
	tasks_queue.append(new_task)
	return new_task
#endregion
