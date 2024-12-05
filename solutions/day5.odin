package aoc2024

import "core:slice"
import "core:strings"

Ordering_Rules :: [100]bit_set[0..<100]

day5_part1 :: proc(input: string) -> (result: int) {
	s1, m, s2 := strings.partition(input, "\n\n")
	assert(m == "\n\n")

	rules, ok := parse_rules(s1)
	assert(ok, "error parsing rules")

	values := make([dynamic]int, context.temp_allocator)
	for line in strings.split_lines_iterator(&s2) {
		assert(parse_list(line, &values))
		if validate(values[:], &rules) {
			result += values[len(values) / 2]
		}
		clear(&values)
	}

	return
}

day5_part2 :: proc(input: string) -> (result: int) {
	s1, m, s2 := strings.partition(input, "\n\n")
	assert(m == "\n\n")

	rules, ok := parse_rules(s1)
	assert(ok, "error parsing rules")

	values := make([dynamic]int, context.temp_allocator)
	for line in strings.split_lines_iterator(&s2) {
		assert(parse_list(line, &values))
		if !validate(values[:], &rules) {
			sort(values[:], &rules)
			result += values[len(values) / 2]
		}
		clear(&values)
	}

	return
}

@(private="file")
validate :: proc(values: []int, ordering: ^Ordering_Rules) -> bool {
	context.user_ptr = ordering
	return slice.is_sorted_by_cmp(values, cmp)
}

@(private="file")
sort :: proc(values: []int, rules: ^Ordering_Rules) {
	context.user_ptr = rules
	slice.sort_by_cmp(values, cmp)
}

@(private="file")
cmp :: proc(v1: int, v2: int) -> slice.Ordering {
	rules := (^Ordering_Rules)(context.user_ptr)^
	if v1 in rules[v2] {
		return .Greater
	}
	if v2 in rules[v1] {
		return .Less
	}
	return .Equal
}

@(private="file")
parse_single_rule :: proc(s: string) -> (a, b: int, ok: bool) {
	entry := s
	a = chop_int(&entry) or_return
	chop_prefix(&entry, "|") or_return
	b = chop_int(&entry) or_return
	ok = entry == ""
	return
}

@(private="file")
parse_rules :: proc(s: string) -> (rules: Ordering_Rules, ok: bool) {
	lines := s
	for line in strings.split_lines_iterator(&lines) {
		i, j := parse_single_rule(line) or_return
		rules[i] |= {j}
	}
	ok = true
	return
}

parse_list :: proc(s: string, out: ^[dynamic]int) -> (ok: bool) {
	entry := s
	for entry != "" {
		a := chop_int(&entry) or_return
		append(out, a)
		chop_prefix(&entry, ",")
	}
	return true
}

import "core:testing"

@(test)
test_day5_part1 :: proc(t: ^testing.T) {
	testing.expect_value(t, day5_part1(SAMPLE), 143)
}

@(test)
test_day5_part2 :: proc(t: ^testing.T) {
	testing.expect_value(t, day5_part2(SAMPLE), 123)
}

SAMPLE ::
	"47|53\n" +
	"97|13\n" +
	"97|61\n" +
	"97|47\n" +
	"75|29\n" +
	"61|13\n" +
	"75|53\n" +
	"29|13\n" +
	"97|29\n" +
	"53|29\n" +
	"61|53\n" +
	"97|53\n" +
	"61|29\n" +
	"47|13\n" +
	"75|47\n" +
	"97|75\n" +
	"47|61\n" +
	"75|61\n" +
	"47|29\n" +
	"75|13\n" +
	"53|13\n" +
	"\n" +
	"75,47,61,53,29\n" +
	"97,61,53,29,13\n" +
	"75,29,13\n" +
	"75,97,47,61,53\n" +
	"61,13,29\n" +
	"97,13,75,29,47\n";
