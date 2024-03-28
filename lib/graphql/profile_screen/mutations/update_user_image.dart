String updateUserImage = """
  mutation UPDATE_USER_IMAGE(\$input: UpdateUserImageInput!) {
    updateUserImage(input: \$input) {
      src
    }
  }
""";
