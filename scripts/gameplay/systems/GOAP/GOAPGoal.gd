extends Node
class_name GOAPGoal

@export var GoalName:String = "AIGoal"
@export var GoalPriority:int = 1

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	return true

func get_priority() -> int:
	return GoalPriority

func get_desired_state() -> Dictionary:
	return {}
#endregion
