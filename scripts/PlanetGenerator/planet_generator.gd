@tool
extends Node3D

@export_tool_button("Generate Sphere") var sphere_plugin = func():
	var sphere = MeshInstance3D.new()
	sphere.mesh = generate_sphere(
		radius,
		subdivisions_per_edge,
		using_noise,
		noise_layers,
	)
	sphere.name = planet_name
	self.add_child(sphere)
	sphere.owner = self
	dynamic_preview = false

@export_tool_button("Force Update Preview") var preview_plugin = func():
	if (dynamic_preview): dynamic_preview_object_generator.call()

@export_group("Planet General")

@export var radius: float = 1.0:
	set(v):
		radius = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var subdivisions_per_edge: int = 8:
	set(v):
		subdivisions_per_edge = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var planet_name: String = "Planet"
@export var dynamic_preview: bool = false:
	set(v):
		dynamic_preview = v
		dynamic_preview_object.visible = v

var dynamic_preview_object = MeshInstance3D.new()

var dynamic_preview_object_generator = func():
	dynamic_preview_object.mesh = generate_sphere(
		radius,
		subdivisions_per_edge,
		using_noise,
		noise_layers,
	)
	dynamic_preview_object.name = planet_name

@export_group("Planet Terrain")

@export var using_noise: bool = false:
	set(v):
		using_noise = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var noise_layers: Array[NoiseLayer] = []:
	set(v):
		noise_layers = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

#@export var use_heightmap_noise: bool = false

#@export var use_color_noise: bool = false

func generate_face(side_square_count: int, uv_position: Vector2) -> Mesh:
	# Create the mesh for a single face.
	# This mesh faces forward
	var face = SurfaceTool.new()
	face.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Verticies must be added in a clockwise order to appear on screen.
	
	# The UV's are formatted like this:
	#		T
	#	L	F	R	Bck
	#		B
	# This means that we have to divide u by 4 and v by 3
	# Ex:
	#	      # Divide by 4             # Divide by 3
	# Vector2(0.25 / side_square_count, (1.0 / 3.0) / side_square_count)
	
	# Triangle 1
	# Top Left	
	face.set_uv(uv_position)
	face.add_vertex(Vector3(0.0, 0.0, 0.0))
	# Top Right
	face.set_uv(uv_position + Vector2( 0.25 / side_square_count, 0.0))
	face.add_vertex(Vector3(1.0 / side_square_count, 0.0, 0.0))
	# Bottom Left
	face.set_uv(uv_position + Vector2(0.0, (1.0 / 3.0) / side_square_count))
	face.add_vertex(Vector3(0.0, -1.0 / side_square_count, 0.0))
	# Triangle 2
	# Top Right (again)
	face.set_uv(uv_position + Vector2(0.25 / side_square_count, 0.0))
	face.add_vertex(Vector3(1.0 / side_square_count, 0.0, 0.0))
	# Bottom Right
	face.set_uv(uv_position + Vector2(0.25 / side_square_count, (1.0 / 3.0) / side_square_count))
	face.add_vertex(Vector3(1.0 / side_square_count, -1.0 / side_square_count, 0.0))
	# Bottom Left (again)
	face.set_uv(uv_position + Vector2(0.0, (1.0 / 3.0) / side_square_count))
	face.add_vertex(Vector3(0.0, -1.0 / side_square_count, 0.0))
	
	return face.commit()

func generate_sphere(
	rad: float,
	side_square_count: int,
	noise: bool = false,
	layers: Array[NoiseLayer] = [],
	):
	
	var sphere = SurfaceTool.new()
	sphere.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var generate_side = func(
		p: Vector3,
		r: Basis,
		uvc: Vector2,
		ud: Vector3,
		vd: Vector3):
		for u in range(side_square_count):
			for v in range(side_square_count):
				var face = generate_face(side_square_count,
					uvc + Vector2(
						(float(u) / side_square_count) / 4.0,
						(float(v) / side_square_count) / 3.0
					)
				)
				
				sphere.append_from(face, 0, Transform3D(
					r,
					p +
					ud * (float(u) / side_square_count) +
					vd * (float(v) / side_square_count)
				))
	
	# Create variables to make it easier to generate each face
	
	# Generate top face
	generate_side.call(
		Vector3(-0.5, 0.5, -0.5), 	# Start in back left corner
		Basis(Vector3.RIGHT, deg_to_rad(-90)), # Make quad face up
		Vector2(0.25, 0.0), 		# Top face in the normal
		Vector3(1.0, 0.0, 0.0), 	# +X; Right
		Vector3(0.0, 0.0, 1.0) 		# +Z; Forward
	)
	
	# Generate left face
	generate_side.call(
		Vector3(-0.5, 0.5, -0.5), 	# Start in back left corner
		Basis(Vector3.UP, deg_to_rad(-90)), # Make quad face left
		Vector2(0.0, (1.0/3.0)), 	# Left face in the normal
		Vector3(0.0, 0.0, 1.0), 	# +Z; Forward
		Vector3(0.0, -1.0, 0.0) 	# -Y; Down
	)
	
	# Generate front face
	generate_side.call(
		Vector3(-0.5, 0.5, 0.5), 	# Start in front left corner
		Basis.IDENTITY, 			# No rotation needed
		Vector2(0.25, (1.0/3.0)), 	# Front face in the normal
		Vector3(1.0, 0.0, 0.0), 	# +X; Right
		Vector3(0.0, -1.0, 0.0) 	# -Y; Down
	)
	
	# Generate right face
	generate_side.call(
		Vector3(0.5, 0.5, 0.5), 	# Start in front right corner
		Basis(Vector3.UP, deg_to_rad(90)), 	# Make quad face right
		Vector2(0.5, (1.0/3.0)), 	# Right face in the normal
		Vector3(0.0, 0.0, -1.0), 	# -Z; Backward
		Vector3(0.0, -1.0, 0.0) 	# -Y; Down
	)
	
	# Generate back face
	generate_side.call(
		Vector3(0.5, 0.5, -0.5), 	# Start in back right corner
		Basis(Vector3.UP, deg_to_rad(180)), 	# Flip quad around
		Vector2(0.75, (1.0/3.0)), 	# Back face in the normal
		Vector3(-1.0, 0.0, 0.0), 	# -X; Left
		Vector3(0.0, -1.0, 0.0) 	# -Y; Down
	)
	
	# Generate bottom face
	generate_side.call(
		Vector3(-0.5, -0.5, 0.5), 	# Start in Front (bottom) left corner
		Basis(Vector3.RIGHT, deg_to_rad(90)), 	# Make quad face down
		Vector2(0.25, (2.0/3.0)), 	# Bottom face in the normal
		Vector3(1.0, 0.0, 0.0), 	# +X; Right
		Vector3(0.0, 0.0, -1.0) 	# -Z; Backward
	)
	
	var mesh: Array = sphere.commit_to_arrays()
	
	# Turn the cube into a sphere by normalizing each vertex,
	# making the verticies' distance from the origin the same
	# (AKA the definition of a sphere)
	for index in mesh[Mesh.ARRAY_VERTEX].size():
		mesh[Mesh.ARRAY_VERTEX][index] = mesh[Mesh.ARRAY_VERTEX][index].normalized()
		
		# We are not adding the normal quite yet.
		# This value becomes wrong after applying noise.
		#mesh[Mesh.ARRAY_NORMAL].append(mesh[Mesh.ARRAY_VERTEX][index]) # Add normal
	
	# Iterate through the verticies again.
	# This time, we multiply them by the vertex's
	# height in order to get the sphere to the right
	# size and radius according to the heightmap
	for index in mesh[Mesh.ARRAY_VERTEX].size():
		var copied_vertex = mesh[Mesh.ARRAY_VERTEX][index]
		
		var height = rad
		if (noise):
			for layer in layers:
				var noise_value = layer.noise_generator.get_noise_3dv(copied_vertex)
				# Apply the noise layer's sampling curve
				height += layer.noise_control.sample(noise_value)
		# Multiply by the radius to get the right length
		mesh[Mesh.ARRAY_VERTEX][index] *= height
	
	var normals := SurfaceTool.new()
	
	normals.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	normals.create_from_arrays(mesh)
	
	normals.generate_normals()
	
	return normals.commit()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dynamic_preview_object.name = "Dynamic Preview"
	self.add_child(dynamic_preview_object)
	pass # Replace with function body.
