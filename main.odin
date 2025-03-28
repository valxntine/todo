package main

import "core:fmt"
import "core:flags"
import "core:os"
import "core:strconv"

Operation :: enum {
  list,
  add,
  delete,
  complete,
}

Options :: struct {
  op: Operation `args:"pos=0" usage:"Operation to perform on todos"`,
  input: string `args:"pos=1"`
}

main :: proc() {
  opt: Options
  style: flags.Parsing_Style = .Odin

  flags.parse_or_exit(&opt, os.args, style)

  todos, err := read_todos()
  if err != TodoError.None {
    fmt.printfln("error reading todos: %v", err)
    os.exit(1)
  }

  #partial switch opt.op {
  case .add:
    add_todo(&todos, opt.input)
  case .complete:
    idx := strconv.atoi(opt.input)
    toggle_todo(&todos, idx)
  case .delete:
    idx := strconv.atoi(opt.input)
    remove_todo(&todos, idx)
  }

  if err := store_todos(&todos); err != nil {
    fmt.printfln("error storing todos: %v", err)
  }
  print_todos(todos)
}
