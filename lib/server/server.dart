
import 'dart:io';


final String HOST = "127.0.0.1";
final int PORT = 8085;

void main(){
  print("HEJSAN");
  HttpServer.bind(HOST, PORT).then((HttpServer server){
    print(server);
    server.listen((HttpRequest request){
        print("tjenare");
        request.response.headers.set("Access-Control-Allow-Origin", "*");
        request.response.write('Hello2World');
        request.response.close();
    });
  });
  
}