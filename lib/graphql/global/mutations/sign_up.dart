String signUp = """
  mutation SIGN_UP(\$input: SignUpInput!) {
    signUp(input: \$input) {
      id
      firstName
      lastName
      email
      token
    }
  }
""";
