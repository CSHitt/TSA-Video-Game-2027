shader_type spatial;

uniform vec4 water_color : source_color = vec4(0.0, 0.5, 0.8, 0.8);
uniform float water_color_falloff = 3.0;

uniform sampler3D wave_noise;
uniform float wave_strength : hint_range(0.0, 1.0) = 0.2;
uniform float wave_speed = 0.03;

void fragment() {
	// Determine the direction from the center of the water
	// to the camera.
	vec3 water_to_camera_normal = normalize(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD);
	// Determine the normal of the surface in world space.
	// Apply some wavyness first
	NORMAL += texture(
		wave_noise, 
		(INV_VIEW_MATRIX * vec4(vec3(VERTEX.x + TIME * wave_speed, VERTEX.yz), 1.0)).rgb
	).rgb * wave_strength;
	vec3 pixel_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	
	// Determine how far the water's surface normal is to
	// the normal from the water to the camera.
	float normal_dist = distance(pixel_normal, water_to_camera_normal);
	
	// Bring to a power. Favors higher values more than
	// lower values.
	float weighted_dist = pow(normal_dist, water_color_falloff);
	
	// Change metallicness with normal difference
	METALLIC = weighted_dist;
	
	ALBEDO = water_color.rgb;
	ALPHA = water_color.a;
	ROUGHNESS = 0.3;
}
