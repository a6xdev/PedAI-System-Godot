extends GOAPAction

func init(actor:ActorGoapPed) -> bool:
	return true

func execute(actor:ActorGoapPed) -> bool:
	var location_target = actor.world_state.get("ai_target_position")
	
	if actor.flow_ai_agent.target_position != location_target:
		actor.flow_ai_agent.set_target_position(location_target)
	
	var agent_target = actor.flow_ai_agent.get_next_path_position()
	actor.move_dir = (agent_target - actor.global_position).normalized()
	
	if actor.flow_ai_agent.is_navigation_finished():
		actor.world_state.set("ai_at_target_location", true)
		actor.global_position = Vector3(location_target.x, actor.global_position.y, location_target.z)
		
		return true
	
	return false

func exit(actor:ActorGoapPed) -> bool:
	actor.move_dir = Vector3.ZERO
	return true

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	return true

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {
		"ai_at_target_location": false
	}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {
		"ai_at_target_location": true
	}
