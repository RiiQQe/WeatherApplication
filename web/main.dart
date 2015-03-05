import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'package:bootjack/bootjack.dart';

//import 'menu.dart';

@Injectable()
class Greeter {
  String name;
}

void main() {
  applicationFactory()
      .rootContextType(Greeter)
      .run();
  
  //dropdown
   Dropdown.use();
  
}
