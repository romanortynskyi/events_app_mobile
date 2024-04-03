String loginWithFacebook = """
  mutation LOGIN_WITH_FACEBOOK(\$accessToken: String!) {
    loginWithFacebook(accessToken: \$accessToken) {
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
