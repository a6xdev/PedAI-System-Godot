extends Area3D
class_name Event

enum EventType {
	NONE,
	DANCE,
	AGRESSION
}

@export var event_priority:int = 1
@export var event_radius:float = 10.0
@export var inner_radius: float = 2.0
@export var event_lifetime:float = 1.0
@export var event_max_slots:int = 5
@export var event_type:EventType = EventType.NONE

var event_owner:CharacterBody3D = null
var event_origin := Vector3.ZERO
var event_involved_npcs:Array[actor_npc] = []
var event_stop_slots:Array[ActionSlot] = []

var collision := CollisionShape3D.new()
var collision_shape = SphereShape3D.new()

signal event_started
signal event_finished(event:Event)

#region GODOT FUNCTIONS
func _ready() -> void:
	event_origin = global_position
	top_level = true
	
	collision_shape.radius = event_radius
	collision.debug_color = Color("#e30202cf")
	collision.shape = collision_shape
	
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	
	add_child(collision)
	
	match event_type:
		EventType.DANCE:
			generate_random_slots()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _process(delta: float) -> void:
	# Timer to finish event
	await get_tree().create_timer(event_lifetime).timeout
	emit_signal("event_finished", self)
	queue_free()
#endregion

#region CALLS
func generate_random_slots() -> void:
	for node in event_stop_slots:
		node.queue_free()
	
	event_stop_slots.clear()
	for i in range(event_max_slots):
		var angle = randf() * TAU
		var r = sqrt(randf()) * (event_radius - inner_radius) + inner_radius
		var pos = Vector3(cos(angle), 0, sin(angle)) * r
		var slot = ActionSlot.new()
		slot.position = pos
		event_stop_slots.append(slot)
		add_child(slot)

func generate_circle_slots() -> void:
	event_stop_slots.clear()
	for i in range(event_max_slots):
		var angle = TAU * (i / float(event_max_slots))
		var pos = Vector3(cos(angle), 0, sin(angle)) * inner_radius
		var slot = ActionSlot.new()
		slot.position = pos
		event_stop_slots.append(slot)
		add_child(slot)

func get_free_slot() -> ActionSlot:
	for slot in event_stop_slots:
		if not slot.is_taken:
			slot.is_taken = true
			return slot
	return null

#endregion

#region SIGNALS
func _on_body_entered(body:Node3D):
	if body is actor_npc and body != event_owner:
		var raycast = RayCast3D.new()
		add_child(raycast)
		raycast.target_position = body.position - global_position
		
		raycast.set_collision_mask_value(1, true)
		raycast.set_collision_mask_value(2, true)
		raycast.set_collision_mask_value(3, true)
		
		await get_tree().process_frame
		
		if raycast.is_colliding() and raycast.get_collider() is CharacterBody3D:
			body.stimulus_controller.set_event(self)
		
		await get_tree().create_timer(1.0).timeout
		raycast.queue_free()
		
		#event_involved_npcs.append(body)
func _on_body_exited(body:Node3D):
	if body is actor_npc:
		#body.is_on_event = false
		#body.stimulus_controller.current_event = null
		if event_involved_npcs.has(body):
			event_involved_npcs.erase(body)
#endregion
