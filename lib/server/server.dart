
import 'dart:io';
import 'dart:html' hide HttpRequest;

void main(){
  
  window.alert("I a min!");
  HttpServer.bind('0.0.0.0', 80).then((HttpServer server){
    print(server);
    server.listen((HttpRequest request){
        window.alert("Server started!!!");
        request.response.write('Hello World');
        request.response.close();
    });
  });
  
}