// ignore_for_file: avoid_print
import 'dart:io';

import 'package:serinus/serinus.dart';
import 'package:serinus_health_check/serinus_health_check.dart';

class TestMiddleware extends Middleware {
  int counter = 0;

  @override
  Future<void> use(RequestContext context, InternalResponse response,
      NextFunction next) async {
    return next();
  }
}

class Test2Middleware extends Middleware {
  Test2Middleware() : super(routes: ['*']);

  @override
  Future<void> use(RequestContext context, InternalResponse response,
      NextFunction next) async {
    DateTime time = DateTime.now();
    response.on(ResponseEvent.all, (e) async {
      switch (e) {
        case ResponseEvent.beforeSend:
          final newDate = DateTime.now();
          print(
              'Before send event ${newDate.millisecondsSinceEpoch - time.millisecondsSinceEpoch}ms');
          time = newDate;
          break;
        case ResponseEvent.afterSend:
          final newDate = DateTime.now();
          print(
              'After send event ${newDate.millisecondsSinceEpoch - time.millisecondsSinceEpoch}ms');
          time = newDate;
          break;
        default:
          break;
      }
      return;
    });
    return next();
  }
}

class TestProvider extends Provider {
  final List<String> testList = [];

  TestProvider({super.isGlobal});

  String testMethod() {
    testList.add('Hello world');
    return 'Hello world';
  }
}

class TestProviderTwo extends Provider
    with OnApplicationInit, OnApplicationShutdown {
  final TestProvider testProvider;

  TestProviderTwo(this.testProvider);

  String testMethod() {
    testProvider.testMethod();
    return '${testProvider.testList} from provider two';
  }

  @override
  Future<void> onApplicationInit() async {
    print('Provider two initialized');
  }

  @override
  Future<void> onApplicationShutdown() async {
    print('Provider two shutdown');
  }
}

class GetRoute extends Route {
  const GetRoute({
    required super.path,
    super.method = HttpMethod.get,
  });

  @override
  int? get version => 2;
}

class PostRoute extends Route {
  const PostRoute({
    required super.path,
    super.method = HttpMethod.post,
    super.queryParameters = const {
      'hello': String,
    },
  });
}

class HomeController extends Controller {
  HomeController({super.path = '/'}) {
    on(GetRoute(path: '/'), (context) async {
      return Response.text('Hello world');
    },);
  }
}

class AppModule extends Module {
  AppModule()
      : super(imports: [
          WsModule(),
          HealthCheckModule(
            connections: [
              Connection('Google', () async {
                try {
                  await InternetAddress.lookup('testone111.com');
                  return true;
                } catch (e) {
                  return false;
                }
              }),
            ]
          )
        ], controllers: [
          HomeController()
        ], providers: [
          TestProvider(isGlobal: true),
        ], middlewares: [
        ]);
}

void main(List<String> arguments) async {
  SerinusApplication application = await serinus.createApplication(
      entrypoint: AppModule(), host: InternetAddress.anyIPv4.address);
  application.enableShutdownHooks();
  await application.serve();
}
