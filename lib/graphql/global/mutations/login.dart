String login = """
  mutation LOGIN(\$input: LoginInput!) {
    login(input: \$input) {
      id
      firstName
      lastName
      email
      token
      image {
        src
      }
    }
  }
""";
