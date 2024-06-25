import 'package:serinus/serinus.dart';

import 'health_check_controller.dart';
import 'health_check_provider.dart';

/// This module is a representation of the entrypoint of your plugin.
/// It is the main class that will be used to register your plugin with the application.
/// 
/// This module should extend the [Module] class and override the [registerAsync] method.
/// 
/// You can also use the constructor to initialize any dependencies that your plugin may have.
class HealthCheckModule extends Module {
  
  final String path;
  final List<Connection> connections;

  HealthCheckModule({
    this.path = '/health',
    this.connections = const [],
  }) : super(
    providers: [
      HealthCheckProvider(connections: connections),
    ]
  );

  @override
  Future<Module> registerAsync(ApplicationConfig config) async {

    controllers = [HealthCheckController(path: path)];

    return this;
  }

}