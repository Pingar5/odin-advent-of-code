package day03

import "core:fmt"
import "core:os"
import "core:strings"

ItemTypeSet :: bit_set['A'..='z'];

main :: proc() {
    input_file_path := os.args[1]
    raw, ok := os.read_entire_file(input_file_path, context.allocator)
    
    if !ok {
        fmt.println("Could not read file")
        return
    }
    defer delete(raw, context.allocator)
    
    part1_answer := 0
    part2_answer := 0
    
    data := string(raw)
    lines, err := strings.split_lines(data)
    
    if err != .None {
        fmt.println("Could not split file into lines")
        return
    }
    
    for i := 0; i < len(lines); i += 3 {
        group_shares: ItemTypeSet = {}
        
        for j in 0..<3 {
            line := lines[i + j]
            half_index := len(line) / 2
            
            full_line_set: ItemTypeSet = {}
            first_half_set: ItemTypeSet = {}
            second_half_set: ItemTypeSet = {}
            
            for i in 0..<len(line) {
                full_line_set += {rune(line[i])}
                
                if i < half_index {
                    first_half_set += {rune(line[i])}
                } else {
                    second_half_set += {rune(line[i])}
                }
            }
            
            if j == 0 do group_shares = full_line_set
            else do group_shares &= full_line_set
            
            in_both_halves := first_half_set & second_half_set
            part1_answer += char_to_priority(extract_values_from_bit_set(in_both_halves)[0])
        }
        
        part2_answer += char_to_priority(extract_values_from_bit_set(group_shares)[0])
    }
    
    fmt.println("Part 1:", part1_answer)
    fmt.println("Part 2:", part2_answer)
}

char_to_priority :: proc(char: rune) -> int {
    if char >= 97 {
        return int(char) - 96
    } else {
        return int(char) - 64 + 26
    }
}

extract_values_from_bit_set :: proc(set: ItemTypeSet) -> []rune {
    values: [dynamic]rune;
    for r in 'A'..='z' {
        if r in set {
            append(&values, r)
        }
    }
    return values[:]
}