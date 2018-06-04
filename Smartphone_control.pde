import frames.core.Frame;
import frames.processing.Scene;
import frames.processing.Shape;
import processing.core.PApplet;
import processing.core.PShape;
import processing.event.MouseEvent;

// frames stuff:
Scene scene;
Shape[] shapes;
Frame snTrackedFrame;
boolean snPicking = true;
SmartphoneControl sc = new SmartphoneControl(this);

void settings() {
  size(1600, 800, P3D);
}

void setup() {
  sc.printMyIps();
  scene = new Scene(this);
  scene.setFieldOfView(PI / 3);
  //scene.setType(Graph.Type.ORTHOGRAPHIC);
  scene.setRadius(1500);
  scene.fitBallInterpolation();
  // set the eye as the space navigator default frame
  snTrackedFrame = scene.eye();
  // mouseShapes
  shapes = new Shape[50];
  for (int i = 0; i < shapes.length; i++) {
    shapes[i] = new Shape(scene, shape());
    scene.randomize(shapes[i]);
  }
  smooth();
}

PShape shape() {
  PShape fig = createShape(BOX, 150);
  fig.setStroke(color(0, 255, 0));
  fig.setStrokeWeight(3);
  fig.setFill(color(random(0, 255), random(0, 255), random(0, 255)));
  return fig;
}

void draw() {
  sc.serveWebPage();
  background(0);
  scene.drawAxes();
  if (snPicking) {
    spaceNavigatorPicking();
    spaceNavigatorInteraction();
  } else {
    scene.castOnMouseMove();
  }
  sc.clearValues();
}

void spaceNavigatorInteraction() {
  float rotationScale = .1, translationScale = -10;
  if (snTrackedFrame != scene.eye()) {
    rotationScale*=-1;
    translationScale*=-1;
  }
  scene.rotate(sc.getRotation().x * rotationScale, 
    sc.getRotation().y*rotationScale, 
    sc.getRotation().z * rotationScale, snTrackedFrame);
  scene.translate(sc.getTranslation().x * translationScale, 
    sc.getTranslation().y * translationScale, 
    0, snTrackedFrame);
}

void spaceNavigatorPicking() {
  float x = map(sc.getCursor().x, -90, 90, 0, width);
  float y = map(sc.getCursor().y, -90, 90, 0, height);
  // frames' drawing + space navigator picking
  Frame frame = scene.cast(x, y);
  if (sc.getSelection()) {
    snTrackedFrame = frame == null ? scene.eye() : frame;
  }
  // draw picking visual hint
  pushStyle();
  strokeWeight(3);
  stroke(0, 255, 0);
  scene.drawCross(x, y, 30);
  popStyle();
}

void webSocketServerEvent(String msg) {
  sc.webSocketServerEvent(msg);
}
void mouseDragged() {
  if (mouseButton == LEFT)
    scene.mouseSpin();
  else if (mouseButton == RIGHT)
    scene.mouseTranslate();
  else
    scene.scale(mouseX - pmouseX);
}

void mouseWheel(MouseEvent event) {
  scene.zoom(event.getCount() * 20);
}

void keyPressed() {
  if (key == 'r')
    scene.setRightHanded();
  if (key == 'l')
    scene.setLeftHanded();
  // define the tracking device
  if (key == 'i')
    snPicking = !snPicking;
}