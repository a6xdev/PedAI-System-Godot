extends Node
class_name GOAPActionPlanner

func make_plan(actor:ActorGoapPed, goal:GOAPGoal) -> Array:
	var plan:Array = []
	var world_state = actor.world_state
	var desired_state = goal.get_desired_state()
	
	if _in_state(desired_state, world_state):
		return []
	
	plan = _build_path(actor, desired_state, world_state, 5)
	
	for action in plan:
		print(action.ActionName)
	
	return plan

func _build_path(actor:ActorGoapPed, target_state:Dictionary, current_state:Dictionary, depth:int) -> Array:
	if depth > 10:
		return []
	
	if _in_state(target_state, current_state): return []
	
	for action in get_children():
		if action is GOAPAction:
			var requirements = action.get_preconditions()
			var sub_plan = _build_path(actor, requirements, current_state, depth + 1)
			
			if sub_plan != null:
				var full_plan = sub_plan
				full_plan.append(action)
				return full_plan
			
	return []

func _in_state(desired:Dictionary, current:Dictionary) -> bool:
	for key in desired:
		if current.get(key) != desired[key]:
			return false
	return true
