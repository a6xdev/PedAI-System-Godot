extends GOAPAction

func init(actor:ActorGoapPed) -> bool:
	return true

func execute(actor:ActorGoapPed) -> bool:
	var smart_object = actor.world_state.get("ai_target_smart_object")
	if smart_object is SmartObject:
		smart_object.perform_interaction(actor)
		return true
	return true

func exit(actor:ActorGoapPed) -> bool:
	return true

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	return actor.nearby_smart_objects.size() > 0

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {
		"ai_at_target_location": true,
	}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {
		"ai_has_smart_object": true,
		"ai_are_tired": false
	}
