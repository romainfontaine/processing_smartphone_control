public class Agent6 extends Agent {
  // Sensitivities array that will multiply the sliders input
  // (found pretty much as trial an error)
  float [] s = {1, 1, 1, .2, .2, .2};
  
  public Agent6(Scene scn) {
    super(scn.inputHandler());
  }
  
  // Parsing of the Space Navigator input data which is stored in the
  // slider* variables. The MotionEvent6 output generated is sent to
  // the scene input node (either the default node or the one picked
  // by the agent) to interact with.
  //
  // To set a default node call scene.setDefaultNode(Node).
  //
  // Override pollFeed() to implement Space Navigator node picking.
  @Override
  public MotionEvent6 handleFeed() {
    return new MotionEvent6(s[0]*translation.x,
                            s[1]*translation.y,
                            s[2]*translation.z,
                            s[3]*rotation.x,
                            s[4]*rotation.y,
                            -s[5]*rotation.z,
                            frames.input.Event.NO_MODIFIER_MASK, SN_ID);
  }
}