package day

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Crate :: struct {
	label: rune,
	next:  ^Crate,
}

Stack :: struct {
	top:    ^Crate,
	bottom: ^Crate,
}


main :: proc() {
	input_file_path := os.args[1]
	crane_model := os.args[2]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	stacks := make([dynamic]^Stack, 0, 16)

	crates_built := false

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		if len(line) == 0 {
			continue
		}

		if !crates_built {
			if line[1] == '1' {
				crates_built = true
				continue
			}

			stack_index := 0
			line_data := string(line)
			for label in split_line_into_crates_iterator(&line_data) {
				if label != nil {
					if len(stacks) <= stack_index {
						inject_at(&stacks, stack_index, new(Stack))
					} else if stacks[stack_index] == nil {
						stacks[stack_index] = new(Stack)
					}

					add_crate(stacks[stack_index], label.?)
				}

				stack_index += 1
			}
		} else {
			words := strings.split(line, " ")

			count := strconv.parse_int(words[1]) or_else 0
			from := (strconv.parse_int(words[3]) or_else 0) - 1
			to := (strconv.parse_int(words[5]) or_else 0) - 1

			if crane_model == "9001" {
				move_crates_grouped(stacks[from], stacks[to], count)
			} else {
				move_crates_individually(stacks[from], stacks[to], count)
			}
		}
	}

	for stack in stacks {
		fmt.print(stack.top.label)
	}
	fmt.println()
}

add_crate :: proc(stack: ^Stack, label: rune) {
	crate := new(Crate)
	crate.label = label
	if stack.top == nil do stack.top = crate
	if stack.bottom != nil do stack.bottom.next = crate
	stack.bottom = crate
}

move_crates_individually :: proc(from: ^Stack, to: ^Stack, count: int) {
	for i in 0 ..< count {
		crate := from.top
		from.top = crate.next
		crate.next = to.top
		to.top = crate
	}
}

move_crates_grouped :: proc(from: ^Stack, to: ^Stack, count: int) {
	top_crate := from.top
	bottom_crate := from.top
	for i := 0; i < count - 1; i += 1 {
		bottom_crate = bottom_crate.next
	}

	from.top = bottom_crate.next
	bottom_crate.next = to.top
	to.top = top_crate
}

print_stack :: proc(stack: ^Stack) {
	for crate := stack.top; crate != nil; crate = crate.next {
		fmt.print(crate.label)
	}
	fmt.println()
}

split_line_into_crates_iterator :: proc(line: ^string) -> (label: Maybe(rune), ok: bool) {
	if line == nil || len(line^) < 3 {
		return nil, false
	}

	if len(line^) == 3 {
		label = rune(line[1])
		ok = true
		line^ = line[len(line):]
	} else if line[1] == ' ' {
		label = nil
		ok = true
		line^ = line[4:]
	} else {
		label = rune(line[1])
		ok = true
		line^ = line[4:]
	}
	return
}
