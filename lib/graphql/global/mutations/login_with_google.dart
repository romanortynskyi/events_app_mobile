String loginWithGoogle = """
  mutation LOGIN_WITH_GOOGLE(\$idToken: String!) {
    loginWithGoogle(idToken: \$idToken) {
      id
      firstName
      lastName
      email
      token
    }
  }
""";
