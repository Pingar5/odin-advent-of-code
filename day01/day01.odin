package day01

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	current_elf := 0
	all_elves: [dynamic]int

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		if line == "" {
			append(&all_elves, current_elf)
			current_elf = 0
		} else {
			calories := strconv.parse_int(line) or_else 0
			current_elf += calories
		}
	}

	if current_elf != 0 {
		append(&all_elves, current_elf)
	}

	slice.sort(all_elves[:])
	elf_count := len(all_elves)

	fmt.println("Overall best: ", all_elves[elf_count - 1])
	fmt.println(
		"Sum of best 3: ",
		(all_elves[elf_count - 1] + all_elves[elf_count - 2] + all_elves[elf_count - 3]),
	)
}
