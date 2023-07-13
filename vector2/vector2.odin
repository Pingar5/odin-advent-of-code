package vector2

Vector2 :: distinct [2]int

ZERO :: Vector2{0, 0}
UP :: Vector2{0, 1}
DOWN :: Vector2{0, -1}
LEFT :: Vector2{-1, 0}
RIGHT :: Vector2{1, 0}
DIRECTIONS :: [4]Vector2{UP, LEFT, RIGHT, DOWN}

taxi_cab_magnitude :: proc(v: Vector2) -> int {
	return abs(v.x) + abs(v.y)
}

normalize_orthogonal :: proc(v: Vector2) -> Vector2 {
	if abs(v.x) >= abs(v.y) {
		return Vector2{v.x / abs(v.x), 0}
	} else {
		return Vector2{0, v.y / abs(v.y)}
	}
}

normalize_diagonal :: proc(v: Vector2, favor_diagonal := false) -> Vector2 {
	abs_x := abs(v.x)
	abs_y := abs(v.y)

	if favor_diagonal && abs_x > 0 && abs_y > 0 {
		return Vector2{v.x / abs_x, v.y / abs_y}
	} else if abs_x == abs_y {
		return Vector2{v.x / abs_x, v.y / abs_y}
	}

	return normalize_orthogonal(v)
}
