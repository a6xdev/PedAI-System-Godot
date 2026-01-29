extends GOAPAction

var walked_index:int = 0

func init(actor:ActorGoapPed) -> bool:
	actor.flow_ai_agent.get_random_path()
	return true

func execute(actor:ActorGoapPed) -> bool:
	var agent_target = actor.flow_ai_agent.get_next_pathnode_position()
	var direction:Vector3 = (agent_target - actor.global_position).normalized()
	
	actor.move_dir = direction
	
	if actor.flow_ai_agent.is_path_complete():
		if walked_index > 2:
			actor.world_state.set("ai_walked_around", true)
			return true
		else:
			actor.flow_ai_agent.get_random_path()
			walked_index += 1
	
	return false

func exit(actor:ActorGoapPed) -> bool:
	actor.world_state.set("ai_walked_around", false)
	walked_index = 0
	return true

#region CALLS
func is_valid() -> bool:
	return true

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {
		"ai_walked_around": false
	}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {
		"ai_walked_around": true
	}
#endregion
