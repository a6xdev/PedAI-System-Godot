extends GOAPAction

func init(actor:ActorGoapPed) -> bool:
	return true

func execute(actor:ActorGoapPed) -> bool:
	actor.current_target_smart_object.desperform_interaction(actor)
	return true

func exit(actor:ActorGoapPed) -> void:
	actor.world_state.set("ai_is_on_action", false)
	actor.world_state.set("ai_has_smart_object", false)

#region CALLS
func is_valid(actor:ActorGoapPed) -> bool:
	var valid = actor.world_state.get("ai_is_on_action")
	return valid

func get_cost() -> int:
	return 1

# Action requirements.
func get_preconditions() -> Dictionary:
	return {
		"ai_is_on_action": true,
	}

# What conditions this action satisfies
func get_effects() -> Dictionary:
	return {
		"ai_is_on_action": false,
	}
