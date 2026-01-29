extends StaticBody3D
class_name SmartObject

enum SmartObjectsType {
	REST,
}

var slots:Array[ActionSlot] = []

#region GODOT FUNCTIONS
func _ready() -> void:
	for child in get_children():
		if child is ActionSlot:
			slots.append(child)
#endregion

#region SYSTEM CALLS
func perform_interaction(actor:ActorGoapPed) -> bool:
	return false
	
func get_empty_slot() -> ActionSlot:
	var empty_slot:ActionSlot = null
	for slot in slots:
		if not slot.is_taken:
			empty_slot = slot
			slot.is_taken = true
			return empty_slot
	return null
#endregion
