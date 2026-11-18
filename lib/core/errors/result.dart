import 'failure.dart';

/// Tipo funcional para representar sucesso ([Success]) ou falha ([Err]).
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Err<T>;

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Err<T>(:final failure) => onError(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
