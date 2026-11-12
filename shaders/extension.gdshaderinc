vec4 triplanar_map(
	sampler2D color,
	vec3 vertex,
	vec3 normal,
	float scale
) {
	// Determine the weight for each side.
	// For example, if the normal faces completely in the -Z
	// direction, only sample the Z projection
	
	vec3 blend = abs(normal);
	blend /= blend.x + blend.y + blend.z;
	
	// Determine the uv coordinate for each face
	vec2 uv_x = vertex.zy * scale;
	vec2 uv_y = vertex.xz * scale;
	vec2 uv_z = vertex.xy * scale;
	
	// Sample the texture from each uv
	vec4 color_x = texture(color, uv_x);
	vec4 color_y = texture(color, uv_y);
	vec4 color_z = texture(color, uv_z);
	
	// Blend between each sample by the blend value
	vec4 final_color = 
		color_x * blend.x +
		color_y * blend.y +
		color_z * blend.z;
	
	return final_color;
}