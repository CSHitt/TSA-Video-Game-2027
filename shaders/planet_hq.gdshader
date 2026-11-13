shader_type spatial;

#include "res://shaders/extension.gdshaderinc"

uniform float minimum_radius = 0.0;
uniform float maximum_radius = 1.0;

uniform float texture_scale = 1.0;
uniform float normal_strength = 1.0;

uniform sampler2D grass_texture : repeat_enable;
uniform sampler2D grass_normal_texture : repeat_enable;
uniform sampler2D grass_curve : repeat_disable;

uniform sampler2D stone_texture: repeat_enable;
uniform sampler2D stone_normal_texture : repeat_enable;
uniform sampler2D stone_curve : repeat_disable;

uniform sampler2D sand_texture : repeat_enable;
uniform sampler2D sand_normal_texture : repeat_enable;
uniform sampler2D sand_curve : repeat_disable;

uniform float grass_threshold : hint_range(0.0, 1.0) = 0.5f;

void fragment() {
	
	// Determine the pixel's world coordinate
	vec3 pixel_position = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 pixel_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	
	// Find the distance from the pixel to the center of the planet
	float dist = distance(pixel_position, NODE_POSITION_WORLD);
	// Find the distance relative to the max and min radii
	float relative_dist = (dist - minimum_radius) / (maximum_radius - minimum_radius);
	// Determine how close the surface normal is to the up direction
	float normal_dist = distance(pixel_normal, normalize(pixel_position - NODE_POSITION_WORLD)) / 2.0f;
	// Normalize the normal distance
	float n_normal_dist = (normal_dist + 1.0f) / 2.0f;
	
	// Determine the weight of each of the materials at the given height
	float sand_sample = texture(sand_curve, vec2(relative_dist)).r;
	float stone_sample = texture(stone_curve, vec2(relative_dist)).r;
	float grass_sample = texture(grass_curve, vec2(relative_dist)).r;
	
	// Determine the color and normal at this pixel
	// Use triplanar mapping.
	vec3 sand_color = triplanar_map(
		sand_texture,
		pixel_position, 
		pixel_normal, 
		texture_scale
	).rgb;
	
	vec3 stone_color = triplanar_map(
		stone_texture,
		pixel_position,
		pixel_normal,
		texture_scale
	).rgb;
	
	vec3 grass_color = triplanar_map(
		grass_texture,
		pixel_position,
		pixel_normal,
		texture_scale
	).rgb;
	
	vec3 sand_normal = triplanar_map(
		sand_normal_texture,
		pixel_position,
		pixel_normal,
		texture_scale
	).rgb;
	
	vec3 stone_normal = triplanar_map(
		stone_normal_texture,
		pixel_position,
		pixel_normal,
		texture_scale
	).rgb;
	
	vec3 grass_normal = triplanar_map(
		grass_normal_texture,
		pixel_position,
		pixel_normal,
		texture_scale
	).rgb;
	
	// Determine the correct base color value given the height and color curves
	vec3 base_color = mix(
		stone_color,
		sand_color,
		(sand_sample - stone_sample + 1.0f) / 2.0f
	);
	
	vec3 base_normal = mix(
		stone_normal,
		sand_normal,
		(sand_sample - stone_sample + 1.0f) / 2.0f
	);
	
	// If the surface is relatively flat, apply a grass color

	// Apply a smooth transition
	// if n_normal_dist > grass_threshold, draw grass
	// else, draw base color
	float grass_normal_weight = smoothstep( 
		grass_threshold - 0.025,
		grass_threshold + 0.025,
		n_normal_dist
	);
	
	vec3 final_color = mix(
		base_color,
		grass_color,
		grass_normal_weight * grass_sample
	);
	
	vec3 final_normal = mix(
		base_normal,
		grass_normal,
		grass_normal_weight * grass_sample
	);
	
	ALBEDO = final_color;
	NORMAL_MAP = final_normal * normal_strength;
}
