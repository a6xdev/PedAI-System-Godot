extends Node
class_name PedSpawnerController

@export var SpawnerSlotsPath:Node = null
@export var SpawnerNpcPath:Node = null
@export var PedsGroupsPath:Node = null
@export var FlowAIControllerNode:FlowAIController = null
@export var PlayerRef:Player = null
@export var NpcScene:PackedScene 

@export_group("Ped Spanwer Settings")
@export var active:bool = true
@export var peds_pool_size:int = 10
@export var spawn_radius:float = 100.0
@export var despawn_radius:float = 100.0

var pathnodes:Array[FlowAIPathNode] = []
var peds_spawners:Array[PedSpawnerSlot] = []

var init_spawn_radius:float = 0.0
var init_despawn_radius:float = 0.0

#region GODOT FUNCTIONS
func _ready() -> void:
	NpcManager.PedSpawnerControllerNode = self
	
	init_spawn_radius = spawn_radius
	init_despawn_radius = despawn_radius
	
	pathnodes = FlowAIControllerNode.all_pathnodes
	
	# If I wanna put spawner manually in the map, use it.
	#for i in SpawnerSlotsPath.get_children():
		#if i is PedSpawnerSlot:
			#peds_spawners.append(i)
	
	# Spawn in SmartObjects
	var all_smart_objects = NpcManager.smart_objects
	for obj in all_smart_objects:
		for action_slot in obj.slots:
			var slot := PedSpawnerSlot.new()
			slot.ped_spawner_type = slot.SpawnerType.ACTION
			slot.smart_object = obj
			SpawnerSlotsPath.add_child(slot)
			slot.global_position = action_slot.global_position
			peds_spawners.append(slot)
	
	# Object Pooling of the NPCs
	for i in range(peds_pool_size):
		var actor_ped = NpcScene.instantiate()
		SpawnerNpcPath.add_child(actor_ped)
		actor_ped.global_position = Vector3(0.0, -10.0, 0.0)
		actor_ped.process_mode = Node.PROCESS_MODE_DISABLED
		actor_ped.visible = false
		NpcManager.all_peds.append(actor_ped)
		NpcManager.inactive_peds.append(actor_ped)
	
	# Idk a better way to spawn NPCs in appropriate locations, that was the solution.
	# Creates the PedSpawnerSlot for each Pathnode of FlowAI System
	for wp in pathnodes:
		var slot = PedSpawnerSlot.new()
		slot.ped_spawner_type = slot.SpawnerType.DEFAULT
		SpawnerSlotsPath.add_child(slot)
		slot.global_position = wp.global_position
		peds_spawners.append(slot)

func _input(event: InputEvent) -> void:
	# Reload all the NPCs to show for the public.
	if Input.is_action_just_pressed("d_reload_npcs"):
		spawn_radius = 0.5
		despawn_radius = 0.6
		await get_tree().create_timer(0.5).timeout
		for slot in peds_spawners:
			slot.reset_spawn()
		spawn_radius = init_spawn_radius
		despawn_radius = init_despawn_radius
		
func _process(delta: float) -> void:
	if active:
		# Spawner Loop
		for slot in peds_spawners:
			var dist = slot.global_position.distance_to(PlayerRef.global_position)
			
			if slot.can_spawn == false and dist <= spawn_radius:
				slot.can_spawn = decide_spawn(slot)
			
			if slot.all_peds_in_slot.size() < slot.peds_size and dist <= spawn_radius and slot.can_spawn:
				while slot.all_peds_in_slot.size() < slot.peds_size:
					var ped = get_ped()
					if ped != null:
						ped.global_position = slot.global_position
						ped.global_position.y = slot.global_position.y + 1
						slot.set_ped_spawner_slot(ped)
						await get_tree().create_timer(0.3).timeout
					else:
						break
				break
			
			if slot.all_peds_in_slot.size() > 0:
				for ped in slot.all_peds_in_slot:
					var dist_to_ped = ped.global_position.distance_to(PlayerRef.global_position)
					if dist_to_ped >= despawn_radius and ped:
						release_ped(ped)
						slot.clean_ped_spawner_slot(ped)
						slot.can_spawn = false
						break
		
		await get_tree().create_timer(0.5).timeout
#endregion

#region CALLS
func decide_spawn(slot:PedSpawnerSlot):
	var spawn_weights = {
		slot.SpawnerType.DEFAULT: 0.8,
		slot.SpawnerType.ACTION: 0.02,
	}

	return randf() < spawn_weights.get(slot.ped_spawner_type, 0.0)

## Get and active a ped
func get_ped() -> actor_npc:
	if NpcManager.inactive_peds.is_empty():
		return null
	var actor_ped = NpcManager.inactive_peds.pop_back()
	actor_ped.process_mode = Node.PROCESS_MODE_INHERIT
	actor_ped.visible = true
	actor_ped.ped_reset()
	NpcManager.active_peds.append(actor_ped)
	return actor_ped

## Disable the ped
func release_ped(ped:actor_npc) -> void:
	ped.global_position =  Vector3(0.0, -10.0, 0.0)
	ped.ped_reset()
	ped.visible = false
	NpcManager.active_peds.erase(ped)
	NpcManager.inactive_peds.append(ped)
	ped.process_mode = Node.PROCESS_MODE_DISABLED

## For PedSpawnerSlot in differents scenes. Like in the park bench.
func registry_ped_spawner(spawn:PedSpawnerSlot) -> void:
	if not peds_spawners.has(spawn):
		peds_spawners.append(spawn)
#endregion
