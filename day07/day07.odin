package day07

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:container/queue"

Directory :: struct {
	name:     string,
	size:     int,
	parent:   ^Directory,
	children: [dynamic]^Directory,
}

MAX_SIZE_TO_SUM :: 100_000
TOTAL_DISK_SPACE :: 70_000_000
SPACE_NEEDED :: 30_000_000

main :: proc() {
	input_file_path := os.args[1]
	raw, ok := os.read_entire_file(input_file_path)

	if !ok {
		fmt.println("Could not read file")
		return
	}
	defer delete(raw, context.allocator)

	root := new(Directory)
	root.name = "/"
	current_directory := root
	sum_of_small_directories := 0

	data := string(raw)
	for line in strings.split_lines_iterator(&data) {
		if line == "$ cd .." {
			if current_directory.size <= MAX_SIZE_TO_SUM {
				sum_of_small_directories += current_directory.size
			}

			parent := current_directory.parent
			parent.size += current_directory.size
			current_directory = parent
		} else if strings.has_prefix(line, "$ cd") {
			name := line[5:]

			if name != "/" {
				new_directory := new(Directory)
				append(&current_directory.children, new_directory)
				new_directory.name = line[5:]
				new_directory.parent = current_directory
				current_directory = new_directory
			}
		} else if strings.has_prefix(line, "$ ls") {
			// Do nothing
		} else if strings.has_prefix(line, "dir ") {
			// Do nothing
		} else {
			split_line, err := strings.split(line, " ")
			current_directory.size += strconv.parse_int(split_line[0]) or_else 0
		}
	}

	for ; current_directory != root; current_directory = current_directory.parent {
		if current_directory.size <= MAX_SIZE_TO_SUM {
			sum_of_small_directories += current_directory.size
		}

		current_directory.parent.size += current_directory.size
	}

	space_available := TOTAL_DISK_SPACE - root.size
	minimum_size_to_delete := SPACE_NEEDED - space_available
	smallest_deletable_directory_size := root.size

	dfs_queue := depth_first_search_init(root)
	for dir in depth_first_search_iterator(dfs_queue) {
		if dir.size < smallest_deletable_directory_size && dir.size >= minimum_size_to_delete {
			smallest_deletable_directory_size = dir.size
		}
	}
	free(dfs_queue)

	fmt.println("Part 1: ", sum_of_small_directories)
	fmt.println("Part 2: ", smallest_deletable_directory_size)
}

depth_first_search_init :: proc(root: ^Directory) -> ^queue.Queue(^Directory) {
	dfs_queue := new(queue.Queue(^Directory))
	queue.init(dfs_queue)
	queue.push(dfs_queue, root)
	return dfs_queue
}

depth_first_search_iterator :: proc(
	to_visit: ^queue.Queue(^Directory),
) -> (
	next_value: ^Directory,
	ok: bool,
) {
	if queue.len(to_visit^) == 0 do return nil, false

	next_value = queue.pop_front(to_visit)
	ok = true

	for child in next_value.children {
		push_ok, err := queue.push_back(to_visit, child)
		if !push_ok do return nil, false
	}

	return
}
