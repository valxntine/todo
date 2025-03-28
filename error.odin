package main

import "core:os"
import "base:runtime"
import "core:encoding/json"

Error :: union {
  TodoError,
  os.Error,
  runtime.Allocator_Error,
  json.Marshal_Error,
  json.Unmarshal_Error,
}
