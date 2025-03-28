package main

import "core:encoding/json"
import "core:os"
import "core:fmt"

read_todos :: proc() -> (Todos, Error) {
  t: Todos
  f, err := os.read_entire_file_or_err("todos.json")
  if err != nil {
    switch err {
    case os.Platform_Error.ENOENT:
      return t, TodoError.None
    case:
      return t, err
    }
  }

  if err := json.unmarshal(f, &t); err != nil {
    return t, err
  }

  return t, TodoError.None
}

store_todos :: proc(t: ^Todos) -> Error {
  b := json.marshal(t^) or_return

  os.write_entire_file_or_err("todos.json", b) or_return
  return nil
}
