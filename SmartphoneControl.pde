import processing.net.*;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;
import websockets.*;
import java.net.*;
import java.util.Enumeration;

class SmartphoneControl {
  int port;
  Server httpServer;
  WebsocketServer wsServer;

  PVector rotation = new PVector();
  PVector translation = new PVector();
  PVector cursor = new PVector();
  PVector zeroVector = new PVector();

  boolean translationToDo = false, rotationToDo = false, selectionToDo = false;

  public SmartphoneControl(PApplet parent) {
    this(parent, 8000, 8080);
  }
  public SmartphoneControl(PApplet parent, int httpPort, int websocketPort) {
    httpServer = new Server(parent, httpPort);
    wsServer= new WebsocketServer(parent, websocketPort, "/");
  }

  public PVector getTranslation() {
    return translationToDo?translation:zeroVector;
  }  
  public PVector getCursor() {
    return cursor;
  }
  public PVector getRotation() {
    return rotationToDo?rotation:zeroVector;
  }
  public boolean getSelection(){
     boolean prev = this.selectionToDo;
     this.selectionToDo = false;
     return prev;
  }

  public void webSocketServerEvent(String msg) {
    println(msg);
    boolean r = msg.charAt(0)=='r'; 
    boolean c = msg.charAt(0)=='c'; 
    boolean t = msg.charAt(0)=='t'; 
    boolean s = msg.charAt(0)=='s';
    if (s) {
      this.selectionToDo = true;
      return;
    }
    String[] split = msg.substring(1).split(" ");
    float[] a = new float[split.length];
    try {
      for (int i = 0; i<split.length; i++) {
        a[i] = Float.valueOf(split[i]);
      }
    }
    catch(NumberFormatException e) {
      println("Error while parsing '"+msg+"'");
      return;
    }
    if (r) {
      rotation.x = a[0];
      rotation.y = a[1];
      rotation.z = a[2];
      rotationToDo = true;
    } else if (t) {
      translation.x = a[0];
      translation.y = a[1];
      translationToDo = true;
    } else if (c) {
      cursor.x = a[0];
      cursor.y = a[1];
    }
  }

  public void serveWebPage() {
    Client c;
    while ((c = httpServer.available())!=null) {
      String lines[] = loadStrings("index.html");
      String s = String.join("\n", lines);
      c.write(String.format("HTTP/1.1 200 OK\r\nCache-Control : no-cache, private\r\nContent-Length : %d\r\n\r\n%s", s.length(), s));
      c.stop();
    }
  }

  public void clearValues() {
    rotationToDo = false;
    translationToDo = false;
  }

  public void printMyIps() {
    try {
      Enumeration e = NetworkInterface.getNetworkInterfaces();
      while (e.hasMoreElements())
      {
        NetworkInterface n = (NetworkInterface) e.nextElement();
        Enumeration ee = n.getInetAddresses();
        while (ee.hasMoreElements())
          println(((InetAddress) ee.nextElement()).getHostAddress());
      }
    }
    catch(SocketException e) {
    }
  }
}