package day08

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "shared:vector2"

HeightMap :: [dynamic][dynamic]int

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	grid: HeightMap

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		row := make([dynamic]int, len(line), len(line))

		for i := 0; i < len(line); i += 1 {
			row[i], _ = strconv.parse_int(line[i:i + 1])
		}

		append(&grid, row)
	}

	y_max := len(grid)
	x_max := len(grid[0])

	visible_count := 0
	best_score := 0

	for y := 0; y < y_max; y += 1 {
		for x := 0; x < x_max; x += 1 {
			is_visible, scenic_score := calculate_tree(&grid, x, y)

			if is_visible do visible_count += 1
			if scenic_score > best_score do best_score = scenic_score
		}
	}

	fmt.println("Visible Trees:", visible_count)
	fmt.println("Best Scenic Score:", best_score)
}

calculate_tree :: proc(
	grid: ^HeightMap,
	x: int,
	y: int,
) -> (
	is_visible: bool = false,
	scenic_score: int,
) {
	using vector2

	y_max := len(grid)
	x_max := len(grid[0])
	tree_height := grid[y][x]

	is_visible =
		get_max_height_in_direction(grid, Vector2{x, y}, UP) < tree_height ||
		get_max_height_in_direction(grid, Vector2{x, y}, DOWN) < tree_height ||
		get_max_height_in_direction(grid, Vector2{x, y}, LEFT) < tree_height ||
		get_max_height_in_direction(grid, Vector2{x, y}, RIGHT) < tree_height

	scenic_score =
		get_viewing_distance(grid, Vector2{x, y}, UP) *
		get_viewing_distance(grid, Vector2{x, y}, DOWN) *
		get_viewing_distance(grid, Vector2{x, y}, LEFT) *
		get_viewing_distance(grid, Vector2{x, y}, RIGHT)

	return
}

get_max_height_in_direction :: proc(
	grid: ^HeightMap,
	from: vector2.Vector2,
	direction: vector2.Vector2,
) -> (
	max_height: int = -1,
) {
	from := from

	for height in iterate_in_direction(grid, &from, direction) {
		if height > max_height do max_height = height
	}

	return
}

get_viewing_distance :: proc(
	grid: ^HeightMap,
	from: vector2.Vector2,
	direction: vector2.Vector2,
) -> (
	viewing_distance: int,
) {
	iter_from := from
	max_height := grid[from.y][from.x]

	for height in iterate_in_direction(grid, &iter_from, direction) {
		viewing_distance += 1

		if height >= max_height do break
	}

	return
}


iterate_in_direction :: proc(
	grid: ^HeightMap,
	from: ^vector2.Vector2,
	direction: vector2.Vector2,
) -> (
	next_value: int,
	ok: bool,
) {
	from^ = vector2.add(from^, direction)

	if from.x < 0 || from.x >= len(grid[0]) || from.y < 0 || from.y >= len(grid) {
		return -1, false
	}

	return grid[from.y][from.x], true
}
