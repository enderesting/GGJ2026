## A thing with a rectangle
## like the play area and the quadrants.
## Assumes `position` is the center
class_name RectangularArea
extends Area2D

var rectangle_shape: RectangleShape2D

# Initialization order HACK
@export var collision_shape_node: CollisionShape2D:
	set(value):
		assert(value)
		collision_shape_node = value
		rectangle_shape = collision_shape_node.shape as RectangleShape2D
		assert(rectangle_shape)


## Returns a Rect2 whose
## position matches the top-left corner and
## size matches the RectangleShape2D size
func get_extents() -> Rect2:
	return Rect2(
		position + collision_shape_node.position - rectangle_shape.size/2,
		rectangle_shape.size
	)

func get_local_extents() -> Rect2:
	return Rect2(-rectangle_shape.size/2, rectangle_shape.size)

## Utility function to grab a random point from a rectangle
static func sample_point(rect: Rect2) -> Vector2:
	return rect.position + Vector2(randf() * rect.size.x, randf() * rect.size.y)

func get_random_position() -> Vector2:
	return RectangularArea.sample_point(get_local_extents())
