//login exceptions
class UserNotFoundAuthException implements Exception {}

class WhrongPasswordAuthException implements Exception {}

//register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic exceptions
class GenericAuthException implements Exception {}

class UserNotLogedInAuthException implements Exception {}
