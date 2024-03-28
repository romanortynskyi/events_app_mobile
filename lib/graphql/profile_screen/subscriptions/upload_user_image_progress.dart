String uploadUserImageProgress = """
  subscription UPLOAD_USER_IMAGE_PROGRESS(\$userId: Int!) {
    uploadUserImageProgress(userId: \$userId) {
      total
      loaded
      userId
    }
  }
""";
