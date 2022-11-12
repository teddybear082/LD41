extends Node




# Called when the node enters the scene tree for the first time.
func _ready():
	$WinningLabel3D.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Labyrinth_2_player_won(player):
	$WinningLabel3D.visible = true
