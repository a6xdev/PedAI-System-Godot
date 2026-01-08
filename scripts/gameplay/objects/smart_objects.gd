extends StaticBody3D
class_name SmartObjects

var tasks_queue:Array[PedTask] = []

func get_interaction_tasks(actor:actor_npc) -> Array[PedTask]:
	return []

func new_task(type:PedTask.Type, value:Variant) -> PedTask:
	var new_task = PedTask.new()
	new_task.type = type
	new_task.target_value = value
	new_task.is_action = true
	tasks_queue.append(new_task)
	return new_task
