/// Fronteira do módulo de autenticação administrativa.
///
/// Login e guard entram no ticket 10; manter esta unidade independente evita
/// importar a feature de autenticação do aplicativo mobile.
abstract final class AdminAuthFeature {
  static const String name = 'Autenticação administrativa';
}
