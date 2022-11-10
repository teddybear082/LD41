extends Spatial

export (XRTools.Buttons) var quit_button : int = XRTools.Buttons.VR_BUTTON_BY
export (XRTools.Buttons) var reload_button : int = XRTools.Buttons.VR_BUTTON_AX
export (XRTools.Buttons) var shoot_button : int = XRTools.Buttons.VR_TRIGGER
export (XRTools.Buttons) var flashlight_button : int = XRTools.Buttons.VR_GRIP

onready var XR_origin = $FPController
onready var XR_camera = XR_origin.get_node("ARVRCamera")
onready var XR_playerbody = XR_origin.get_node("PlayerBody")
onready var Camera_lamp = XR_camera.get_node("Lamp")
onready var HUD = XR_camera.get_node("HUD")
onready var HUD_ammo = HUD.get_node("Ammo")
onready var HUD_health = HUD.get_node("Health")
onready var Handgun = $Handgun
onready var Nozzle = Handgun.get_node("Nozzle")
onready var ShellPosition = Handgun.get_node("ShellPosition")
onready var Shootlight = Handgun.get_node("ShootLight")
onready var Flashlight = Handgun.get_node("Flashlight")
onready var Shootsound = Handgun.get_node("Nozzle/ShootSound")
onready var ReloadSound = Handgun.get_node("Nozzle/ReloadSound")
onready var EmptySound = Handgun.get_node("Nozzle/EmptySound")
onready var HandgunAnimPlayer = Handgun.get_node("AnimationPlayer")
onready var Hurt1Sound = $FPController/PlayerSounds/Hurt1
onready var Hurt2Sound = $FPController/PlayerSounds/Hurt2
onready var FootStepSound = $FPController/PlayerSounds/FootStep
onready var Shootlighttimer = $ShootLightTimer
onready var Shoottimer = $Timer
onready var GunRaycast = Handgun.get_node("RayCast")

var health_float : float = 100.0
var health : int = 100
var ammo : int = 12
var pack : int = 2
var left_handed : bool = false

var impact = "res://Instances/Impact.tscn"
var bullet = "res://Instances/Bullet.tscn"
var shell = "res://Instances/Shell.tscn"

var can_shoot : bool = true

puppet var puppet_transform = transform
puppet var puppet_camera_rotation = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	update_HUD()
	update_handgun_hand()
	
	if is_network_master():
		#$Camera.current = true
		HUD.visible = true
		#$Camera/RayCast.enabled = true
		#$Camera/Lamp.visible = false
		GunRaycast.enabled = true
		Camera_lamp.visible = false
		if Network.vr_left_handed == true:
			left_handed = true
			update_handgun_hand()
		if Network.vr_seated_mode == true:
			XR_playerbody.player_height_offset = .50
		if Network.vr_smooth_turn == true:
			XR_origin.get_node("RightHandController/MovementTurn").turn_mode = XR_origin.get_node("RightHandController/MovementTurn").TurnMode.SMOOTH
	else:
		HUD.visible = false

	#Connect signals for controller buttons for cancel
	$FPController/LeftHandController.connect("button_pressed", self, "_on_LeftHand_button_pressed")
	$FPController/RightHandController.connect("button_pressed", self, "_on_RightHand_button_pressed")
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	if is_network_master():
		if health <= 0:
			global_transform = Network.spawn.global_transform
			XR_origin.global_transform = Network.spawn.global_transform
			yield(get_tree().create_timer(.01), "timeout")

			health_float = 100.0
			update_HUD()
		
		if HandgunAnimPlayer.current_animation != "fire" and HandgunAnimPlayer.current_animation != "reload" and HandgunAnimPlayer.current_animation != "pull out":
		
			if abs(XR_playerbody.ground_control_velocity.x) > .3 or abs(XR_playerbody.ground_control_velocity.y) > .3:
				rpc("footstep", true, 0.75, -25)
			else:
				rpc("footstep", false, 1.0, -20)
		
		
		rset_unreliable("puppet_transform", XR_origin.transform)
		#other_abilities()
		
		
		
	else:
		transform = puppet_transform
		XR_origin.transform = puppet_transform
		#XR_camera.rotation = puppet_camera_rotation
		#$Camera.rotation = puppet_camera_rotation

func other_abilities():
	pass
#	if Input.is_action_just_pressed("shoot"):
#		if can_shoot and $Camera/Handgun/AnimationPlayer.current_animation != "reload":
#			if ammo > 0:
#				ammo -= 1
#				update_HUD()
#				randomize()
#				var pitch = rand_range(0.9, 1.1)
#				rpc("shoot", pitch)
#
#				can_shoot = false
#				$Timer.start()
#
#				rpc("animation", "fire")
#				if $Camera/RayCast.is_colliding():
#					if $Camera/RayCast.get_collider().is_in_group("Zombie"):
#						$Camera/RayCast.get_collider().rpc("shot")
#					else:
#						if not $Camera/RayCast.get_collider().is_in_group("Player"):
#							rpc("impact", $Camera/RayCast.get_collision_point())
#			else:
#				rpc("empty_sound")
	
#	if Input.is_action_just_pressed("ui_cancel"):
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
#	if Input.is_action_just_pressed("reload") and ammo != 12:
#		if pack > 0:
#			rpc("reload")
#			ammo = 12
#			pack -= 1
#			update_HUD()
#


remotesync func empty_sound():
	EmptySound.play()

remotesync func footstep(status, pitch, volume):
	if not FootStepSound.playing:
		if status:
			FootStepSound.pitch_scale = pitch
			FootStepSound.unit_db = volume
			FootStepSound.play()
		else:
			FootStepSound.stop()

remotesync func impact(position):
	var impact_instance = load(impact).instance()
	impact_instance.global_transform.origin = position
	get_tree().get_root().get_node("Game").add_child(impact_instance)

func heal():
	health_float += 50.0
	if health_float > 100.0:
		health_float = 100.0
	health = int(health_float)
	update_HUD()

remotesync func attacked(delta):
	health_float -= 30.0 * delta
	update_HUD()
	randomize()
	var number = rand_range(0,2)
	var pitch = rand_range(0.9, 1.1)
	rpc("hurt_sound", number, pitch)

remotesync func hurt_sound(number, pitch):
	if Hurt1Sound.playing == false and Hurt2Sound.playing == false:

		if number < 1:
			Hurt1Sound.pitch_scale = pitch
			Hurt1Sound.play()
		else:
			Hurt2Sound.play()
			Hurt2Sound.pitch_scale = pitch
	
remotesync func reload():
	HandgunAnimPlayer.play("reload")
	ReloadSound.play()

func update_HUD():
	health = int(health_float)
	HUD_health.set_text(str(health))
	HUD_ammo.set_text(str(ammo) + " / " + str(pack))

remotesync func animation(anim):
	HandgunAnimPlayer.play(anim)

remotesync func toggle_light(status):
	Flashlight.visible = status
	Camera_lamp.get_node("Feedback").visible = status

remotesync func shoot(pitch):
	Shootsound.pitch_scale = pitch
	Shootsound.play()
	Shootlight.visible = true
	Shootlighttimer.start()

	var bullet_instance = load(bullet).instance()
	bullet_instance.global_transform = Nozzle.global_transform
	get_tree().get_root().get_node("Game").add_child(bullet_instance)
	bullet_instance.linear_velocity = -Nozzle.transform.basis.z * 200
	
	var shell_instance = load(shell).instance()
	shell_instance.global_transform = ShellPosition.global_transform
	get_tree().get_root().get_node("Game").add_child(shell_instance)
	shell_instance.linear_velocity = ShellPosition.global_transform.basis.x * 5
	
	yield(get_tree().create_timer(2), "timeout")
	bullet_instance.queue_free()
	shell_instance.queue_free()

func _on_network_peer_connected(id):
	if is_network_master():
		rpc("toggle_light", Flashlight.visible)
		rset("puppet_camera_rotation", XR_camera.rotation)

func _on_Timer_timeout():
	can_shoot = true

func _on_ShootLightTimer_timeout():
	Shootlight.visible = false
	rpc("shootlight", false)

func vr_check_shoot():
	if is_network_master():
		if can_shoot and Handgun.get_node("AnimationPlayer").current_animation != "reload":
			if ammo > 0:
				ammo -= 1
				update_HUD()
				randomize()
				var pitch = rand_range(0.9, 1.1)
				rpc("shoot", pitch)
				
				can_shoot = false
				Shoottimer.start()
				
				rpc("animation", "fire")
				if GunRaycast.is_colliding():
					if GunRaycast.get_collider().is_in_group("Zombie"):
						GunRaycast.get_collider().rpc("shot")
					else:
						if not GunRaycast.get_collider().get_parent().get_parent().get_parent().is_in_group("Player"):
							rpc("impact", GunRaycast.get_collision_point())
			else:
				rpc("empty_sound")

func vr_check_reload():
	if is_network_master():
		if ammo != 12:
			if pack > 0:
				rpc("reload")
				ammo = 12
				pack -= 1
				update_HUD()
	
func _on_LeftHand_button_pressed(button):
	if button == quit_button:
		get_tree().change_scene("res://Lobby-VR.tscn")	
	
	if left_handed == true:
		if button == shoot_button:
			vr_check_shoot()
		if button == reload_button:
			vr_check_reload()
		if button == flashlight_button and is_network_master():
			Flashlight.visible = !Flashlight.visible
			rpc("toggle_light", Flashlight.visible)

func _on_RightHand_button_pressed(button):
	if button == quit_button:
		get_tree().change_scene("res://Lobby-VR.tscn")
	
	if left_handed == false:
		if button == shoot_button:
			vr_check_shoot()
		if button == reload_button:
			vr_check_reload()	
		if button == flashlight_button and is_network_master():
			Flashlight.visible = !Flashlight.visible
			rpc("toggle_light", Flashlight.visible)
		
func update_handgun_hand():
	if left_handed == true:
		$FPController/LeftHandController/RemoteTransform.set_remote_node($Handgun.get_path())
	
	else:
		$FPController/RightHandController/RemoteTransform.set_remote_node($Handgun.get_path())
