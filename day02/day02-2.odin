package day02

import "core:os"
import "core:fmt"
import "core:strings"

part2 :: proc(input_file_path: string) {
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
		result := char_to_result(line[2])
		friendly_move: Move
		
		total_points += int(result)
		
		if result == Result.TIE {
			friendly_move = enemy_move
		} else if result == Result.LOSS {
			friendly_move_int := int(enemy_move) - 1
			if friendly_move_int == 0 do friendly_move_int = 3
			friendly_move = Move(friendly_move_int)
		} else {
			friendly_move_int := int(enemy_move) + 1
			if friendly_move_int == 4 do friendly_move_int = 1
			friendly_move = Move(friendly_move_int)
		}
		
		total_points += int(friendly_move)
	}

	fmt.println(total_points)
}

char_to_result :: proc(result_char: u8) -> Result {
	switch result_char {
	case 'X':
		return Result.LOSS
	case 'Y':
		return Result.TIE
	case 'Z':
		return Result.WIN
	case:
		fmt.println("Invalid result:", result_char)
		return Result.LOSS
	}
}