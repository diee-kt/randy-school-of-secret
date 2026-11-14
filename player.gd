extends CharacterBody3D
# Kontrol sentuh: kiri = joystick jalan, kanan = geser kamera.
const SPEED := 3.0
const SENS := 0.004
var cam: Camera3D
var pitch := 0.0
var move_idx := -1
var look_idx := -1
var move_origin := Vector2.ZERO
var move_vec := Vector2.ZERO
var stick_base: ColorRect
var stick_knob: ColorRect

func _ready() -> void:
	cam = Camera3D.new()
	cam.position = Vector3(0, 1.6, 0)
	cam.current = true
	add_child(cam)
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 1.8
	col.shape = cap
	col.position.y = 0.9
	add_child(col)

func attach_stick(layer: CanvasLayer) -> void:
	stick_base = ColorRect.new()
	stick_base.size = Vector2(160, 160)
	stick_base.color = Color(0.2, 0.6, 1.0, 0.18)
	stick_base.visible = false
	stick_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(stick_base)
	stick_knob = ColorRect.new()
	stick_knob.size = Vector2(70, 70)
	stick_knob.color = Color(0.3, 0.7, 1.0, 0.5)
	stick_knob.visible = false
	stick_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(stick_knob)

func _unhandled_input(e: InputEvent) -> void:
	var vs := get_viewport().get_visible_rect().size
	if e is InputEventScreenTouch:
		if e.pressed:
			if e.position.x < vs.x * 0.4:
				if move_idx == -1:
					move_idx = e.index
					move_origin = e.position
					stick_base.position = e.position - Vector2(80, 80)
					stick_knob.position = e.position - Vector2(35, 35)
					stick_base.visible = true
					stick_knob.visible = true
			elif not (e.position.x > vs.x * 0.75 and e.position.y > vs.y * 0.45):
				if look_idx == -1:
					look_idx = e.index
		else:
			if e.index == move_idx:
				move_idx = -1
				move_vec = Vector2.ZERO
				stick_base.visible = false
				stick_knob.visible = false
			elif e.index == look_idx:
				look_idx = -1
	elif e is InputEventScreenDrag:
		if e.index == move_idx:
			var d: Vector2 = e.position - move_origin
			move_vec = (d / 80.0).limit_length(1.0)
			stick_knob.position = move_origin + move_vec * 80.0 - Vector2(35, 35)
		elif e.index == look_idx:
			rotate_y(-e.relative.x * SENS)
			pitch = clamp(pitch - e.relative.y * SENS, -1.2, 1.2)
			cam.rotation.x = pitch

func _physics_process(delta: float) -> void:
	var dir := (global_transform.basis * Vector3(move_vec.x, 0, move_vec.y))
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0
	move_and_slide()
