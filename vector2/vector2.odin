package vector2

Vector2 :: struct {
	x: int,
	y: int,
}

UP :: Vector2{0, 1}
DOWN :: Vector2{0, -1}
LEFT :: Vector2{-1, 0}
RIGHT :: Vector2{1, 0}

add :: proc(a: Vector2, b: Vector2) -> Vector2 {
	return Vector2{a.x + b.x, a.y + b.y}
}

sub :: proc(a: Vector2, b: Vector2) -> Vector2 {
	return Vector2{a.x - b.x, a.y - b.y}
}
