String addEvent = """
  mutation ADD_EVENT(\$input: EventInput!) {
    addEvent(input: \$input) {
      id
    }
  }
""";
