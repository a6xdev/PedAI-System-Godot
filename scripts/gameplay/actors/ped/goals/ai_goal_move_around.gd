extends GOAPGoal

func is_valid(actor:ActorGoapPed) -> bool:
	return actor.world_state.has("ai_target_position") and not actor.world_state.get("ai_at_target_location", false)

func get_desired_state() -> Dictionary:
	return {
		"ai_walked_around" = true
	}
