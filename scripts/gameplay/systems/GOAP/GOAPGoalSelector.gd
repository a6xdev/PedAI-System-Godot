extends Node
class_name GOAPGoalSelector

var current_goal:GOAPGoal = null

func set_goal(actor:ActorGoapPed, goal:GOAPGoal) -> bool:
	current_goal = goal
	return true

func get_best_goal(actor:ActorGoapPed) -> GOAPGoal:
	var best_goal:GOAPGoal = null
	var highest_priority:float = -1.0
	
	for goal in get_children():
		if goal is GOAPGoal:
			var p = goal.get_priority()
			if p > highest_priority:
				highest_priority = p
				best_goal = goal
	
	current_goal = best_goal
	return best_goal

func get_current_goal() -> GOAPGoal:
	return current_goal
