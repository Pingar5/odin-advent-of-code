package day04

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Range :: [2]int

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	contains_count := 0
	overlaps_count := 0

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		first, second := read_line_as_ranges(line)

		if contains(first, second) do contains_count += 1
		if overlaps(first, second) do overlaps_count += 1
	}

	fmt.println(contains_count, "fully contained")
	fmt.println(overlaps_count, "overlaps")
}

read_line_as_ranges :: proc(line: string) -> (first: Range, second: Range) {
	using strconv

	str_ranges, err := strings.split(line, ",")
	str_first_range, err2 := strings.split(str_ranges[0], "-")
	str_second_range, err3 := strings.split(str_ranges[1], "-")

	first = [2]int{
		parse_int(str_first_range[0]) or_else 0,
		parse_int(str_first_range[1]) or_else 0,
	}
	second = [2]int{
		parse_int(str_second_range[0]) or_else 0,
		parse_int(str_second_range[1]) or_else 0,
	}

	return
}

contains :: proc(first: Range, second: Range) -> bool {
	return(
		(first[0] <= second[0] && first[1] >= second[1]) ||
		(first[0] >= second[0] && first[1] <= second[1]) \
	)
}

overlaps :: proc(first: Range, second: Range) -> bool {
	return(
		(first[0] <= second[0] && first[0] >= second[1]) ||
		(first[1] >= second[0] && first[1] <= second[1]) ||
		(second[0] <= first[0] && second[0] >= first[1]) ||
		(second[1] >= first[0] && second[1] <= first[1]) \
	)
}
