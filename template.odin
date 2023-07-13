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
	}
}
