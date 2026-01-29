extends Node
class_name GOAPAction

@export var ActionName:String = "AIGoal"
@export var ActionPriority:int = 1

#region FUNCTIONS BASE
func init(actor:ActorGoapPed) -> bool:
	return true

func execute(actor:ActorGoapPed) -> bool:
	return false

func exit(actor:ActorGoapPed) -> bool:
	return true
#endregion

#region CALLS
func is_valid() -> bool:
	return true

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {}
#endregion
