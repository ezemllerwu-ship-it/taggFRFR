extends CharacterBody2D

# --- CONSTANTS ---
const ACCELERATION := 3000.0
const MAX_SPEED := 18000.0
const LIMIT_SPEED_Y := 1200.0
const JUMP_FORCE := 36000.0
const MIN_JUMP_FORCE := 12000.0
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.1
const WALL_JUMP_FORCE := 18000.0
const WALL_JUMP_LOCK := 0.15
const WALL_SLIDE_FACTOR := 0.8
const GRAVITY := 2100.0
const DASH_SPEED := 36000.0
const DASH_DURATION := 0.25

# --- VARIABLES ---
var axis := Vector2.ZERO
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_jump_timer := 0.0
var dash_timer := 0.0

var can_jump := false
var wall_sliding := false
var is_dashing := false
var has_dashed := false
var is_grabbing := false

func _physics_process(delta: float) -> void:
	get_input_axis()
	if !is_dashing and velocity.y < LIMIT_SPEED_Y:
		velocity.y += GRAVITY * delta
	handle_dash(delta)
	handle_wall_slide(delta)	
	if wall_jump_timer <= 0.0 and !is_dashing and !is_grabbing:
		handle_horizontal(delta)
	else:
		wall_jump_timer -= delta
	if is_on_floor():
		can_jump = true
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		if coyote_timer <= 0.0:
			can_jump = false
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta
		if is_on_floor():
			do_jump(delta)
	if Input.is_action_just_pressed("jump"):
		if can_jump:
			do_jump(delta)
		elif is_on_wall():
			do_wall_jump(delta)
		else:
			jump_buffer_timer = JUMP_BUFFER
	if Input.is_action_just_released("jump"):
		if velocity.y < -MIN_JUMP_FORCE * delta:
			velocity.y = -MIN_JUMP_FORCE * delta
	move_and_slide()

func get_input_axis() -> void:
	axis = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	).normalized()

func do_jump(delta: float) -> void:
	velocity.y = -JUMP_FORCE * delta
	can_jump = false
	jump_buffer_timer = 0.0

func do_wall_jump(delta: float) -> void:
	var dir := wall_direction()
	if dir != 0:
		velocity.x = -dir * WALL_JUMP_FORCE * delta
		velocity.y = -JUMP_FORCE * delta
		wall_jump_timer = WALL_JUMP_LOCK

func is_on_wall_custom() -> bool:
	return $RayCast/ray_cast_left.is_colliding() or $RayCast/ray_cast_right.is_colliding()

func wall_direction() -> int:
	if $RayCast/ray_cast_left.is_colliding():
		return -1
	if $RayCast/ray_cast_right.is_colliding():
		return 1
	return 0

func handle_wall_slide(delta: float) -> void:
	if !is_on_floor() and is_on_wall_custom() and velocity.y > 0:
		wall_sliding = true

		if Input.is_action_pressed("grab"):
			is_grabbing = true
			velocity.y = axis.y * 12000 * delta
		else:
			is_grabbing = false
			velocity.y *= WALL_SLIDE_FACTOR
	else:
		wall_sliding = false
		is_grabbing = false

func handle_horizontal(delta: float) -> void:
	if axis.x != 0:
		velocity.x = move_toward(
			velocity.x,
			axis.x * MAX_SPEED * delta,
			ACCELERATION * delta
		)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.4)

func handle_dash(delta: float) -> void:
	if !has_dashed and Input.is_action_just_pressed("dash"):
		is_dashing = true
		has_dashed = true
		dash_timer = DASH_DURATION
		velocity = axis * DASH_SPEED * delta

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

	if is_on_floor():
		has_dashed = false
