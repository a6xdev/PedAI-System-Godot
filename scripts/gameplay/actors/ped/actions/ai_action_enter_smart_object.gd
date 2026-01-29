extends GOAPAction

func init(actor:ActorGoapPed) -> bool:
	return true

func execute(actor:ActorGoapPed) -> bool:
	var smart_object = actor.current_target_smart_object
	if smart_object is SmartObject:
		actor.world_state.set("ai_is_on_action", true)
		actor.world_state.set("ai_are_tired", false)
		smart_object.perform_interaction(actor)
		return true
	return false

func exit(actor:ActorGoapPed) -> void:
	actor.world_state.set("ai_at_target_location", false)
	pass

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	var valid = actor.nearby_smart_objects.size() > 0 and not actor.world_state.get("ai_is_on_action", false)
	return valid

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
		"ai_are_tired": false
	}
