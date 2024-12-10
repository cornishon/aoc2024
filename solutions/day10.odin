package aoc2024

import "core:strings"

day10_part1 :: proc(input: string) -> (result: int) {
	hm := parse_height_map(input)
	defer delete(hm.values)
	for v, i in hm.values {
		if v == 0 {
			result += trailhead_score(hm, i, context.temp_allocator)
			free_all(context.temp_allocator)
		}
	}
	return
}

day10_part2 :: proc(input: string) -> (result: int) {
	hm := parse_height_map(input)
	defer delete(hm.values)
	for v, i in hm.values {
		if v == 0 {
			result += trailhead_rating(hm, i, context.temp_allocator)
			free_all(context.temp_allocator)
		}
	}
	return
}

Height_Map :: struct {
	width, height: int,
	values: []u8,
}

parse_height_map :: proc(s: string, allocator := context.allocator) -> (hm: Height_Map) {
	lines := strings.split_lines(s, allocator)
	defer delete(lines, allocator)

	assert(len(lines) != 0, "grid can't be empty")
	hm.height = len(lines)
	hm.width = len(lines[0])
	for line in lines[1:] {
		assert(len(line) == hm.width, "all rows must be the same length")
	}

	hm.values = make([]u8, hm.width * hm.height, allocator)

	for line, y in lines {
		row_offset := y * hm.width
		for x in 0 ..< hm.width {
			hm.values[row_offset + x] = line[x] - '0'
		}
	}
	
	return
}

trailhead_score :: proc(hm: Height_Map, trailhead: int, allocator := context.allocator) -> (score: int) {
	stack := make([dynamic]int, 1, 16, allocator)
	stack[0] = trailhead
	defer delete(stack)
	visited := make([]bool, len(hm.values), allocator)
	defer delete(visited, allocator)

	for len(stack) != 0 {
		v := pop(&stack)
		visited[v] = true
		nbors := [4]int{
			v + 1 if (v + 1) % hm.width != 0 else -1,
			v - 1 if v % hm.width != 0 else -1,
			v + hm.width,
			v - hm.width,
		}
		hm_len := len(hm.values)
		for n in nbors {
			if 0 <= n && n < hm_len && !visited[n] && hm.values[n] - hm.values[v] == 1 {
				if hm.values[n] == 9 {
					score += 1
				}
				append(&stack, n)
			}
		}
	}
	return
}

trailhead_rating :: proc(hm: Height_Map, trailhead: int, allocator := context.allocator) -> (rating: int) {
	stack := make([dynamic]int, 1, 16, allocator)
	stack[0] = trailhead
	defer delete(stack)

	for len(stack) != 0 {
		v := pop(&stack)
		nbors := [4]int{
			v + 1 if (v + 1) % hm.width != 0 else -1,
			v - 1 if v % hm.width != 0 else -1,
			v + hm.width,
			v - hm.width,
		}
		hm_len := len(hm.values)
		for n in nbors {
			if 0 <= n && n < hm_len && hm.values[n] - hm.values[v] == 1 {
				if hm.values[n] == 9 {
					rating += 1
				}
				append(&stack, n)
			}
		}
	}
	return
}

import "core:testing"

@(test)
test_day10_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day10_part1(SAMPLE), 36)
}

@(test)
test_day10_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, day10_part2(SAMPLE), 81)
}

@(private="file")
SAMPLE ::
	"89010123\n" +
	"78121874\n" +
	"87430965\n" +
	"96549874\n" +
	"45678903\n" +
	"32019012\n" +
	"01329801\n" +
	"10456732";
