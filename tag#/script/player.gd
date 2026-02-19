extends CharacterBody2D

# --- Constants ---
const ACCEL := 1000.0
const MAX_SPEED := 110.0
const FRICTION := 800.0 

const GRAVITY := 700.0
const FALL_GRAVITY := 1000.0
const APEX_THRESHOLD := 35.0 
const MAX_FALL_SPEED := 420.0

const JUMP_FORCE := 185
const MIN_JUMP_FORCE := 50.0
const COYOTE_TIME := 0.08
const JUMP_BUFFER := 0.10

const WALL_SLIDE_SPEED := 800
const WALL_JUMP_FORCE := Vector2(140, -110)
const WALL_JUMP_LOCK := 0.15

const DASH_SPEED := 340.0
const DASH_DURATION := 0.12
const DASH_FREEZE := 0.05 
const DASH_NERF_UP := 0.50
const DASH_NERF_DIAG_UP := 0.75

const LAND_ANIM_TIME := 0.10

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var axis := Vector2.ZERO
var dash_dir := Vector2.ZERO
var last_frame_velocity := Vector2.ZERO

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_jump_timer := 0.0
var wall_jump_float_timer := 0.0
var dash_timer := 0.0
var landing_timer := 0.0

var grounded := false
var gravity_frozen := false
var is_dashing := false
var has_dash := false

func _physics_process(delta: float) -> void:
	update_state()
	handle_input()
	apply_gravity(delta)
	handle_dash(delta)
	handle_horizontal_movement(delta)
	handle_jump()
	process_timers(delta)
	last_frame_velocity = velocity
	move_and_slide()
	update_visuals(delta)

func update_state() -> void:
	var was_grounded = grounded
	grounded = is_on_floor()
	
	if grounded:
		has_dash = true
		coyote_timer = COYOTE_TIME
		if !was_grounded and last_frame_velocity.y > 200:
			landing_timer = LAND_ANIM_TIME
			apply_squish(1.2, 0.8) 

func handle_input() -> void:
	var raw = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if raw.length() < 0.2:
		axis = Vector2.ZERO
	else:
		var snapped_angle = round(raw.angle() / (PI / 4)) * (PI / 4)
		axis = Vector2(cos(snapped_angle), sin(snapped_angle)).round()

func apply_gravity(delta: float) -> void:
	if gravity_frozen: return
	
	if wall_jump_float_timer > 0:
		velocity.y += GRAVITY * delta * 0.20
	elif is_on_wall_custom() and velocity.y > 0 and !grounded:
		velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, GRAVITY * delta)
	else:
		var current_grav = FALL_GRAVITY if velocity.y > 0 else GRAVITY
		if abs(velocity.y) < APEX_THRESHOLD and !Input.is_action_pressed("jump"):
			current_grav *= 0.5
		
		velocity.y = move_toward(velocity.y, MAX_FALL_SPEED, current_grav * delta)

func handle_horizontal_movement(delta: float) -> void:
	if is_dashing: return
	if wall_jump_timer > 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * 0.5 * delta)
	elif axis.x != 0:
		velocity.x = move_toward(velocity.x, axis.x * MAX_SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER

	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			perform_jump()
		elif is_on_wall_custom() and !grounded:
			perform_wall_jump()
			
	if Input.is_action_just_released("jump") and velocity.y < -MIN_JUMP_FORCE:
		velocity.y = -MIN_JUMP_FORCE

func handle_dash(delta: float) -> void:
	if has_dash and Input.is_action_just_pressed("dash") and !is_dashing:
		initiate_dash()
		
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			terminate_dash()

# --- Actions ---

func perform_jump() -> void:
	velocity.y = -JUMP_FORCE
	jump_buffer_timer = 0
	coyote_timer = 0
	apply_squish(0.7, 1.3)

func perform_wall_jump() -> void:
	var dir = get_wall_direction()
	if dir != 0:
		velocity = Vector2(-dir * WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
		wall_jump_timer = WALL_JUMP_LOCK
		wall_jump_float_timer = 0.12
		jump_buffer_timer = 0
		apply_squish(0.8, 1.2)

func initiate_dash() -> void:
	is_dashing = true
	has_dash = false
	gravity_frozen = true
	dash_timer = DASH_DURATION
	dash_dir = axis if axis != Vector2.ZERO else (Vector2.LEFT if anim.flip_h else Vector2.RIGHT)
	velocity = dash_dir.normalized() * DASH_SPEED

	Engine.time_scale = 0.05
	await get_tree().create_timer(DASH_FREEZE * 0.05).timeout
	Engine.time_scale = 1.0
	
	apply_squish(1.3, 0.7)

func terminate_dash() -> void:
	is_dashing = false
	gravity_frozen = false
	if dash_dir.y < -0.1:
		velocity.y *= DASH_NERF_UP
	velocity.x *= 0.8

func process_timers(delta: float) -> void:
	if !grounded: coyote_timer -= delta
	jump_buffer_timer -= delta
	wall_jump_timer -= delta
	wall_jump_float_timer -= delta
	landing_timer -= delta

func is_on_wall_custom() -> bool:
	return $RayCastWalls/ray_cast_left.is_colliding() or $RayCastWalls/ray_cast_right.is_colliding()

func get_wall_direction() -> int:
	if $RayCastWalls/ray_cast_left.is_colliding(): return -1
	if $RayCastWalls/ray_cast_right.is_colliding(): return 1
	return 0

# --- Visual Effects ---

func apply_squish(x: float, y: float) -> void:
	anim.scale = Vector2(x, y)

func update_visuals(delta: float) -> void:
	anim.scale = anim.scale.lerp(Vector2.ONE, 8.0 * delta)
	if is_dashing and dash_dir.x != 0:
		anim.flip_h = dash_dir.x < 0
	elif wall_jump_timer > 0 and velocity.x != 0:
		anim.flip_h = velocity.x < 0
	elif abs(velocity.x) > 5:
		anim.flip_h = velocity.x < 0
		
	# if is_dashing: anim.play("dash")
	# elif !grounded: anim.play("jump")
	# else: anim.play("run" if abs(velocity.x) > 10 else "idle")
