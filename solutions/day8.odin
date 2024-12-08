package aoc2024

import "core:strings"

day8_part1 :: proc(input: string) -> (result: int) {
	nodes := parse_node_map(input, context.temp_allocator)
	an := antinodes(nodes, context.temp_allocator)
	for n in an {
		result += int(n)
	}
	return
}

day8_part2 :: proc(input: string) -> (result: int) {
	nodes := parse_node_map(input, context.temp_allocator)
	an := antinodes2(nodes, context.temp_allocator)
	for n in an {
		result += int(n)
	}
	return
}

Node_Map :: struct {
	w, h: int,
	// indexed by ascii values
	locs: [128][dynamic][2]int,
}

parse_node_map :: proc(s: string, allocator := context.allocator) -> (m: Node_Map) {
	lines := strings.split_lines(s, allocator)
	defer delete(lines, allocator)

	assert(len(lines) != 0, "grid can't be empty")
	m.h = len(lines)
	m.w = len(lines[0])
	for line in lines[1:] {
		assert(len(line) == m.w, "all rows must be the same length")
	}

	for &loc in m.locs {
		loc.allocator = allocator
	}
	for line, y in lines {
		for x in 0 ..< len(line) {
			freq := line[x]
			if freq != '.' {
				append(&m.locs[freq], [2]int{x, y})
			}
		}
	}

	return
}

in_bounds :: #force_inline proc "contextless" (ns: Node_Map, loc: [2]int) -> bool {
	return 0 <= loc.x && loc.x < ns.w && 0 <= loc.y && loc.y < ns.h
}

antinodes :: proc(nodes: Node_Map, allocator := context.allocator) -> []bool #no_bounds_check {
	ret := make([]bool, nodes.w * nodes.h, allocator)
	for loc in nodes.locs {
		for i := 1; i < len(loc); i += 1 {
			for j := 0; j < i; j += 1 {
				diff := loc[i] - loc[j]
				if a1 := loc[i] + diff; in_bounds(nodes, a1) {
					ret[a1.y * nodes.w + a1.x] = true
				}
				if a2 := loc[j] - diff; in_bounds(nodes, a2) {
					ret[a2.y * nodes.w + a2.x] = true
				}
			}
		}
	}
	return ret
}

antinodes2 :: proc(nodes: Node_Map, allocator := context.allocator) -> []bool #no_bounds_check {
	ret := make([]bool, nodes.w * nodes.h, allocator)
	for loc in nodes.locs {
		for i := 1; i < len(loc); i += 1 {
			for j := 0; j < i; j += 1 {
				diff := loc[i] - loc[j]
				for a1 := loc[i]; in_bounds(nodes, a1); a1 += diff {
					ret[a1.y * nodes.w + a1.x] = true
				}
				for a2 := loc[j]; in_bounds(nodes, a2); a2 -= diff {
					ret[a2.y * nodes.w + a2.x] = true
				}
			}
		}
	}
	return ret
}

import "core:testing"

@(test)
test_day8_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day8_part1(SAMPLE), 14)
}

@(test)
test_day8_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, day8_part2(SAMPLE), 34)
}

@(private="file")
SAMPLE ::
	"............\n" +
	"........0...\n" +
	".....0......\n" +
	".......0....\n" +
	"....0.......\n" +
	"......A.....\n" +
	"............\n" +
	"............\n" +
	"........A...\n" +
	".........A..\n" +
	"............\n" +
	"............";
