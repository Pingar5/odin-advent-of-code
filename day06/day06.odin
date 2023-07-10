package day

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		using fmt

		println("Start of packet ::", detect_marker(line, 4, false))
		println("Start of message ::", detect_marker(line, 14, false))
		println()
	}
}

detect_marker :: proc(
	data: string,
	marker_length: int,
	print_debug_info: bool = false,
) -> (
	marker_location: int,
	ok: bool,
) {
	ring := make([dynamic]rune, marker_length - 1, marker_length - 1)
	for i in 0 ..< marker_length - 1 do ring[i] = '_'

	ring_start := 0
	ring_invalid_for := len(ring) - 1

	for index := 0; index < len(data); index += 1 {
		is_marker := ring_invalid_for < 0
		new_character := rune(data[index])

		for offset := len(ring) - 1; offset >= 0; offset -= 1 {
			index := (ring_start + offset) % len(ring)

			old_character := ring[(ring_start + offset) % len(ring)]
			if new_character == old_character {
				is_marker = false

				if offset != 0 && offset > ring_invalid_for {
					ring_invalid_for = offset
				}
				break
			}
		}

		if print_debug_info {
			for print_index := 0; print_index < len(ring); print_index += 1 {
				if print_index == ring_start && print_index == ((ring_start + ring_invalid_for) % len(ring)) && ring_invalid_for > -1 do fmt.print("\033[1;36m")
				else if print_index == ring_start do fmt.print("\033[1;33m")
				else if print_index == ((ring_start + ring_invalid_for) % len(ring)) && ring_invalid_for > -1 do fmt.print("\033[1;31m")

				fmt.print(ring[print_index], "\033[1;0m, ", sep = "")
			}
			fmt.println(new_character)
		}

		removed_character := ring[ring_start]
		ring[ring_start] = new_character
		ring_start += 1
		ring_start %= len(ring)
		ring_invalid_for -= 1

		if is_marker && index >= len(ring) {
			if print_debug_info do fmt.println(index + 1, "::", ring, removed_character)
			return index + 1, true
		}
	}

	return -1, false
}
