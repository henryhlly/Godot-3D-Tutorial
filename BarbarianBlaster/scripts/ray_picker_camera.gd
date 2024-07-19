extends Camera3D

@export var grid_map: GridMap

@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Get cursor position relative to viewport
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	# Fire ray normal to camera with distance 100
	ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * 100.0
	ray_cast_3d.force_raycast_update()
	
	if ray_cast_3d.is_colliding:
		# Get what the ray is colliding with
		var collider = ray_cast_3d.get_collider()
		if collider is GridMap:
			# Get global point where ray has collided
			var collision_point = ray_cast_3d.get_collision_point()
			# Get the position in terms of grid map cells
			var cell = grid_map.local_to_map(collision_point)
			
			# Check if colliding cell is the free space
			if grid_map.get_cell_item(cell) == 0:
				# Change the cell to the turret space
				grid_map.set_cell_item(cell, 1)
