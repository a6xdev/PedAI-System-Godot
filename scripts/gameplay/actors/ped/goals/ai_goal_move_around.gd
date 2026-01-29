extends GOAPGoal

func is_valid(actor:ActorGoapPed) -> bool:
	return true

func get_desired_state() -> Dictionary:
	return {
		"ai_walked_around" = true
	}
