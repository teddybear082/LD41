extends Spatial

var which_pointer : String = "right"


# Called when the node enters the scene tree for the first time.
func _ready():
	$screenholder.visible = false
	$LoadingScreen.set_camera($FPController/ARVRCamera)
	
	# Connect loading screen signal
	$LoadingScreen.connect("continue_pressed", self, "_on_LoadingScreen_continue_pressed")
	
	# Connect button pressed signals on controllers
	$FPController/LeftHandController.connect("button_pressed", self, "_on_LeftHand_button_pressed")
	$FPController/RightHandController.connect("button_pressed", self, "_on_RightHand_button_pressed")

	# Connect signals for button pressed on menu to audio
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("Menu/HostButton").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("Menu/JoinButton").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("Menu/Quit").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("Menu/VROptionsButton").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("VROptionsMenu/HSplitContainer/SeatedCheckButton").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("VROptionsMenu/HSplitContainer2/SmoothTurnCheckButton").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("VROptionsMenu/HSplitContainer3/LeftHandedCheckButton").connect("pressed", self, "_on_ui_button_pressed")
	$screenholder/lobbyviewport2Dto3D.get_scene_instance().get_node("VROptionsMenu/VRBackButton").connect("pressed", self, "_on_ui_button_pressed")

func _on_LoadingScreen_continue_pressed():
	$LoadingScreen.follow_camera = false
	$LoadingScreen.visible = false
	yield(get_tree().create_timer(1.0), "timeout")
	$screenholder.stop_moving()
	if $screenholder.transform.origin.y < 1.5:
		$screenholder.transform.origin.y = 1.5
	$screenholder.visible = true


# Functions to switch which VR pointer is active depending on which trigger the player last pressed
func _update_pointers():
	$FPController/LeftHandController/FunctionPointer.enabled = which_pointer == "left"
	$FPController/RightHandController/FunctionPointer.enabled = which_pointer == "right"
	
	
func _on_LeftHand_button_pressed(button):
	if which_pointer == "right" and button == $FPController/LeftHandController/FunctionPointer.active_button:
		which_pointer = "left"
		_update_pointers()


func _on_RightHand_button_pressed(button):
	if which_pointer == "left" and button == $FPController/RightHandController/FunctionPointer.active_button:
		which_pointer = "right"
		_update_pointers()
		

# Receiver function of button pressed signal to play the menu audio sound
func _on_ui_button_pressed():
	$SoundEffects/MenuSelect.play()
