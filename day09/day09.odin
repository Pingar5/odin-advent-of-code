package day09

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "shared:vector2"

main :: proc() {
	using vector2

	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
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
	tail := Vector2{0, 0}
	tail_positions := make([dynamic]Vector2, 1)
	tail_positions[0] = tail
	defer delete(tail_positions)

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		direction := DIRECTION_MAP[rune(line[0])]
		count, _ := strconv.parse_int(line[2:])

		for i in 0 ..< count {
			head = add(head, direction)

			moved: bool
			tail, moved = select_tail_position(tail, head)

			if moved {
				is_new := true

				for old_tail_position in tail_positions {
					if equals(tail, old_tail_position) {
						is_new = false
						break
					}
				}

				if is_new do append(&tail_positions, tail)
			}
		}
	}

	fmt.println("Visited", len(tail_positions), "positions")
}

select_tail_position :: proc(
	old_position: vector2.Vector2,
	head: vector2.Vector2,
) -> (
	new_position: vector2.Vector2,
	moved: bool = false,
) {
	using vector2

	if equals(old_position, head) do new_position = old_position
	else if old_position.x == head.x || old_position.y == head.y {
		delta := sub(head, old_position)

		if taxi_cab_magnitude(delta) > 1 {
			direction := normalize_orthogonal(delta)
			new_position = add(old_position, direction)
			moved = true
		} else {
			new_position = old_position
		}
	} else {
		delta := sub(head, old_position)

		if taxi_cab_magnitude(delta) > 2 {
			direction := normalize_diagonal(delta, true)
			new_position = add(old_position, direction)
			moved = true
		} else {
			new_position = old_position
		}
	}

	return
}
