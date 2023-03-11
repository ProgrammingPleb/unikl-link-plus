class InvalidBranchException implements Exception {
  InvalidBranchException(String branch) {
    InvalidBranchException("The \"$branch\" branch does not exist!");
  }
}
