package day10

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

DEBUG :: false

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	sum_of_signal_strengths := 0
	current_cycle := 0
	x := 1
	current_crt_row := strings.Builder{}

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		command := strings.split(line, " ")

		cycles: int = 1
		if command[0] == "addx" do cycles = 2

		if DEBUG {
			fmt.println()
			fmt.println("Command:", line)
		}

		for i in 0 ..< cycles {
			current_cycle += 1
			if DEBUG do fmt.println("Cycle =", current_cycle)

			print_pixel(&current_crt_row, current_cycle % 40 - 1, x)

			if (current_cycle - 20) % 40 == 0 {
				sum_of_signal_strengths += current_cycle * x
			} else if current_cycle % 40 == 0 {
				fmt.println(strings.to_string(current_crt_row))
				current_crt_row = strings.Builder{}
			}

			if DEBUG {
				fmt.println("Current CRT Row:", strings.to_string(current_crt_row))

				debug_row := strings.Builder{}
				for pixel in 0 ..< 40 {
					print_pixel(&debug_row, pixel, x)
				}
				fmt.println("Sprite position:", strings.to_string(debug_row))
			}
		}

		if command[0] == "addx" {
			value := strconv.atoi(command[1])
			x += value
		}
	}

	fmt.println(sum_of_signal_strengths)
}

print_pixel :: proc(row: ^strings.Builder, pixel_position: int, sprite_position: int) {
	strings.write_rune(row, abs(pixel_position - sprite_position) <= 1 ? '#' : '.')
	fmt.print()
}
