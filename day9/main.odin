package day9

import "core:slice"
import "../utils"

main :: proc() {
	utils.solve_day(9, part1, part2)
}

part1 :: proc(input: string) -> (result: int) {
	fm := parse_file_map(input, context.temp_allocator)
	compact := compactify(fm, context.temp_allocator)
	return checksum(compact)
}

part2 :: proc(input: string) -> (result: int) {
	fm := parse_file_map(input, context.temp_allocator)
	compact := compactify2(fm, context.temp_allocator)
	return checksum(compact)
}

File_Entry :: struct {
	offset: int,
	size: int,
}

checksum :: proc(compact: []i16) -> (result: int) {
	for id, i in compact {
		if id != -1 do result += int(id) * i
	}
	return
}

compactify2 :: proc(fm: []File_Entry, allocator := context.temp_allocator) -> (compact: []i16) {
	last_entry := fm[len(fm)-1]
	compact_size := last_entry.offset + last_entry.size

	compact = make([]i16, compact_size, allocator)
	for &x in compact do x = -1

	for e, id in fm {
		for i in 0 ..< e.size {
			idx := e.offset + i
			compact[idx] = i16(id)
		}
	}

	find_slot :: proc(compact: []i16, size: int) -> []i16 {
		offset: int
		search: for {
			i, found := slice.linear_search(compact[offset:], -1)
			start := i + offset
			end := start + size
			if !found || end > len(compact) {
				return nil
			}
			for id, j in compact[start:end] {
				if id != -1 {
					offset = start + j
					continue search
				}
			}
			return compact[start:end]
		}
		return nil
	}

	for id := len(fm) - 1; id > 0; id -= 1 {
		entry := fm[id]
		end := entry.offset + entry.size
		if slot := find_slot(compact[:entry.offset], entry.size); slot != nil {
			slice.swap_between(slot, compact[entry.offset:end])
		}
	}

	return
}

compactify :: proc(fm: []File_Entry, allocator := context.temp_allocator) -> (compact: []i16) {
	compact_size: int
	for e in fm do compact_size += e.size

	compact = make([]i16, compact_size, allocator)
	for &c in compact do c = -1

	outer: for e, id in fm {
		for i in 0 ..< e.size {
			idx := e.offset + i
			(idx < len(compact)) or_break outer
			compact[idx] = i16(id)
		}
	}

	id := len(fm)-1
	entry: File_Entry = fm[id]
	for &c in compact {
		if c == -1 {
			c = i16(id)
			entry.size -= 1
		}
		if entry.size <= 0 {
			id -= 1
			entry = fm[id]
		}
	}

	return
}

parse_file_map :: proc(s: string, allocator := context.allocator) -> []File_Entry {
	offset: int
	entry_count: int
	fm := make([]File_Entry, len(s)/2 + 1, allocator)
	for i in 0 ..< len(s) {
		size := int(s[i] - '0')
		if i&1 == 0 {
			fm[entry_count] = { offset, size }
			entry_count += 1
		}
		offset += size
	}
	return fm[:entry_count]
}

import "core:testing"

@(test)
test_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part1(SAMPLE), 1928)
}

@(test)
test_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part2(SAMPLE), 2858)
}

@(private="file")
SAMPLE :: "2333133121414131402";
