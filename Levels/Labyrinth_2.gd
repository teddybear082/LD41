extends Spatial

signal player_won(player)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_exited(body):
	if body.get_parent().get_parent().get_parent().is_in_group("Player"):
		emit_signal("player_won", get_tree().get_nodes_in_group("Player")[0])
