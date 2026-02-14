# Player.gd
extends CharacterBody2D

const ACCELERATION = 3000
const MAX_SPEED = 18000
const LIMIT_SPEED_Y = 1200
const JUMP_HEIGHT = 36000
const MIN_JUMP_HEIGHT = 12000
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
const WALL_JUMP_AMOUNT = 18000
const WALL_JUMP_TIME = 10
const WALL_SLIDE_FACTOR = 0.8
const WALL_HORIZONTAL_TIME = 30
const GRAVITY = 2100
const DASH_SPEED = 36000

var axis = Vector2()

var coyoteTimer = 0
var jumpBufferTimer = 0
var wallJumpTimer = 0
var wallHorizontalTimer = 0
var dashTime = 0

var canJump = false
var friction = false
var wall_sliding = false
var trail = false
var isDashing = false
var hasDashed = false
var isGrabbing = false


func _physics_process(delta):
	if velocity.y <= LIMIT_SPEED_Y:
		if !isDashing:
			velocity.y += GRAVITY * delta
	friction = false
	
	getInputAxis()
	
	dash(delta)
	
	wallSlide(delta)

func getInputAxis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	axis = axis.normalized()

func dash(delta):
	if !hasDashed:
		if Input.is_action_just_pressed("dash"):
			velocity = axis * DASH_SPEED * delta
			isDashing = true
			hasDashed = true

	if isDashing:
		trail = true
		dashTime += delta

		if dashTime >= 0.25:
			isDashing = false
			trail = false
			dashTime = 0
	if is_on_floor() && velocity.y >= 0:
		hasDashed = false
