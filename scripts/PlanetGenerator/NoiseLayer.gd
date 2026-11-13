@tool
extends Resource

class_name NoiseLayer

@export var noise_control: Curve = Curve.new()
@export var noise_generator: Noise = FastNoiseLite.new()
@export var noise_power: float = 1.0
@export var noise_max: float = 1.0
@export var using_normalization: bool = true

func _init() -> void:
	# Create a default linear Curve
	noise_control.add_point(
		Vector2(0.0, 0.0),
		Curve.TANGENT_LINEAR,
		Curve.TANGENT_LINEAR
	)
	
	noise_control.add_point(
		Vector2(1.0, 1.0),
		Curve.TANGENT_LINEAR,
		Curve.TANGENT_LINEAR
	)

func sample(uvx: Vector3) -> float:
	# Normalize noise into [0.0, 1.0] range
	var normalized_noise: float = (
		(noise_generator.get_noise_3dv(uvx) / 2.0) + 1.0 
		if using_normalization 
		else clamp(noise_generator.get_noise_3dv(uvx), 0.0, 1.0)
	)
	# Pass into noise control curve
	# Use baked function to increase performance (slightly)
	var controlled_noise := noise_control.sample_baked(normalized_noise)
	# Apply noise power
	var powered_noise := pow(controlled_noise, noise_power)
	# Scale noise by noise max
	return powered_noise * noise_max
