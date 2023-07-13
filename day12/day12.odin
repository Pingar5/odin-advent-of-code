package day12

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:container/queue"
import "shared:vector2"

Boundaries :: struct {
	top:    int,
	left:   int,
	right:  int,
	bottom: int,
}

HeightMap :: [dynamic][dynamic]u8

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	height_map := make(HeightMap)
	start: vector2.Vector2
	end: vector2.Vector2

	data := string(raw)
	y := 0
	for line in strings.split_lines_iterator(&data) {
		x := 0
		row := make([dynamic]u8, len(line))

		for i in 0 ..< len(line) {
			character := line[i]

			if rune(character) == 'S' {
				start = vector2.Vector2{x, y}
				character = u8('a')
			} else if rune(character) == 'E' {
				end = vector2.Vector2{x, y}
				character = u8('z')
			}

			row[i] = character - u8('a')
			x += 1
		}

		append(&height_map, row)
		y += 1
	}

	fmt.println(
		"From starting point:",
		calculate_length_of_shortest_path(height_map, start, end, true),
	)
	fmt.println(
		"From any low ground:",
		calculate_length_of_shortest_path_from_any_low_ground(height_map, end, false),
	)
}

get_edge_weight :: proc(height_map: HeightMap, from: vector2.Vector2, to: vector2.Vector2) -> int {
	from_height := int(height_map[from.y][from.x])
	to_height := int(height_map[to.y][to.x])

	if from_height - to_height > 1 do return -1

	return 1
}

distance_hueristic :: proc(from: vector2.Vector2, to: vector2.Vector2) -> int {
	delta := to - from
	return vector2.taxi_cab_magnitude(delta)
}

get_adjacent_vectors :: proc(v: vector2.Vector2, boundaries: Boundaries) -> []vector2.Vector2 {
	adjacent_vectors: [dynamic]vector2.Vector2
	for direction in vector2.DIRECTIONS {
		adjacent_vector := v + direction

		if adjacent_vector.x < boundaries.left ||
		   adjacent_vector.x >= boundaries.right ||
		   adjacent_vector.y < boundaries.top ||
		   adjacent_vector.y >= boundaries.bottom {
			continue
		}

		append(&adjacent_vectors, adjacent_vector)
	}
	return adjacent_vectors[:]
}

index_of :: proc(arr: ^[dynamic]vector2.Vector2, v: vector2.Vector2) -> int {
	for i in 0 ..< len(arr) {
		if arr[i] == v do return i
	}
	return -1
}

calculate_shortest_paths :: proc(
	height_map: HeightMap,
	from: vector2.Vector2,
) -> (
	costs: [dynamic][dynamic]int,
	parents: [dynamic][dynamic]vector2.Vector2,
) {
	using vector2

	open := queue.Queue(Vector2){}
	closed := make([dynamic]Vector2)
	boundaries := Boundaries {
		top    = 0,
		left   = 0,
		right  = len(height_map[0]),
		bottom = len(height_map),
	}

	costs = make([dynamic][dynamic]int, len(height_map))
	for y in 0 ..< len(costs) do costs[y] = make([dynamic]int, len(height_map[y]))

	parents = make([dynamic][dynamic]Vector2, len(height_map))
	for y in 0 ..< len(parents) do parents[y] = make([dynamic]Vector2, len(height_map[y]))

	queue.init(&open)
	queue.push(&open, from)

	costs[from.y][from.x] = 0
	parents[from.y][from.x] = from

	for open.len > 0 {
		current := queue.pop_front(&open)

		for successor in get_adjacent_vectors(current, boundaries) {
			edge_weight := get_edge_weight(height_map, current, successor)
			if edge_weight < 0 do continue

			successor_cost := costs[current.y][current.x] + edge_weight


			if index_of(&open.data, successor) >= 0 {
				if costs[successor.y][successor.x] <= successor_cost do continue
			} else {
				successor_index_in_closed := index_of(&closed, successor)
				if successor_index_in_closed >= 0 {
					if costs[successor.y][successor.x] <= successor_cost do continue

					queue.push(&open, successor)
					unordered_remove(&closed, successor_index_in_closed)
				} else {
					queue.push(&open, successor)
				}

				costs[successor.y][successor.x] = successor_cost
				parents[successor.y][successor.x] = current
			}
		}

		append(&closed, current)
	}

	return
}

visualize_shortest_path :: proc(
	parents: [dynamic][dynamic]vector2.Vector2,
	from: vector2.Vector2,
) {
	visualization := make([dynamic][dynamic]rune, len(parents))
	for y in 0 ..< len(visualization) {
		visualization[y] = make([dynamic]rune, len(parents[y]))

		for x in 0 ..< len(visualization[y]) {
			visualization[y][x] = '.'
		}
	}

	current := from
	for true {
		parent := parents[current.y][current.x]
		delta := current - parent

		if delta == vector2.ZERO {
			visualization[current.y][current.x] = 'E'
			break
		}

		switch delta {
		case vector2.UP:
			visualization[current.y][current.x] = '^'
		case vector2.DOWN:
			visualization[current.y][current.x] = 'v'
		case vector2.LEFT:
			visualization[current.y][current.x] = '>'
		case vector2.RIGHT:
			visualization[current.y][current.x] = '<'
		}

		current = parent
	}

	for row in visualization {
		for char in row {
			fmt.print(char)
		}
		fmt.println()
	}
}

visualize_costs :: proc(parents: [dynamic][dynamic]vector2.Vector2, costs: [dynamic][dynamic]int) {
	for row in costs {
		for cost in row {
			if cost == -1 do fmt.print(" . ")
			else {
				buf: [3]byte
				cost_string := strconv.itoa(buf[:], cost)
				cost_string = strings.center_justify(cost_string, 3, " ")
				fmt.print(cost_string)
			}
		}
		fmt.println()
	}
}

calculate_length_of_shortest_path :: proc(
	height_map: HeightMap,
	from: vector2.Vector2,
	to: vector2.Vector2,
	print_visualization: bool = false,
) -> int {
	costs, parents := calculate_shortest_paths(height_map, to)
	fmt.println("Done!")

	if print_visualization {
		fmt.println()
		visualize_costs(parents, costs)
		fmt.println()
		visualize_shortest_path(parents, from)
	}

	return costs[from.y][from.x]
}

calculate_length_of_shortest_path_from_any_low_ground :: proc(
	height_map: HeightMap,
	to: vector2.Vector2,
	print_visualization: bool = false,
) -> int {
	costs, parents := calculate_shortest_paths(height_map, to)

	if print_visualization {
		fmt.println()
		visualize_costs(parents, costs)
		fmt.println()
		visualize_shortest_path(parents, vector2.ZERO)
	}

	best_low_ground := -1
	for y in 0 ..< len(height_map) {
		for x in 0 ..< len(height_map[y]) {
			if height_map[y][x] != 0 || costs[y][x] == 0 do continue

			if costs[y][x] < best_low_ground || best_low_ground == -1 {
				best_low_ground = costs[y][x]
			}
		}
	}
	return best_low_ground
}
