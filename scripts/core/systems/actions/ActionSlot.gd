extends Marker3D
class_name ActionSlot

var is_taken:bool = false
var slot_owner:CharacterBody3D = null

func _ready() -> void:
	#top_level = true
	
	if World.is_debugging:
		var w_mesh := MeshInstance3D.new()
		var w_mesh_material := StandardMaterial3D.new()

		w_mesh_material.albedo_color = Color(1, 0, 0)
		w_mesh.mesh = BoxMesh.new()
		w_mesh.mesh.size = Vector3(0.1, 0.1, 0.1)
		w_mesh.set_surface_override_material(0, w_mesh_material)
		
		add_child(w_mesh)

func _process(delta: float) -> void:
	DebugDraw3D.draw_sphere(global_position, 0.2, Color(0, 0, 1))
