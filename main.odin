package main

import "core:fmt"
import "core:flags"
import "core:os"
import "core:strconv"
import "base:runtime"

Operation :: enum {
  list,
  add,
  delete,
  complete,
}

Input :: union {
  string,
  int
}

Options :: struct {
  op: Operation `args:"pos=0" usage:"Operation to perform on todos"`,
  input: Input `args:"pos=1"`
}

main :: proc() {
  opt: Options
  style: flags.Parsing_Style = .Odin

  flags.register_type_setter(input_arg_setter)
  flags.parse_or_exit(&opt, os.args, style)

  todos, err := read_todos()
  if err != TodoError.None {
    fmt.printfln("error reading todos: %v", err)
    os.exit(1)
  }

  #partial switch opt.op {
  case .add:
    add_todo(&todos, opt.input.(string))
  case .complete:
    toggle_todo(&todos, opt.input.(int))
  case .delete:
    remove_todo(&todos, opt.input.(int))
  }

  if err := store_todos(&todos); err != nil {
    fmt.printfln("error storing todos: %v", err)
  }
  print_todos(todos)
}

input_arg_setter :: proc(
	data_ptr: rawptr,
	data_type: typeid,
	unparsed_value: string,
	args_tag: string,
) -> (
	error: string,
	handled: bool,
	alloc_error: runtime.Allocator_Error,
) {
  data := any{ data=data_ptr, id=data_type}
  switch &value in data {
    case Input:
      handled = true
      if i, ok := strconv.parse_int(unparsed_value); ok {
        value = i
      } else {
        value = unparsed_value
      }
  }
  return
}
