updates {
  type: INSERT
  entity {
    table_entry {
      table_id: 0 # TODO: provide table Id
      match {
        field_id: 1
        exact {
          value: "\x00 \x00 \x00 \x00 \x00 \x01"
        }
      }
      action {
        action {
          action_id: 0 # TODO: provide action id
          params {
            param_id: 1
            value: "\x00 \x01"
          }
        }
      }
    }
  }
}