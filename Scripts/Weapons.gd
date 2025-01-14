extends Spatial
#
##Shooting params
#var shoot_range = 1000
#var screen_width_center = 0
#var screen_height_center = 0
#var shoot_origin = Vector3()
#var shoot_direction = Vector3()
#var shooting = false
#var impactForce = 20
#var weaponID = 0
#
## Pistol
#var PistolData = {
#	magSize = 12,
#	bulletsInWeapon = 12,
#	bulletsOutWeapon = 24,
#	damage = 10
#}
#
##Effects
#onready var particleSystem = get_node("Particles")
#onready var audioSystem = get_node("Audio")
#onready var ReloadaudioSystem = get_node("ReloadAudio")
#onready var PickUpAudio = get_node("PickUpAudio")
#onready var Shotlight = get_node("Shotlight")
#onready var NoBullets = get_node("NoBullets")
#
##Animation
#onready var animationPlayer = get_node("Handgun/AnimationPlayer")
#var walk = false
#var idle = true
#
#func _ready():
#	Game.animation = animationPlayer
#	animationPlayer.play("pull out")
#	updateAmmoUI(PistolData)
#
#func _input(event):
#	if event is InputEventMouseButton and event.pressed:
#		var camera = get_node("../")
#		shoot_origin = camera.project_ray_origin(Vector2(screen_width_center, screen_height_center))
#		shoot_direction = camera.project_ray_normal(Vector2(screen_width_center, screen_height_center)) * shoot_range
#
#		if event.button_index == 1:
#			shooting = true
#func _physics_process(delta):
#	screen_width_center = OS.get_window_size().x/2
#	screen_height_center = OS.get_window_size().y/2
#	if animationPlayer.get_current_animation() == "fire":
#		Shotlight.light_energy = lerp(Shotlight.light_energy,4,0.4)
#	else:
#		Shotlight.light_energy = lerp(Shotlight.light_energy,0,0.4)
#	animations()
#	if shooting and !animationPlayer.get_current_animation() == "reload" and !animationPlayer.get_current_animation() == "fire":
#		pistol()
#	shooting = false
#	if Input.is_action_pressed("reload"):
#		reload(PistolData)
#	pass
#
#func pistol():
#	if PistolData.bulletsInWeapon > 0:
#		particleSystem.restart()
#		audioSystem.play()
#		var impulse
#		var impact_position
#
#		var space_state = get_world().direct_space_state
#		var result = space_state.intersect_ray(shoot_origin, shoot_direction, [self], 1)
#
#		PistolData.bulletsInWeapon -= 1
#		animationPlayer.play("fire")
#		animationPlayer.queue("idle (copy)")
#		updateAmmoUI(PistolData)
#		if result:
#			impulse = (result.position - global_transform.origin).normalized()
#			var position = result.position - result.collider.global_transform.origin
#			if shooting:
#				# for objects
#				if result.collider is RigidBody:
#					result.collider.apply_impulse(position, impulse*impactForce)
#				# for zombie
#				if result.collider is KinematicBody and result.collider.has_method("hit"):
#					var headshot = position.y > 0.96 # height of body
#					result.collider.hit(PistolData.damage, headshot)
#	else:
#		NoBullets.play()
#
#func reload(weapon):
#	if weapon.bulletsOutWeapon > 0 and weapon.bulletsInWeapon < weapon.magSize and !animationPlayer.get_current_animation() == "fire":
#		ReloadaudioSystem.play()
#		animationPlayer.play("reload")
#		animationPlayer.queue("idle (copy)")
#		var reloadRange = weapon.magSize - weapon.bulletsInWeapon
#		var reloadValue
#
#		if weapon.bulletsOutWeapon >= reloadRange:
#			reloadValue = reloadRange
#		else:
#			reloadValue = weapon.bulletsOutWeapon
#
#		weapon.bulletsOutWeapon -= reloadValue
#		weapon.bulletsInWeapon += reloadValue
#		updateAmmoUI(weapon)
#
#func updateAmmoUI(weapon):
#	var inWeaponLabel = get_node("../../../Control/AmmoUI/InWeapon")
#	inWeaponLabel.text = str(weapon.bulletsInWeapon)
#	var inMagLabel = get_node("../../../Control/AmmoUI/InMag")
#	inMagLabel.text = str(weapon.bulletsOutWeapon)
#
#func animations():
#	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
#		if walk or animationPlayer.get_current_animation() == "fire" or animationPlayer.get_current_animation() == "reload":
#			pass
#		else:
#			animationPlayer.play("walk (copy)")
#			walk = true
#			idle = false
#	else:
#		if idle or animationPlayer.get_current_animation() == "fire" or animationPlayer.get_current_animation() == "reload":
#			pass
#		else:
#			animationPlayer.play("idle (copy)")
#			idle = true
#			walk = false
#
#func _on_Area_area_entered(area):
#
#	if area.is_in_group("pistolAmmo"):
#		getAmmo(PistolData, 30)
#		updateAmmoUI(PistolData)
#		area.queue_free()
#		PickUpAudio.play()
#	pass # replace with function body
#
#func getAmmo(weapon, amount):
#	weapon.bulletsOutWeapon += amount
