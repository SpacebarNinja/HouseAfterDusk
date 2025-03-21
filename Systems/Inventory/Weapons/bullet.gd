extends Node2D

@export var speed: float = 600.0
@export var max_distance: float = 1000.0  # Bullet disappears after traveling this far

var direction: Vector2
var start_position: Vector2

func _ready():
	start_position = global_position

func _process(delta):
	# Move bullet in the set direction
	position += direction * speed * delta

	# Check if the bullet has traveled too far
	if start_position.distance_to(global_position) > max_distance:
		queue_free()

func shoot_towards(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()  # Rotate bullet to face movement direction

func _on_area_2d_area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.has_method("take_damage"):
		entity.take_damage(100)
		queue_free()
		print(entity, " hit")
