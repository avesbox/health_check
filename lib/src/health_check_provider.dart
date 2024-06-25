import 'dart:io' as io;

import 'package:serinus/serinus.dart';
import 'package:yaml/yaml.dart';

class HealthCheckProvider extends Provider{

  final List<Connection> connections;

  HealthCheckProvider(
    {this.connections = const []}
  ) : _healthCheck = _HealthCheck(connections);

  final _HealthCheck _healthCheck;

  Future<Map<String, dynamic>> get healthCheck async {
    return await _healthCheck.toJson();
  }

}

class Connection {

  final String name;
  final Future<bool> Function() check;

  Connection(this.name, this.check);

}

class _HealthCheck {

  _HealthCheck(this.connections);

  final List<Connection> connections;

  final DateTime startDate = DateTime.now();
  int get uptime => startDate.millisecondsSinceEpoch ~/ 1000;
  String get upSince => startDate.toIso8601String();
  _HealthCheckService service = _HealthCheckService();
  int get pid => io.pid;

  Future<Map<String, dynamic>> toJson() async {
    String status = 'fail!';
    Map<String, String> results = {};

    for (var connection in connections) {
      if (!await connection.check()) {
        results[connection.name] = 'fail!';
      } else {
        results[connection.name] = 'ok!';
      }
    }

    if (results.values.every((element) => element == 'ok!')) {
      status = 'ok!';
    }else{
      status = 'fail! - ${results.entries.where((element) => element.value == 'fail!').map((e) => e.key)} connections failed!';
    }

    return {
      'status': status,
      'uptime': DateTime.now().millisecondsSinceEpoch ~/ 1000 - uptime,
      'upSince': upSince,
      'service': {
        'name': service.name,
        'description': service.description,
        'version': service.version,
      },
      'connections': results,
      'pid': pid,
    };
  }

}


class _HealthCheckService {

  String? name;
  String? description;
  String? version;

  _HealthCheckService() {
    io.File pubspec = io.File(io.Directory.current.path + '/pubspec.yaml');
    final content = pubspec.readAsStringSync();
    final yaml = loadYaml(content);
    name = yaml['name'];
    description = yaml['description'];
    version = yaml['version'];
  }

}