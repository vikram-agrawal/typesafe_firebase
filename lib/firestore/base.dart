class $Collection<T> {
  final T Function() creator;

  // Accept the constructor as a parameter
  $Collection(this.creator);

  T createInstance() {
    return creator(); // Calls the passed constructor
  }

  T operator [](String id) {
    return createInstance();
  }
}

class $Document<T> {
  Future<bool> exists() async {
    return true;
  }

  Future<T> get data async {
    return {} as T;
  }
}
