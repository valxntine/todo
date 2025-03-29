#+feature dynamic-literals
package tests

import "core:testing"
import "core:log"
import "core:fmt"
import "core:time"
import "../"

@(test)
test_filter :: proc(t: ^testing.T) {
  expected := todo.Todos{
    {
      title = "title1",
      completed = false,
    },
    {
      title = "title3",
      completed = false,
    }
  }

  actual := base_todos()
  defer {
    delete(expected)
    delete(actual)
  }

  filtered := todo.filter_todos(actual, todo.is_incomplete)
  for todo, idx in filtered {
    testing.expect(t, todo == expected[idx])
  }
}

@(test)
test_add_todo :: proc(t: ^testing.T) {
  expected := base_todos()
  actual := todo.Todos{
    {
      title = "title1",
      completed = false,
    },
    {
      title = "title2",
      completed = true,
    },
  }
  defer {
    delete(expected)
    delete(actual)
  }

  err := todo.add_todo(&actual, "title3")
  testing.expectf(t, err == nil, "expected err to be nil, got %v", err)
  testing.expect_value(t, len(actual), 3)
  if ok := testing.expect(t, len(actual) == len(expected)); !ok {
    testing.fail_now(t, fmt.tprintf("expected length of actual: %d to match expected: %d", len(actual), len(expected)))
  }
  
  for todo, idx in actual {
    testing.expect(t, todo.completed == expected[idx].completed)
    testing.expect(t, todo.title == expected[idx].title)
  }
}

@(test)
test_remove_todo :: proc(t: ^testing.T) {
  actual := base_todos()

  defer {
    delete(actual)
  }

  err := todo.remove_todo(&actual, 1)
  testing.expectf(t, err == nil, "expected err to be nil, got %v", err)
  testing.expect_value(t, len(actual), 2)
}

@(test)
test_toggle_todo :: proc(t: ^testing.T) {
  actual := base_todos()

  defer delete(actual)

  err := todo.toggle_todo(&actual, 0)
  testing.expectf(t, err == nil, "expected err to be nil, got %v", err)
  testing.expect_value(t, actual[0].completed, true)
} 

@(test)
test_edit_todo :: proc(t: ^testing.T) {
  actual := base_todos()

  defer delete(actual)

  err := todo.edit_todo(&actual, 0, "new title")
  testing.expectf(t, err == nil, "expected err to be nil, got %v", err)
  testing.expect_value(t, actual[0].title, "new title")
}

@(test)
test_now_string :: proc(t: ^testing.T) {
  now := time.Time{
    _nsec = 1743288161566204000,
  }
  expected := "29-03-2025 22:42:41"
  actual := todo.now_to_string(now)
  testing.expectf(t, actual == expected, "expected: %s got: %s", expected, actual)
}

base_todos :: proc() -> todo.Todos {
  return todo.Todos{
    {
      title = "title1",
      completed = false,
    },
    {
      title = "title2",
      completed = true,
    },
    {
      title = "title3",
      completed = false,
    },
  }

}
