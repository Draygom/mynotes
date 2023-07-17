class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNote extends CloudStorageException {}

class CouldNotGetAllNotes extends CloudStorageException {}

class CouldNotGetUpdateNote extends CloudStorageException {}

class CouldNotDeleteNote extends CloudStorageException {}
