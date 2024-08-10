extends RigidBody2D

enum ANIMAL_STATE { READY, DRAG, RELEASE }

@onready var arrow = $Arrow
@onready var label = $Label
@onready var stretch_sound = $StretchSound
@onready var launch_sound = $LaunchSound
@onready var kick_sound = $KickSound


const DRAG_LIM_MAX: Vector2 = Vector2(0, 60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200.0

var _state: ANIMAL_STATE = ANIMAL_STATE.READY

var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO
var _arrow_scale_x: float = 0.0
var _last_collision_count: int = 0

func _ready():
	_arrow_scale_x = arrow.scale.x
	arrow.hide()
	_start = position
	pass

func _physics_process(delta):
	update(delta)
	label.text = "%s\n" % ANIMAL_STATE.keys()[_state]
	label.text += "%.1f,%.1f" % [_dragged_vector.x, _dragged_vector.y]
	pass
	
func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT
	pass

func set_drag() -> void:
	_drag_start = get_global_mouse_position()
	arrow.show()
	pass
	
func set_release() -> void:
	arrow.hide()
	freeze = false
	apply_central_impulse(get_impulse())
	launch_sound.play()
	SignalManager.on_attempt_made.emit()
	pass
	
func set_new_state(new_state: ANIMAL_STATE) -> void:
	_state = new_state
	if(_state == ANIMAL_STATE.RELEASE):
		set_release()
	elif(_state == ANIMAL_STATE.DRAG):
		set_drag()
	pass

func detect_release() -> bool: 
	if(_state == ANIMAL_STATE.DRAG):
		if(Input.is_action_just_released("drag")):
			set_new_state(ANIMAL_STATE.RELEASE)
			pass
			return true
	return false
	pass
	
func scale_arrow() -> void:
	
	var imp_len = get_impulse().length()
	var perc = imp_len / IMPULSE_MAX
	
	arrow.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	arrow.rotation = (_start - position).angle()
	pass
	
func play_stretch_sound() -> void:
	if(_last_dragged_vector - _dragged_vector).length() > 0:
		if(stretch_sound.playing == false):
			stretch_sound.play()
	pass
	
func get_dragged_vector(gmp: Vector2) -> Vector2:
	return gmp - _drag_start
	pass

func drag_in_limits() -> void:
	
	_last_dragged_vector = _dragged_vector
	
	_dragged_vector.x = clampf(
		_dragged_vector.x,
		 DRAG_LIM_MIN.x,
		 DRAG_LIM_MAX.x
	)
	_dragged_vector.y = clampf(
	_dragged_vector.y,
	 DRAG_LIM_MIN.y,
	DRAG_LIM_MAX.y
	)
	
	position = _start + _dragged_vector
	pass

func update_drag() -> void:
	
	if(detect_release()): return
	
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)
	play_stretch_sound()
	drag_in_limits()
	scale_arrow()
	pass

func play_collision_sound() -> void:
	if(_last_collision_count == 0 &&
	  get_contact_count() > 0 && 
	  !kick_sound.playing):
		
		kick_sound.play()
	_last_collision_count = get_contact_count()
	pass
	
func update_flight() -> void:
	play_collision_sound()
	pass
	
func update(delta: float) -> void:
	match _state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			update_flight()
			pass
	pass

func _on_screen_exited():
	die()
	pass

func die() -> void:
	SignalManager.on_animal_died.emit()
	queue_free()
	pass


func _on_input_event(viewport, event: InputEvent, shape_idx):
	if(_state == ANIMAL_STATE.READY && event.is_action_pressed("drag")):
		set_new_state(ANIMAL_STATE.DRAG)
	pass 

func _on_sleeping_state_changed():
	
	if(sleeping): 
		var cb = get_colliding_bodies()
		if(cb.size() > 0):
			cb[0].die()
		call_deferred("die")
	pass 
