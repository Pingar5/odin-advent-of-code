package day02

import "core:os"
import "core:fmt"
import "core:strings"


part1 :: proc(input_file_path: string) {
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	total_points := 0

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		enemy_move := char_to_move(line[0])
		friendly_move := char_to_move(line[2])

		total_points += int(friendly_move)
		if friendly_move == enemy_move {
			total_points += int(Result.TIE)
		} else if (enemy_move == Move.ROCK && friendly_move == Move.PAPER) ||
		   (enemy_move == Move.PAPER && friendly_move == Move.SCISSORS) ||
		   (enemy_move == Move.SCISSORS && friendly_move == Move.ROCK) {
			total_points += int(Result.WIN)
		} else {
            total_points += int(Result.LOSS)
        }
	}

	fmt.println(total_points)
}