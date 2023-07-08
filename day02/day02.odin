package day02

import "core:os"
import "core:fmt"

Move :: enum {
	NONE     = 0,
	ROCK     = 1,
	PAPER    = 2,
	SCISSORS = 3,
}

Result :: enum {
    LOSS = 0,
    TIE = 3,
    WIN = 6,
}

main :: proc() {
    part := os.args[1]
    input_file_path := os.args[2]
    
    if part == "1" do part1(input_file_path)
    else do part2(input_file_path)
}

char_to_move :: proc(move_char: u8) -> Move {
	switch move_char {
	case 'A', 'X':
		return Move.ROCK
	case 'B', 'Y':
		return Move.PAPER
	case 'C', 'Z':
		return Move.SCISSORS
	case:
		fmt.println("Invalid move:", move_char)
		return Move.NONE
	}
}
