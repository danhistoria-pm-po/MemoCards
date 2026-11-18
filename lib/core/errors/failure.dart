/// Hierarquia de falhas de domínio para evitar vazar exceções de infraestrutura.
sealed class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, {this.cause});

  @override
  String toString() => '$runtimeType($message)';
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause});
}

final class SeedLoadFailure extends Failure {
  const SeedLoadFailure(super.message, {super.cause});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.cause});
}
