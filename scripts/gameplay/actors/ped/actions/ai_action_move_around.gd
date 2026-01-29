extends GOAPAction

var walked_index:int = 0

func init(actor:ActorGoapPed) -> bool:
	actor.flow_ai_agent.get_random_path()
	return true

func execute(actor:ActorGoapPed) -> bool:
	var agent_target = actor.flow_ai_agent.get_next_pathnode_position()
	actor.move_dir = (agent_target - actor.global_position).normalized()
	
	if actor.flow_ai_agent.is_path_complete():
		if walked_index > 2:
			actor.world_state.set("ai_walked_around", true)
			actor.world_state.set("ai_are_tired", true)
			return true
		else:
			actor.flow_ai_agent.get_random_path()
			walked_index += 1
	
	return false

func exit(actor:ActorGoapPed) -> void:
	actor.world_state.set("ai_walked_around", false)
	actor.move_dir = Vector3.ZERO
	walked_index = 0

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	return true

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {
		"ai_walked_around": false,
		"ai_is_on_action": false,
	}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {
		"ai_walked_around": true
	}
#endregion
