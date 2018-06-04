# Assignment Interaction/Shaders - Scene control with a Smartphone, over WiFi

## Members
| Name| Github |
|------------|-------------|
| Romain Fontaine          | [romainfontaine](https://github.com/romainfontaine) 
## Goals
The goal of this assignment is to provide a new way to **interact** with the [framesjs](https://github.com/VisualComputing/framesjs) library. This new way of interaction is based on the sensors available in currents **smartphones**, namely the gyroscope and the accelerometer. The communication is achieved through WiFi.

The user should be able to interact with a **scene**, i.e. rotating and translating the viewpoint as well as the objects that compose the scene. In order to do so, the user must be able to **select** objects.
## Implementation
This project has been implemented using the latest developpement version of [framesjs](https://github.com/VisualComputing/framesjs) (on June 4th 2018). The smartphone side is based on JavaScript and HTML, for a basic user interface, accessing the phone's sensors' outputs, and communicating through [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API).
This simple webpage is served through a TCP Socket thanks to [Processing's Network Library](https://processing.org/reference/libraries/net/index.html).

The client side can be seen as a Finite State Automaton, with the four following states: 
- Disconnected
- Moving Cursor
- Rotating
- Translating

The states are changed according to the connection's status and the user's interactions with the buttons.

The accelerometer's precision on the development device was too poor to provide good results. Therefore, the gyroscope has been used for every type of interaction. It provides the rotation rate in degrees by second by second.

The position of the cursor can be determined by accumulating this acceleration variable into a velocity variable, and by accumulating the velocity variable into the position variable, doing so for every frame.

Framesjs needs relative values for doing translations and rotations. Therefore the rotation rate (in degrees/second/second) is communicated for the rotation in 3 dimensions, and the accumulated rotation speed (in degrees/second) is used for translation, in 2 dimensions.

The communication protocol is only one way with the WebSockets, for simplicity. The client can send four types of messages:
- Select the current object according to the cursor - example message: "s".
- Move the cursor - example message: "c45 -90"
- Perform a rotation - example message: "r5 10 -15"
- Perform a translation - exaple message: "t10 -10"

The selection is performed regarding the cursors coordinates thanks to the framesjs library. It uses another buffer in order uniquely identify the object pointed by the cursor.

In order to make the translations and rotations more intuitive, it is needed to invert the movements (i.e. multiply by -1 every component).

This proof-of-concept is based on Jean Pierre Charalambos' [example for the Space Navigator](https://github.com/VisualComputing/framesjs/blob/geom/testing/src/basics/SpaceNavigator1.java).

## Results
This project has shown that this approach is feasible and that the interaction methods chosen are quite intuitive. Indeed, it is relatively easy and quick to understand how to manipulate objects with this tool.

It is also self-contained, in only one class and can easily be reused, only depending on [framesjs](https://github.com/VisualComputing/framesjs), [WebSockets](https://github.com/alexandrainst/processing_websockets) and [Processings's Net library](https://processing.org/reference/libraries/net/index.html). When reusing this code, it is only needed to instanciate the class, call the methods `serveWebPage()` and `clearValues()` at the beginning and at the end (respectively) of the `draw()` function, and add the following websocket callback: 
```java
void webSocketServerEvent(String msg) {
  sc.webSocketServerEvent(msg);
}
```

## Future Works
- Further investigation on using the accelerometer for moving objects with three degrees of freedom. Potentially with a device that has a more precise sensor which is able to eliminate gravity from the outputs.
- Add a more advanced two-way communication between the client and the server, for confirming a selection change by vibrating, for example.
- Develop a native application (Android and/or iOS) in order to allow more control over the device and to use the physical buttons which may allow more ergonomic interactions than the touchscreen.
- Use the touchscreen for more interaction, which would be very intuitive as well (moving the cursor, 3D rotation & 2D translation of objects). 

## References
- Jankowski, Jacek, and Martin Hachet. "A survey of interaction techniques for interactive 3D environments." Eurographics 2013-STAR. 2013. (available [here](https://hal.inria.fr/hal-00789413/document)).
- [MDN Websocket reference](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [FramesJS](https://github.com/VisualComputing/framesjs)
- [Processing's Net Library](https://processing.org/reference/libraries/net/index.html)
- [Websockets in Processing](https://github.com/alexandrainst/processing_websockets)