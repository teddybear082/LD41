extends Control

func _ready():
	$VROptionsMenu/HSplitContainer/SeatedCheckButton.pressed = Network.vr_seated_mode
	$VROptionsMenu/HSplitContainer2/SmoothTurnCheckButton.pressed = Network.vr_smooth_turn
	$VROptionsMenu/HSplitContainer3/LeftHandedCheckButton.pressed = Network.vr_left_handed
	get_tree().set_network_peer(null)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$Tween.interpolate_property($Logo1, "position:y", $Logo1.position.y, 850, 2, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 2)
	$Tween.interpolate_property($Logo2, "position:y", $Logo2.position.y, 850, 2, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 3)
	$Tween.interpolate_property($Logo3, "position:y", $Logo3.position.y, 850, 2, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 4)
	$Tween.start()
	

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_HostButton_pressed():
	Network.create_server()

func _on_JoinButton_pressed():
	Network.join_server( $Menu/IP.text )

func _on_IP_text_entered(new_text):
	_on_JoinButton_pressed()

func _on_Quit_pressed():
	get_tree().quit()


func _on_Timer_timeout():
	$Menu.show()
	$Back.show()


func _on_VROptionsButton_pressed():
	$Menu.hide()
	$VROptionsMenu.show() 


func _on_VRBackButton_pressed():
	$VROptionsMenu.hide() 
	$Menu.show()




func _on_SeatedCheckButton_toggled(button_pressed):
	Network.vr_seated_mode = button_pressed


func _on_SmoothTurnCheckButton_toggled(button_pressed):
	Network.vr_smooth_turn = button_pressed


func _on_LeftHandedCheckButton_toggled(button_pressed):
	Network.vr_left_handed = button_pressed
