package aoc2024

import "core:fmt"
import "core:mem"
import "core:strings"

day6_part1 :: proc(input: string) -> (result: int) {
	start_x, start_y, grid := parse_grid(input, context.temp_allocator)
	visited := simulate(grid, start_x, start_y, .North, context.temp_allocator)
	for row in visited.rows {
		for chunk in row {
			result += card(chunk)
		}
	}
	return
}

CHUNK_SIZE :: 32

Row :: distinct []bit_set[0..<CHUNK_SIZE]

Grid :: struct {
	allocator: mem.Allocator,
	rows: []Row,
	row_len: int,
}

grid_new :: proc(rows, columns: int, allocator := context.allocator) -> (grid: Grid) {
	grid.allocator = allocator
	grid.row_len = columns
	grid.rows = make([]Row, rows, allocator)
	for &row in grid.rows {
		row = make(Row, (columns + CHUNK_SIZE - 1)/CHUNK_SIZE, allocator)
	}
	return
}

row_get :: #force_inline proc(row: Row, x: int) -> bool {
	return (x % CHUNK_SIZE) in row[x / CHUNK_SIZE]
}

row_set :: #force_inline proc(row: Row, x: int, val: bool) {
	if val {
		row[x / CHUNK_SIZE] |= { x % CHUNK_SIZE }
	} else {
		row[x / CHUNK_SIZE] &~= { x % CHUNK_SIZE }
	}
}

grid_get :: proc(grid: Grid, x, y: int) -> bool {
	(y < len(grid.rows)) or_return
	(x < grid.row_len) or_return
	return row_get(grid.rows[y], x)
}

grid_set :: proc(grid: Grid, x, y: int, val: bool) {
	if (y < len(grid.rows)) && (x < grid.row_len) {
		row_set(grid.rows[y], x, val)
	}
}

grid_destroy :: proc(grid: Grid) {
	for row in grid.rows {
		delete(row, grid.allocator)
	}
	delete(grid.rows, grid.allocator)
}

parse_grid :: proc(s: string, allocator := context.allocator) -> (x, y: int, grid: Grid) {
	lines := strings.split_lines(s, allocator)
	defer delete(lines, allocator)

	assert(len(lines) != 0, "grid can't be empty")
	row_len := len(lines[0])
	for line in lines[1:] {
		assert(len(line) == row_len, "all rows must be the same length")
	}

	grid = grid_new(len(lines), row_len, allocator)

	x, y = -1, -1
	for line, r in lines {
		for i in 0 ..< row_len {
			if line[i] == '#' {
				row_set(grid.rows[r], i, true)
			} else if line[i] == '^' {
				x = i
				y = r
			}
		}
	}
	assert(x >= 0 && y >= 0, "starting position not found")

	return
}

dump_grid :: proc(grid: Grid) {
	for row in grid.rows {
		dump_row(row, grid.row_len)
	}
}

dump_row :: proc(row: Row, max_len: int) {
	count: int
	for i in 0 ..< len(row) {
		for j in 0 ..< CHUNK_SIZE {
			count += 1
			if count > max_len {
				fmt.println()
				return
			}
			fmt.print(j in row[i] ? '#' : '.')
		}
	}
}

Direction :: enum u8 {
	North,
	East,
	South,
	West,
}

rot90 :: proc(d: Direction) -> Direction {
	return Direction((int(d) + 1) % 4)
}

simulate :: proc(grid: Grid, start_x, start_y: int, dir: Direction, allocator := context.allocator) -> Grid {
	visited := grid_new(len(grid.rows), grid.row_len, allocator)
	grid_set(visited, start_x, start_y, true)

	step(grid, start_x, start_y, dir, visited)
	return visited
}

step :: proc(grid: Grid, start_x, start_y: int, dir: Direction, visited: Grid) {
	switch dir {
	case .North:
		for y := start_y - 1; y >= 0; y -= 1 {
			if row_get(grid.rows[y], start_x) {
				step(grid, start_x, y+1, rot90(dir), visited)
				break
			}
			row_set(visited.rows[y], start_x, true)
		}
	case .East:
		for x := start_x + 1; x < grid.row_len; x += 1 {
			if row_get(grid.rows[start_y], x) {
				step(grid, x-1, start_y, rot90(dir), visited)
				break
			}
			row_set(visited.rows[start_y], x, true)
		}
	case .South:
		for y := start_y + 1; y < len(grid.rows); y += 1 {
			if row_get(grid.rows[y], start_x) {
				step(grid, start_x, y-1, rot90(dir), visited)
				break
			}
			row_set(visited.rows[y], start_x, true)
		}
	case .West:
		for x := start_x - 1; x >= 0; x -= 1 {
			if row_get(grid.rows[start_y], x) {
				step(grid, x+1, start_y, rot90(dir), visited)
				break
			}
			row_set(visited.rows[start_y], x, true)
		}
	}
	return
}

import "core:testing"

@(test)
test_parse_grid :: proc(t: ^testing.T) {
	x, y, grid := parse_grid(SAMPLE)
	defer grid_destroy(grid)

	// fmt.printf("\n\n\n\n")
	// dump_grid(grid)

	visited := simulate(grid, x, y, .North)
	defer grid_destroy(visited)

	// fmt.printf("\n\n\n\n")
	// dump_grid(visited)
	// fmt.printf("\n\n\n\n")

	testing.expect_value(t, x, 4)
	testing.expect_value(t, y, 6)
	testing.expect_value(t, grid.row_len, 10)
}

@(test)
test_day6_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day6_part1(SAMPLE), 41)
}

@(private="file")
SAMPLE ::
	"....#.....\n" +
	".........#\n" +
	"..........\n" +
	"..#.......\n" +
	".......#..\n" +
	"..........\n" +
	".#..^.....\n" +
	"........#.\n" +
	"#.........\n" +
	"......#...";
