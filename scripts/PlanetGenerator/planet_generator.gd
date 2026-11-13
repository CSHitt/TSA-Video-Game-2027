@tool
extends Node3D

var planet_shader := load("res://shaders/planet.gdshader")
var hq_planet_shader := load("res://shaders/planet_hq.gdshader")
var water_shader := load("res://shaders/water.gdshader")

@export_tool_button("Generate Sphere") var sphere_plugin = func():
	var planet = Node3D.new()
	planet.name = planet_name
	
	self.add_child(planet)
	planet.owner = self
	
	var terrain = MeshInstance3D.new()
	terrain.name = "Terrain"
	terrain.mesh = generate_sphere(
		radius,
		subdivisions_per_edge,
		true,
		noise_layers
	)
	
	if using_terrain_shader:
		var terrain_material := ShaderMaterial.new()
		terrain_material.shader = 	hq_planet_shader if using_high_quality_terrain else planet_shader
		terrain_material.set_shader_parameter("minimum_radius", radius)
		terrain_material.set_shader_parameter("maximum_radius", maximum_radius)
		terrain_material.set_shader_parameter("grass_threshold", grass_threshold)
		if using_high_quality_terrain:
			terrain_material.set_shader_parameter("texture_scale", texture_scale)
			terrain_material.set_shader_parameter("normal_strength", normal_strength)
			terrain_material.set_shader_parameter("grass_texture", grass_texture)
			terrain_material.set_shader_parameter("grass_normal_texture", grass_normal_texture)
			terrain_material.set_shader_parameter("stone_texture", stone_texture)
			terrain_material.set_shader_parameter("stone_normal_texture", stone_normal_texture)
			terrain_material.set_shader_parameter("sand_texture", sand_texture)
			terrain_material.set_shader_parameter("sand_normal_texture", sand_normal_texture)
		else:
			terrain_material.set_shader_parameter("grass_color", grass_color)
			terrain_material.set_shader_parameter("stone_color", stone_color)
			terrain_material.set_shader_parameter("sand_color", sand_color)
			terrain_material.set_shader_parameter("grass_curve", grass_curve)
			terrain_material.set_shader_parameter("stone_curve", stone_curve)
			terrain_material.set_shader_parameter("sand_curve", sand_curve)
		terrain.material_override = terrain_material
	else:
		terrain.material_override = null
	
	if using_water:
		var water = MeshInstance3D.new()
		water.name = "Water"
		water.mesh = generate_sphere(water_radius, 8)
		dynamic_preview_water.visible = true
		var water_material := ShaderMaterial.new()
		water_material.shader = water_shader
		water_material.set_shader_parameter("water_color", water_color)
		water_material.set_shader_parameter("water_color_falloff", water_color_falloff)
		water_material.set_shader_parameter("wave_noise", wave_noise)
		water_material.set_shader_parameter("wave_strength", wave_strength)
		water_material.set_shader_parameter("wave_speed", wave_speed)
		water.material_override = water_material
		
		planet.add_child(water)
		water.owner = self
	
	planet.add_child(terrain)
	terrain.owner = self
	
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
		if (dynamic_preview): dynamic_preview_object_generator.call()

var dynamic_preview_object := Node3D.new()
var dynamic_preview_planet := MeshInstance3D.new()
var dynamic_preview_water := MeshInstance3D.new()

var dynamic_preview_object_generator = func():
	dynamic_preview_planet.mesh = generate_sphere(
		radius,
		subdivisions_per_edge,
		true,
		noise_layers
	)
	
	dynamic_preview_water.mesh = generate_sphere(water_radius, 8)
	
	if using_terrain_shader:
		var terrain_material := ShaderMaterial.new()
		terrain_material.shader = 	hq_planet_shader if using_high_quality_terrain else planet_shader
		terrain_material.set_shader_parameter("minimum_radius", radius)
		terrain_material.set_shader_parameter("maximum_radius", maximum_radius)
		terrain_material.set_shader_parameter("grass_threshold", grass_threshold)
		if using_high_quality_terrain:
			terrain_material.set_shader_parameter("texture_scale", texture_scale)
			terrain_material.set_shader_parameter("normal_strength", normal_strength)
			terrain_material.set_shader_parameter("grass_texture", grass_texture)
			terrain_material.set_shader_parameter("grass_normal_texture", grass_normal_texture)
			terrain_material.set_shader_parameter("stone_texture", stone_texture)
			terrain_material.set_shader_parameter("stone_normal_texture", stone_normal_texture)
			terrain_material.set_shader_parameter("sand_texture", sand_texture)
			terrain_material.set_shader_parameter("sand_normal_texture", sand_normal_texture)
		else:
			terrain_material.set_shader_parameter("grass_color", grass_color)
			terrain_material.set_shader_parameter("stone_color", stone_color)
			terrain_material.set_shader_parameter("sand_color", sand_color)
			terrain_material.set_shader_parameter("grass_curve", grass_curve)
			terrain_material.set_shader_parameter("stone_curve", stone_curve)
			terrain_material.set_shader_parameter("sand_curve", sand_curve)
		dynamic_preview_planet.material_override = terrain_material
	else:
		dynamic_preview_planet.material_override = null
	
	if using_water:
		dynamic_preview_water.visible = true
		var water_material := ShaderMaterial.new()
		water_material.shader = water_shader
		water_material.set_shader_parameter("water_color", water_color)
		water_material.set_shader_parameter("water_color_falloff", water_color_falloff)
		water_material.set_shader_parameter("wave_noise", wave_noise)
		water_material.set_shader_parameter("wave_strength", wave_strength)
		water_material.set_shader_parameter("wave_speed", wave_speed)
		dynamic_preview_water.material_override = water_material
	else:
		dynamic_preview_water.material_override = null
		dynamic_preview_water.visible = false

@export_group("Planet Terrain")

@export var using_noise: bool = false:
	set(v):
		using_noise = v
		notify_property_list_changed()
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var noise_layers: Array[NoiseLayer] = []:
	set(v):
		noise_layers = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var using_terrain_shader: bool = false:
	set(v):
		using_terrain_shader = v
		notify_property_list_changed()
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var maximum_radius: float = 2.0:
	set(v):
		maximum_radius = v
		notify_property_list_changed()
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var grass_threshold: float = 0.5:
	set(v):
		grass_threshold = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var grass_color: Color = Color.LAWN_GREEN:
	set(v):
		grass_color = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var stone_color: Color = Color.SLATE_GRAY:
	set(v):
		stone_color = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var sand_color: Color = Color.SANDY_BROWN:
	set(v):
		sand_color = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var grass_curve: CurveTexture = CurveTexture.new():
	set(v):
		grass_curve = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var stone_curve: CurveTexture = CurveTexture.new():
	set(v):
		stone_curve = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var sand_curve: CurveTexture = CurveTexture.new():
	set(v):
		sand_curve = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export_group("High Quality Planet Terrain")

@export var using_high_quality_terrain: bool = false:
	set(v):
		using_high_quality_terrain = v
		notify_property_list_changed()
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var texture_scale: float = 1.0:
	set(v):
		texture_scale = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var normal_strength: float = 1.0:
	set(v):
		normal_strength = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var grass_texture: Texture2D:
	set(v):
		grass_texture = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var grass_normal_texture: Texture2D:
	set(v):
		grass_normal_texture = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var stone_texture: Texture2D:
	set(v):
		stone_texture = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var stone_normal_texture: Texture2D:
	set(v):
		stone_normal_texture = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var sand_texture: Texture2D:
	set(v):
		sand_texture = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var sand_normal_texture: Texture2D:
	set(v):
		sand_normal_texture = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export_group("Planet Water")

@export var using_water: bool = false:
	set(v):
		using_water = v
		notify_property_list_changed()
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var water_radius: float = 1.01:
	set(v):
		water_radius = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var water_color: Color = Color.AQUA:
	set(v):
		water_color = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var water_color_falloff: float = 3.0:
	set(v):
		water_color_falloff = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var wave_noise: NoiseTexture3D:
	set(v):
		wave_noise = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var wave_strength: float = 0.2:
	set(v):
		wave_strength = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

@export var wave_speed: float = 0.03:
	set(v):
		wave_speed = v
		if (dynamic_preview): dynamic_preview_object_generator.call()

func _validate_property(property: Dictionary) -> void:
	if not using_noise:
		match property.name:
			"noise_layers": property.usage |= PROPERTY_USAGE_READ_ONLY
	if not using_terrain_shader:
		match property.name:
			"maximum_radius": property.usage |= PROPERTY_USAGE_READ_ONLY
			"grass_threshold": property.usage |= PROPERTY_USAGE_READ_ONLY
			"grass_color": property.usage |= PROPERTY_USAGE_READ_ONLY
			"stone_color": property.usage |= PROPERTY_USAGE_READ_ONLY
			"sand_color": property.usage |= PROPERTY_USAGE_READ_ONLY
			"grass_curve": property.usage |= PROPERTY_USAGE_READ_ONLY
			"stone_curve": property.usage |= PROPERTY_USAGE_READ_ONLY
			"sand_curve": property.usage |= PROPERTY_USAGE_READ_ONLY
	if not using_high_quality_terrain:
		match property.name:
			"texture_scale": property.usage |= PROPERTY_USAGE_READ_ONLY
			"normal_strength": property.usage |= PROPERTY_USAGE_READ_ONLY
			"grass_texture": property.usage |= PROPERTY_USAGE_READ_ONLY
			"grass_normal_texture": property.usage |= PROPERTY_USAGE_READ_ONLY
			"stone_texture": property.usage |= PROPERTY_USAGE_READ_ONLY
			"stone_normal_texture": property.usage |= PROPERTY_USAGE_READ_ONLY
			"sand_texture": property.usage |= PROPERTY_USAGE_READ_ONLY
			"sand_normal_texture": property.usage |= PROPERTY_USAGE_READ_ONLY
	if not using_water:
		match property.name:
			"water_radius": property.usage |= PROPERTY_USAGE_READ_ONLY
			"water_color": property.usage |= PROPERTY_USAGE_READ_ONLY
			"water_color_falloff": property.usage |= PROPERTY_USAGE_READ_ONLY
			"wave_noise": property.usage |= PROPERTY_USAGE_READ_ONLY
			"wave_strength": property.usage |= PROPERTY_USAGE_READ_ONLY
			"wave_speed": property.usage |= PROPERTY_USAGE_READ_ONLY

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
	using_noise: bool = false,
	noise_layers: Array[NoiseLayer] = []
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
	
	# Apply optimizations before committing.
	# This improves CPU and GPU performance by removing duplicate
	# verticies.
	#sphere.index()
	# This only really improves performance when rendering because
	# it sorts triangles that makes rendering faster
	#sphere.optimize_indices_for_cache()
	
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
		if (using_noise):
			for layer in range(noise_layers.size()):
				height += noise_layers[layer].sample(copied_vertex)
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
	dynamic_preview_object.add_child(dynamic_preview_planet)
	dynamic_preview_object.add_child(dynamic_preview_water)
	pass # Replace with function body.
