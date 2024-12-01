package main

import "core:flags"
import "core:fmt"
import "core:os"
import "core:sys/posix"
import "solutions"

Args :: struct {
	day:     int `args:"" usage:"Day (1-25)"`,
	part:    int `args:"" usage:"Part (1 or 2), leave unset to run both"`,
	session: string `args:"" usage:"custom cookie for authentication"`,
}

arg_checker :: proc(model: rawptr, name: string, value: any, args_tag: string) -> (error: string) {
	if name == "day" {
		v := value.(int)
		if !(1 <= v && v <= 25) {
			error = "Valid day range is 1 ..= 25"
		}
	}
	if name == "part" {
		v := value.(int)
		if !(1 <= v && v <= 2) {
			error = "Valid part range is 1 ..= 2"
		}
	}
	return
}

main :: proc() {
	defer free_all(context.temp_allocator)
	flags.register_flag_checker(arg_checker)
	args := Args {
		day = 1,
	}
	flags.parse_or_exit(&args, os.args)
	input_path := fmt.tprintf("inputs/day%v", args.day)
	if !os.exists(input_path) {
		if args.session == "" {
			session, ok := os.read_entire_file("aoc.session")
			if ok {
				args.session = string(session)
			}
		}
		if args.session == "" {
			fmt.eprintln(
				"Error: To download the input you must specify a session cookie in 'aoc.session' file or through the '-session' flag",
			)
			fmt.eprintfln(
				"Or just download the file manually and save int in inputs/day%v",
				args.day,
			)
			os.exit(1)
		}

		child_pid := posix.fork()
		switch child_pid {
		case -1:
			// `fork` failed.
			panic("fork failed")

		case 0:
			// This is the child.
			fmt.eprintln("Downloading input...")
			err := os.execvp(
				"curl",
				{
					fmt.tprintf("https://adventofcode.com/2024/day/%v/input", args.day),
					"--cookie",
					fmt.tprintf("session=%v", args.session),
					"-o",
					input_path,
				},
			)
			if err != nil {
				fmt.eprintln("Error downloading input:", err)
				os.exit(1)
			}

		case:
			status: i32
			for {
				wpid := posix.waitpid(child_pid, &status, {.UNTRACED, .CONTINUED})
				if wpid == -1 {
					panic("waitpid failure")
				}

				switch {
				case posix.WIFEXITED(status):
					fmt.printfln("child exited, status=%v", posix.WEXITSTATUS(status))
				case posix.WIFSIGNALED(status):
					fmt.printfln("child killed (signal %v)", posix.WTERMSIG(status))
				case posix.WIFSTOPPED(status):
					fmt.printfln("child stopped (signal %v", posix.WSTOPSIG(status))
				case posix.WIFCONTINUED(status):
					fmt.println("child continued")
				case:
					// Should never happen.
					fmt.println("unexpected status (%x)", status)
				}

				if posix.WIFEXITED(status) || posix.WIFSIGNALED(status) {
					break
				}
			}
		}
	}

	input_bytes, err := os.read_entire_file_or_err(input_path)
	if err != nil {
		fmt.eprintln("Error reading input:", err)
		os.exit(1)
	}

	input := string(input_bytes)
	if input[len(input) - 1] == '\n' {
		input = input[:len(input) - 1]
	}
	defer delete(input)

	switch args.part {
	case 0:
		dur1 := solutions.solve(args.day, 1, input)
		dur2 := solutions.solve(args.day, 2, input)
		fmt.printfln("Total time: %v", dur1 + dur2)
	case:
		solutions.solve(args.day, args.part, input)
	}
}
