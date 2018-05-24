import frames.input.*;
import frames.input.event.*;
import frames.primitives.*;
import frames.core.*;
import frames.processing.*;

import websockets.*;
import java.net.*;
import java.util.Enumeration;
WebsocketServer ws;
PVector rotation = new PVector();
PVector translation = new PVector();

boolean translationToDo = false, rotationToDo = false;

PImage bg;
PImage texmap;

int sDetail = 35;  // Sphere detail setting
float rotationX = 0;
float rotationY = 0;
float velocityX = 0;
float velocityY = 0;
float globeRadius = 400;
float pushBack = 0;

float[] cx, cz, sphereX, sphereY, sphereZ;
float sinLUT[];
float cosLUT[];
float SINCOS_PRECISION = 0.5;
int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);

Scene scene;
// Space navigator gesture id
int SN_ID = 101;
Shape6 eye, rocket;
Agent6 agent6;


import processing.net.*;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;

Server s = new Server(this, 8000);


void printMyIps() {
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

void setup() {

  ws= new WebsocketServer(this, 8080, "/");

  printMyIps();
  size(800, 600, P3D);
  texmap = loadImage("world32k.jpg");    
  initializeSphere(sDetail);
  scene = new Scene(this);
  // add custom user agent:
  agent6 = new Agent6(scene);

  // Do the rest as always...
  // both the eye and the rocket shapes have 6-DOFs

  // 1. the eye
  eye = new Shape6(scene);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.setRadius(260);
  scene.fitBallInterpolation();

  // 2. the rocket shape
  rocket = new Shape6(scene, loadShape("rocket.obj"));
  rocket.translate(new Vector(275, 180, 0));
  rocket.scale(0.3);

  smooth();
}

void webSocketServerEvent(String msg) {
  boolean r = msg.charAt(0)=='r'; 
  String[] split = msg.substring(1).split(" ");
  float[] a = new float[3];
  try {
    for (int i = 0; i<3; i++) {
      a[i] = Float.valueOf(split[i]);
    }
  }
  catch(NumberFormatException e) {
    return;
  }
  if (r) {
    rotation.x = a[0];
    rotation.y = a[1];
    rotation.z = a[2];
    rotationToDo = true;
  } else {
    translation.x = a[0];
    translation.y = a[1];
    translation.z = a[2];
    translationToDo = true;
  }
}

void draw() {
  Client c;
  while ((c = s.available())!=null) {
    String lines[] = loadStrings("index.html");
    String s = String.join("\n", lines);
    c.write(String.format("HTTP/1.1 200 OK\r\nCache-Control : no-cache, private\r\nContent-Length : %d\r\n\r\n%s", s.length(), s));
    c.stop();
  }  

  background(0);    
  renderGlobe();
  scene.traverse();
  if (rotationToDo) {
    rotationToDo = false;
    rotation = new PVector();
  }
  if (translationToDo) {
    translationToDo = false;
    translation = new PVector();
  }
}

void keyPressed() {
  if (key == 'y')
    scene.flip();
  // shift the agents' (mouse and agent6) default node
  if ( key == 'i')
    scene.shiftDefaultGrabber(eye, rocket);
}

void renderGlobe() {
  fill(200);
  noStroke();
  textureMode(IMAGE);  
  texturedSphere(globeRadius, texmap);
}

void initializeSphere(int res) {
  sinLUT = new float[SINCOS_LENGTH];
  cosLUT = new float[SINCOS_LENGTH];

  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
  }

  float delta = (float)SINCOS_LENGTH/res;
  float[] cx = new float[res];
  float[] cz = new float[res];

  // Calc unit circle in XZ plane
  for (int i = 0; i < res; i++) {
    cx[i] = -cosLUT[(int) (i*delta) % SINCOS_LENGTH];
    cz[i] = sinLUT[(int) (i*delta) % SINCOS_LENGTH];
  }

  // Computing vertexlist vertexlist starts at south pole
  int vertCount = res * (res-1) + 2;
  int currVert = 0;

  // Re-init arrays to store vertices
  sphereX = new float[vertCount];
  sphereY = new float[vertCount];
  sphereZ = new float[vertCount];
  float angle_step = (SINCOS_LENGTH*0.5f)/res;
  float angle = angle_step;

  // Step along Y axis
  for (int i = 1; i < res; i++) {
    float curradius = sinLUT[(int) angle % SINCOS_LENGTH];
    float currY = -cosLUT[(int) angle % SINCOS_LENGTH];
    for (int j = 0; j < res; j++) {
      sphereX[currVert] = cx[j] * curradius;
      sphereY[currVert] = currY;
      sphereZ[currVert++] = cz[j] * curradius;
    }
    angle += angle_step;
  }
  sDetail = res;
}

// Generic routine to draw textured sphere
void texturedSphere(float r, PImage t) {
  int v1, v11, v2;
  r = (r + 240 ) * 0.33;
  beginShape(TRIANGLE_STRIP);
  texture(t);
  float iu=(float)(t.width-1)/(sDetail);
  float iv=(float)(t.height-1)/(sDetail);
  float u=0, v=iv;
  for (int i = 0; i < sDetail; i++) {
    vertex(0, -r, 0, u, 0);
    vertex(sphereX[i]*r, sphereY[i]*r, sphereZ[i]*r, u, v);
    u+=iu;
  }
  vertex(0, -r, 0, u, 0);
  vertex(sphereX[0]*r, sphereY[0]*r, sphereZ[0]*r, u, v);
  endShape();   

  // Middle rings
  int voff = 0;
  for (int i = 2; i < sDetail; i++) {
    v1=v11=voff;
    voff += sDetail;
    v2=voff;
    u=0;
    beginShape(TRIANGLE_STRIP);
    texture(t);
    for (int j = 0; j < sDetail; j++) {
      vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1++]*r, u, v);
      vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2++]*r, u, v+iv);
      u+=iu;
    }

    // Close each ring
    v1=v11;
    v2=voff;
    vertex(sphereX[v1]*r, sphereY[v1]*r, sphereZ[v1]*r, u, v);
    vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v+iv);
    endShape();
    v+=iv;
  }
  u=0;

  // Add the northern cap
  beginShape(TRIANGLE_STRIP);
  texture(t);
  for (int i = 0; i < sDetail; i++) {
    v2 = voff + i;
    vertex(sphereX[v2]*r, sphereY[v2]*r, sphereZ[v2]*r, u, v);
    vertex(0, r, 0, u, v+iv);    
    u+=iu;
  }
  vertex(sphereX[voff]*r, sphereY[voff]*r, sphereZ[voff]*r, u, v);
  endShape();
}