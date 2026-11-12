@tool
extends Resource

class_name NoiseLayer

@export var noise_control: Curve = Curve.new()
@export var noise_generator: Noise = FastNoiseLite.new()

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
