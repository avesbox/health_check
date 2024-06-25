import 'package:serinus/serinus.dart';
import 'package:serinus_health_check/src/health_check_provider.dart';

class HealthCheckController extends Controller {
  
  HealthCheckController({super.path = '/health'}) {
    on(
      Route.get('/'),
      (RequestContext context) async {
        return Response.json(await context.use<HealthCheckProvider>().healthCheck);
      }
    );
  }


}