extends CharacterBody2D

const ACCEL := 2000
const MAX_SPEED := 300.0
const FRICTION := 0.12

const GRAVITY := 1800.0
const FALL_GRAVITY := 2400.0
const MAX_FALL_SPEED := 900.0

const JUMP_FORCE := 600
const MIN_JUMP_FORCE := 80.0
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.12

const WALL_SLIDE_SPEED := 60.0
const WALL_JUMP_FORCE := Vector2( 320, -320)
const WALL_JUMP_LOCK := 0.2


const DASH_SPEED := 800
const DASH_DURATION := 0.15
const DASH_NERF_UP := 0.20        
const DASH_NERF_DIAG_UP := 0.85
const DASH_RESET_COOLDOWN := 0.1

var axis := Vector2.ZERO
var dash_dir := Vector2.ZERO

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_jump_timer := 0.0
var wall_jump_float_timer := 0.0
var dash_timer := 0.0
var dash_reset_cooldown := 0.0

var grounded := false
var gravity_frozen = false
var is_dashing := false
var has_dash := false

func _physics_process(delta):
	update_grounded()
	get_input_axis()
	gravity(delta)
	handle_dash(delta)
	handle_horizontal(delta)
	handle_coyote_time(delta)
	do_we_have_dash()
	
	if Input.is_action_just_pressed("jump"):
		if coyote_timer > 0:
			do_jump()
		elif is_on_wall_custom() and !grounded:
			do_wall_jump()
	
	if Input.is_action_just_released("jump"):
		if velocity.y < -MIN_JUMP_FORCE:
			velocity.y = lerp(velocity.y, -MIN_JUMP_FORCE, 0.55)
	
	move_and_slide()
	
func gravity(delta):
	if wall_jump_float_timer > 0 :
		wall_jump_float_timer -= delta
		velocity.y += GRAVITY * delta * 0.45
		return
	if !gravity_frozen:
		if velocity.y > 0:
			velocity.y += FALL_GRAVITY * delta
		else:
			velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

func update_grounded():
	var was_grounded = grounded
	grounded = is_on_floor()
	if grounded and !was_grounded:
		if axis.x == 0:
			velocity.x = 0

func get_input_axis():
	var raw = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if raw.length() < 0.2:
		axis = Vector2.ZERO
		return
		
	var angle = raw.angle()
	var snapped_angle = round(angle / (PI / 4)) * (PI / 4)
	axis = Vector2.RIGHT.rotated(snapped_angle)
	
func do_jump():
	velocity.y = -JUMP_FORCE
	jump_buffer_timer = 0
	coyote_timer = 0
	
func handle_coyote_time(delta):
	if grounded:
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
func do_wall_jump():
	var dir = wall_direction()
	if dir != 0 :
		velocity = Vector2(-dir * WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
		wall_jump_timer = WALL_JUMP_LOCK
		wall_jump_float_timer = 0.15
		
func is_on_wall_custom() -> bool:
	return $RayCastWalls/ray_cast_left.is_colliding() or $RayCastWalls/ray_cast_right.is_colliding()
	
func wall_direction() -> int:
	if $RayCastWalls/ray_cast_left.is_colliding():
		return -1
	if $RayCastWalls/ray_cast_right.is_colliding():
		return 1
	return 0
	
func handle_horizontal(delta):
	if wall_jump_timer > 0: 
		wall_jump_timer -= delta
		velocity.x *= 0.95
		if sign(axis.x) !=0 and sign(axis.x) != sign(velocity.x):
			return
	if !is_dashing:
		if axis.x != 0:
			velocity.x = move_toward(velocity.x, axis.x * MAX_SPEED, ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta * 60)
	
func handle_dash(delta):
	if has_dash and Input.is_action_just_pressed("dash"):
		is_dashing = true
		has_dash = false
		dash_timer = DASH_DURATION
		dash_dir = axis
		
		if dash_dir == Vector2.ZERO:
			dash_dir = Vector2.RIGHT
			
		dash_dir = dash_dir.normalized()
		
		if dash_dir.y < 0:
			dash_dir.y *= 0.75
		elif dash_dir.y > 0.5:
			dash_dir.y *= 1.25
			
		velocity = dash_dir * DASH_SPEED
		gravity_frozen = true
		
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			gravity_frozen = false
			is_dashing = false
			
			if dash_dir.y < -0.6:
				velocity.x *= DASH_NERF_UP
			elif dash_dir.y < -0.2:
				velocity.x *= DASH_NERF_DIAG_UP

func do_we_have_dash():
	if is_on_floor():
		has_dash = true
		
func dash_refill():
	has_dash = true
