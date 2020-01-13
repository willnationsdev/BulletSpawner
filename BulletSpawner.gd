extends Node2D

tool


#For the purposes of your project, feel free to add more parameters to this signal.
#If you do, remember to change its calls in fire() appropriately!
signal bullet_fired(position, direction, speed)

export(float, 0.05, 10, 0.05) var interval: float = 1 setget _set_interval

export(float, 10, 500, 10) var bullet_speed: float = 100 setget _set_bullet_speed
export(int, 1, 100) var bullet_count: int = 1 setget _set_bullet_count
export(float, 0, 360, 0.1) var bullet_spread_degrees: float = 0 setget _set_bullet_spread_degrees

export var firing: bool = false setget _set_firing
var shot_direction: Vector2 setget , _get_shot_direction

func _set_interval(value: float) -> void:
	interval = value
	$Timer.wait_time = value

func _set_bullet_speed(value: float) -> void:
	bullet_speed = value;
	if Engine.editor_hint:
		update()

func _set_bullet_count(value: int) -> void:
	bullet_count = value
	if Engine.editor_hint:
		update()

func _set_bullet_spread_degrees(value: float) -> void:
	bullet_spread_degrees = value
	if Engine.editor_hint:
		update()

func _set_firing(value: bool) -> void:
	firing = value
	if not Engine.editor_hint and is_inside_tree():
		if firing:
			$Timer.start()
		else:
			$Timer.stop()

func _get_shot_direction() -> Vector2:
	 return Vector2(cos(rotation), sin(rotation))

func _ready() -> void:
	if Engine.editor_hint:
		update()
		return
	connect('bullet_fired', $'/root/BulletServerRelay','on_bullet_fired')
	$Timer.connect('timeout', self, 'fire')
	$Timer.wait_time = interval
	self.firing = firing

func fire() -> void:
	if bullet_spread_degrees != 0.0 && bullet_count > 1:
		var spread_radians: float = deg2rad(bullet_spread_degrees)
		var spacing: float = spread_radians / (bullet_count - 1)
		var start_dir: Vector2 = self.shot_direction.rotated(spread_radians / 2)
		for i in range(bullet_count):
			var bullet_dir: Vector2 = start_dir.rotated(-spacing * i)
			emit_signal('bullet_fired', global_position, bullet_dir, bullet_speed)
	elif bullet_count > 0:
		emit_signal('bullet_fired', global_position, self.shot_direction, bullet_speed)

func _draw() -> void:
	if Engine.editor_hint:
		_draw_shot_preview(Color.pink, Color.white, 2)

func _draw_shot_preview(border_color: Color, shot_color: Color, scale: float = 1.0) -> void:
	var arc_point_count := 64
	var min_dist: float = 5 * scale
	var max_dist: float = 20 * scale
	var bullet_dist: float = lerp(min_dist, (max_dist - scale), float((bullet_speed - 10)) / 490)
	
	var bullet_trail_color: Color = Color(border_color.r, border_color.g, border_color.b, 0.1)
	
	if bullet_count > 1:
		var angle: Vector2 = Vector2.RIGHT.rotated(deg2rad(bullet_spread_degrees / 2))
		var opposite: Vector2 = angle.rotated(deg2rad(-bullet_spread_degrees))
		var step_radians: float = deg2rad(bullet_spread_degrees / (bullet_count - 1))
		var arc_points := PoolVector2Array()
		draw_arc(Vector2.ZERO, min_dist, angle.angle(), opposite.angle(), arc_point_count / 2, border_color, 0.5)
		draw_arc(Vector2.ZERO, max_dist, angle.angle(), opposite.angle(), arc_point_count, border_color, 0.5)
		draw_line(opposite * min_dist, opposite * max_dist, border_color)
		draw_line(angle * min_dist, angle * max_dist, border_color)
		draw_line(Vector2.RIGHT * (min_dist - scale), Vector2.RIGHT * (min_dist + scale), border_color)
		draw_line(Vector2.RIGHT * (max_dist - scale), Vector2.RIGHT * (max_dist + scale), border_color)
		for i in range(bullet_count):
			var shot_angle: Vector2 = angle.rotated(-step_radians * i)
			draw_line(shot_angle * min_dist, shot_angle * bullet_dist, bullet_trail_color)
			draw_line(shot_angle * bullet_dist, shot_angle * (bullet_dist + scale), shot_color)
	else:
		draw_line(Vector2.RIGHT * (min_dist - scale), Vector2.RIGHT * (max_dist + scale), border_color)
	
