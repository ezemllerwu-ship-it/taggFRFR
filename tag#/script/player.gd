extends CharacterBody2D

const ACCEL := 9000.0
const MAX_SPEED := 300.0
const FRICTION := 0.15

const GRAVITY := 1800.0
const FALL_GRAVITY := 2400.0
const MAX_FALL_SPEED := 900.0

const JUMP_FORCE := 600
const MIN_JUMP_FORCE := 80.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.12

const WALL_SLIDE_SPEED := 60.0
const WALL_JUMP_FORCE := Vector2(260, -420)
const WALL_JUMP_LOCK := 0.2

const DASH_SPEED := 800
const DASH_DURATION := 0.25

var axis := Vector2.ZERO
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_jump_timer := 0.0
var dash_timer := 0.0

var grounded := false
var grounded_timer := 0.0
const GROUNDED_GRACE := 0.04

var is_dashing := false
var has_dashed := false
var dash_dir := Vector2.ZERO
var was_on_floor := false

func _physics_process(delta):
	update_grounded(delta)
	get_input_axis()

	if !is_dashing:
		if velocity.y > 0:
			velocity.y += FALL_GRAVITY * delta
		else:
			velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

	handle_dash(delta)

	if wall_jump_timer <= 0 and !is_dashing:
		handle_horizontal(delta)
	else:
		wall_jump_timer -= delta

	if grounded:
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if grounded:
			do_jump()

	if Input.is_action_just_pressed("jump"):
		if coyote_timer > 0:
			do_jump()
		elif is_on_wall_custom() and !grounded:
			do_wall_jump()
		else:
			jump_buffer_timer = JUMP_BUFFER

	if Input.is_action_just_released("jump"):
		if velocity.y < -MIN_JUMP_FORCE:
			velocity.y = lerp(velocity.y, -MIN_JUMP_FORCE, 0.55)

	if grounded and !is_dashing:
		has_dashed = false

	was_on_floor = grounded
	move_and_slide()

func update_grounded(delta):
	if is_on_floor():
		grounded_timer = GROUNDED_GRACE
	else:
		grounded_timer -= delta
	grounded = grounded_timer > 0

func get_input_axis():
	axis = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

func do_jump():
	velocity.y = -JUMP_FORCE
	jump_buffer_timer = 0
	coyote_timer = 0

func do_wall_jump():
	var dir = wall_direction()
	if dir != 0:
		velocity = Vector2(-dir * WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
		wall_jump_timer = WALL_JUMP_LOCK

func is_on_wall_custom() -> bool:
	return $RayCast/ray_cast_left.is_colliding() or $RayCast/ray_cast_right.is_colliding()

func wall_direction() -> int:
	if $RayCast/ray_cast_left.is_colliding():
		return -1
	if $RayCast/ray_cast_right.is_colliding():
		return 1
	return 0

func handle_horizontal(delta):
	if axis.x != 0:
		velocity.x = move_toward(velocity.x, axis.x * MAX_SPEED, ACCEL * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, FRICTION)

func handle_dash(delta):
	if !has_dashed and Input.is_action_just_pressed("dash"):
		is_dashing = true
		has_dashed = true
		dash_timer = DASH_DURATION
		dash_dir = axis
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT
		dash_dir = dash_dir.normalized()
		velocity = dash_dir * DASH_SPEED

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
