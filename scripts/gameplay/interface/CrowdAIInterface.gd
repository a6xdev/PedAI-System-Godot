extends CanvasLayer

@onready var fps: Label = $Interface/VBoxContainer/fps
@onready var peds: Label = $Interface/VBoxContainer/peds
@onready var active_peds: Label = $Interface/VBoxContainer/active_peds
@onready var inactive_peds: Label = $Interface/VBoxContainer/inactive_peds
@onready var spawn_radius: Label = $Interface/VBoxContainer2/spawn_radius
@onready var despawn_radius: Label = $Interface/VBoxContainer2/despawn_radius

@export var ped_spawner_controller:PedSpawnerController

func _process(delta: float) -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	peds.text = "Peds: " + str(NpcManager.all_peds.size())
	active_peds.text = "Active Peds: " + str(NpcManager.active_peds.size())
	inactive_peds.text = "Inactive Peds: " + str(NpcManager.inactive_peds.size())
	
	#spawn_radius.text = "Spawn Radius: " + str(ped_spawner_controller.spawn_radius)
	#despawn_radius.text = "Despawn Radius: " + str(ped_spawner_controller.despawn_radius)
