package main

import "core:fmt"
import "core:text/table"
import "core:time"
import "core:time/datetime"

Todo :: struct {
  title: string `json:"title"`,
  completed: bool `json:"completed,omitempty"`,
  created_at: string `json:"created_at,omitempty"`,
  completed_at: string `json:"completed_at,omitempty"`,
}

Todos :: [dynamic]Todo

TodoError :: enum {
  None,
  Invalid_Index,
}

handle_cmd :: proc(opt: Options) -> Error {
  todos, err := read_todos()
  if err != TodoError.None {
    return err
  }
  fmt.println(opt.op)

  switch opt.op {
  case .add:
    add_todo(&todos, opt.input.(string))
    print_incomplete_todos(todos)
  case .complete:
    toggle_todo(&todos, opt.input.(int))
    print_incomplete_todos(todos)
  case .delete:
    remove_todo(&todos, opt.input.(int))
    print_incomplete_todos(todos)
  case .list, .all:
    print_todos(todos)
  case .default:
    print_incomplete_todos(todos)
  }

  if err := store_todos(&todos); err != nil {
    fmt.printfln("error storing todos: %v", err)
  }

  return TodoError.None

}

add_todo :: proc(t: ^Todos, title: string) -> Error {
  todo: Todo = Todo{
    title = title,
    created_at = now_to_string(time.now()),
  } 
  if _, err := append(t, todo); err != nil {
    return err
  }
  return nil
}

remove_todo :: proc(t: ^Todos, index: int) -> Error {
  validate_index(t, index) or_return

  unordered_remove(t, index)
  return nil
}

toggle_todo :: proc(t: ^Todos, index: int) -> Error {
  validate_index(t, index) or_return

  is_completed := t[index].completed

  if !is_completed {
    t[index].completed_at = now_to_string(time.now())
  }

  t[index].completed = !is_completed

  return nil
}

edit_todo :: proc(t: ^Todos, index: int, title: string) -> Error {
  validate_index(t, index) or_return

  t[index].title = title
  return nil
}

validate_index :: proc(t: ^Todos, index: int) -> Error {
  if index < 0 && index >= len(t) {
    return TodoError.Invalid_Index
  }
  return nil
}

now_to_string :: proc(t: time.Time) -> string {
  hms_buf: [time.MIN_HMS_LEN]u8
  date_buf: [time.MIN_YYYY_DATE_LEN]u8
  return fmt.tprintf("%s %s", time.to_string_dd_mm_yyyy(t, date_buf[:]), time.to_string_hms(t, hms_buf[:]))
}

print_todos :: proc(t: Todos) {
  tbl: table.Table
  table.init(&tbl)
  table.caption(&tbl, "Valentine's Todos")
  table.padding(&tbl, 1, 3)
  table.header(&tbl, "ID", "Title", "Completed", "Created At", "Completed At")
  for td, idx in t {
    complete := "\u274C"
    
    if td.completed {
      complete = "\u2705"
    }
    
    table.row(&tbl, idx, td.title, complete, td.created_at, td.completed_at)
  }
  stdout := table.stdio_writer()

  table.write_plain_table(stdout, &tbl)
}

print_incomplete_todos :: proc(t: Todos) {
  ft := filter_todos(t, is_incomplete)
  print_todos(ft)
  delete(ft)
}

filter_todos :: proc(t: Todos, filter: proc(Todo) -> bool) -> Todos {
  ft := make(Todos)
  for v in t {
    if filter(v) {
      append(&ft, v)
    }
  }
  return ft
}

is_incomplete :: proc(t: Todo) -> bool {
  return !t.completed
}

