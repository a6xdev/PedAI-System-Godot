extends GOAPGoal

func is_valid(actor:ActorGoapPed) -> bool:
	if actor.nearby_smart_objects.size() > 0:
		var obj = actor.nearby_smart_objects.pick_random()
		var slot:ActionSlot = obj.get_empty_slot()
		
		if slot:
			actor.current_action_slot = slot
			actor.current_target_smart_object = obj
			actor.world_state.set("ai_target_position", slot.global_position)
			actor.world_state.set("ai_has_smart_object", true)
		
		return actor.world_state.get("ai_are_tired", true)
	return false

func get_desired_state() -> Dictionary:
	return {
		"ai_are_tired" = false
	}
