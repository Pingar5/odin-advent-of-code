package day09

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "shared:vector2"

main :: proc() {
	using vector2

	tail_length, tail_length_ok := strconv.parse_int(os.args[2])

	if !tail_length_ok {
		fmt.println("That is not a valid tail length")
		return
	}

	input_file_path := os.args[1]
	raw, input_file_ok := os.read_entire_file(input_file_path, context.allocator)

	if !input_file_ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	DIRECTION_MAP := map[rune]vector2.Vector2 {
		'U' = vector2.UP,
		'D' = vector2.DOWN,
		'L' = vector2.LEFT,
		'R' = vector2.RIGHT,
	}

	head := Vector2{0, 0}
	segments := make([dynamic]Vector2, tail_length, tail_length)
	defer delete(segments)

	tail_positions := make([dynamic]Vector2, 1)
	tail_positions[0] = segments[len(segments) - 1]
	defer delete(tail_positions)

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		direction := DIRECTION_MAP[rune(line[0])]
		count, _ := strconv.parse_int(line[2:])

		for i in 0 ..< count {
			head += direction

			for segment_index in 0 ..< tail_length {
				following: Vector2
				if segment_index == 0 do following = head
				else do following = segments[segment_index - 1]

				moved: bool
				segments[segment_index], moved = move_segment(segments[segment_index], following)

				if moved && segment_index == tail_length - 1 {
					is_new := true

					for old_tail_position in tail_positions {
						if segments[segment_index] == old_tail_position {
							is_new = false
							break
						}
					}

					if is_new do append(&tail_positions, segments[segment_index])
				}
			}
		}
	}

	fmt.println("Visited", len(tail_positions), "positions")
}

move_segment :: proc(
	old_position: vector2.Vector2,
	following: vector2.Vector2,
) -> (
	new_position: vector2.Vector2,
	moved: bool = false,
) {
	using vector2

	if old_position == following do new_position = old_position
	else if old_position.x == following.x || old_position.y == following.y {
		delta := following - old_position

		if taxi_cab_magnitude(delta) > 1 {
			direction := normalize_orthogonal(delta)
			new_position = old_position + direction
			moved = true
		} else {
			new_position = old_position
		}
	} else {
		delta := following - old_position

		if taxi_cab_magnitude(delta) > 2 {
			direction := normalize_diagonal(delta, true)
			new_position = old_position + direction
			moved = true
		} else {
			new_position = old_position
		}
	}

	return
}
