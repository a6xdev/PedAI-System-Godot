extends Resource
class_name PedTask

enum Type {
	MOVE_TO,
	ROTATE_TO,
	PLAY_ANIM,
	WAIT,
	TALK,
	COLLISION_DISABLED
}

@export var type:Type
@export var target_name:String = ""
@export var target_value:Variant
@export var is_action:bool = false
