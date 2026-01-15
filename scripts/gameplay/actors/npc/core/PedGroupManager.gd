extends Node3D
class_name PedGroupManager

enum GroupState {
	CONFUSED,
	TALKING,
	WALKING
}

var ped_group_owner:actor_npc = null
var peds_in_group:Array[actor_npc] = []
var peds_group_slots:Array = []

var current_group_state:GroupState = GroupState.TALKING

var detect_player_area3D := Area3D.new()
var detect_player_collision := CollisionShape3D.new()
var collision_mesh = SphereShape3D.new()

func _ready() -> void:
	collision_mesh.radius = 1.5
	
	add_child(detect_player_area3D)
	detect_player_area3D.add_child(detect_player_collision)
	
	detect_player_area3D.set_collision_mask_value(1, false)
	detect_player_area3D.set_collision_mask_value(2, true)
	detect_player_area3D.set_collision_mask_value(3, true)
	detect_player_collision.shape = collision_mesh
	
	detect_player_area3D.body_entered.connect(_on_body_entered)

func generate_circle_slots(group_size:int) -> void:
	peds_group_slots.clear()
	
	for i in range(group_size):
		var angle = TAU * (i / float(group_size))
		var pos = Vector3(cos(angle), 0, sin(angle)) * 1.0
		var slot = ActionSlot.new()
		slot.position = pos
		peds_group_slots.append(slot)
		add_child(slot)

func get_free_slot() -> ActionSlot:
	for slot in peds_group_slots:
		if not slot.is_taken:
			slot.is_taken = true
			return slot
	return null

# When player enter in the group area, the peds get out and the group is removed
func _on_body_entered(body:Node3D):
	if body is Player:
		current_group_state = GroupState.CONFUSED
		await get_tree().create_timer(1.0).timeout
		queue_free()
