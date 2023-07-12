package day11

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"

MONKEY_ENTRY_LENGTH :: 7

Operator :: enum {
	Add,
	Multiply,
	Exponent,
}

Operation :: struct {
	operator: Operator,
	operand:  int,
}

Monkey :: struct {
	index:                int,
	items:                [dynamic]int,
	operation:            Operation,
	divisor:              int,
	divisible_target:     int,
	non_divisible_target: int,
	inspection_count:     int,
}

main :: proc() {
	input_file_path := os.args[1]
	part := os.args[2]
	raw, ok := os.read_entire_file(input_file_path, context.allocator)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	monkeys := parse_monkeys(string(raw))
	least_common_multiple := select_least_common_multiple(monkeys)

	max_item: int = 0
	max_rounds := part == "1" ? 20 : 10_000
	for round_number in 1 ..= max_rounds {
		for monkey in monkeys {
			if len(monkey.items) == 0 do continue

			for len(monkey.items) > 0 {
				item := pop_front(&monkey.items)

				item = apply_operation(item, monkey.operation)
				if part == "1" do item /= 3

				if item > max_item do max_item = item

				target_index :=
					item % monkey.divisor == 0 \
					? monkey.divisible_target \
					: monkey.non_divisible_target

				item %= least_common_multiple

				append(&monkeys[target_index].items, item)

				monkey.inspection_count += 1
			}
		}
	}

	best_inspection_count := 0
	second_best_inspection_count := 0

	for monkey in monkeys {
		if monkey.inspection_count > best_inspection_count {
			second_best_inspection_count = best_inspection_count
			best_inspection_count = monkey.inspection_count
		} else if monkey.inspection_count > second_best_inspection_count {
			second_best_inspection_count = monkey.inspection_count
		}
	}

	fmt.println("Monkey business:", best_inspection_count * second_best_inspection_count)
}

apply_operation :: proc(item: int, operation: Operation) -> int {
	switch operation.operator {
	case .Add:
		return item + operation.operand
	case .Exponent:
		return item * item
	case .Multiply:
		return item * operation.operand
	}

	return 0
}

parse_monkeys :: proc(data: string) -> [dynamic]^Monkey {
	monkeys := make([dynamic]^Monkey)
	lines := strings.split_lines(data)

	for line_index := 0; line_index < len(lines); line_index += MONKEY_ENTRY_LENGTH {
		monkey := new(Monkey)
		monkey.index = line_index / MONKEY_ENTRY_LENGTH

		starting_item_strings := strings.split(lines[line_index + 1][18:], ", ")
		for item_string in starting_item_strings {
			append(&monkey.items, strconv.parse_int(item_string) or_else 0)
		}

		operation := Operation{}
		operator_text := rune(lines[line_index + 2][23])
		operand_text := lines[line_index + 2][25:]

		if operator_text == '+' do operation.operator = .Add
		else {
			if operand_text == "old" {
				operation.operator = .Exponent
				operation.operand = 2
			} else {
				operation.operator = .Multiply
			}
		}

		if operand_text != "old" do operation.operand = strconv.parse_int(operand_text) or_else 0

		monkey.operation = operation

		monkey.divisor = strconv.parse_int(lines[line_index + 3][21:]) or_else 0
		monkey.divisible_target = strconv.parse_int(lines[line_index + 4][29:]) or_else 0
		monkey.non_divisible_target = strconv.parse_int(lines[line_index + 5][30:]) or_else 0

		monkey.inspection_count = 0

		append(&monkeys, monkey)
	}

	return monkeys
}

select_least_common_multiple :: proc(monkeys: [dynamic]^Monkey) -> (lcm: int = 1) {
	for monkey in monkeys {
		lcm = math.lcm(lcm, monkey.divisor)
	}
	return
}
