class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5182',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: 'pk_test_51SvL7dBlrIi9HZmrpay9Tog3KFDvHRhlqN79lwDSk6eEY28g9AX5Lh9jCo73WpvKoy1uOPishDeoIkj2rFCy20wL00kgziPzD3',
  );
}
