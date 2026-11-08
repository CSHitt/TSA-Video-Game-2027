extends Control

var player: PlatformerPlayer
var x_position: Label
var y_position: Label
var state: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_parent().get_parent().find_child("Player")
	x_position = find_child("x_position")
	y_position = find_child("y_position")
	state = find_child("state")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	x_position.text = "x_position: " + str(player.position.x)
	y_position.text = "y_position: " + str(player.position.y)
	state.text = "state: " + str(PlatformerPlayer.PlatformerStateEnum.find_key(player.platformer_state))
