/// Abstração de relógio para permitir testes determinísticos (SRS e timestamps).
abstract interface class Clock {
  DateTime now();
}

/// Implementação padrão usando o relógio do sistema em UTC.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
