class $Collection<T> {
  final T Function() creator;

  // Accept the constructor as a parameter
  $Collection(this.creator);

  T createInstance() {
    return creator(); // Calls the passed constructor
  }

  T call(String id) {
    return createInstance();
  }
}
