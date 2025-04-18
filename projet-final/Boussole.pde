class Compass {
  private int targetDirection = 0;
  private int currentDirection = 2;
  private float rotationProgress = 0;
  private boolean isRotating = false;
  private float rotationSpeed = 0.1;
  private PShape compassShape;
  private PGraphics cardinalTexts;
  private float scaleFactor;
  
  public Compass(float scaleFactor) {
    this.scaleFactor = scaleFactor;
    createCardinalTexts();
    compassShape = createCompassShape();
  }
  
  public void drawCompass() {
    pushMatrix();
    camera();
    ortho();
    
    float compassRadius = 200 * scaleFactor;
    float margin = 20;
    translate(compassRadius + margin, height - compassRadius - margin); // Positionnement bas-gauche
    
    rotateX(radians(45));
    
    hint(DISABLE_DEPTH_TEST);
    shape(compassShape);
    image(cardinalTexts, -cardinalTexts.width/2, -cardinalTexts.height/2);
    hint(ENABLE_DEPTH_TEST);
    
    drawAnimatedArrow();
    popMatrix();
    
    updateAnimation();
  }
  
  public void rotateToNextDirection(boolean horaire) {
    targetDirection = (currentDirection + (horaire ? 1 : -1)) % 4;
    isRotating = true;
  }
  
  private void createCardinalTexts() {
    int size = (int)(400 * scaleFactor);
    cardinalTexts = createGraphics(size, size);
    cardinalTexts.beginDraw();
    cardinalTexts.clear();
    cardinalTexts.textSize(28 * scaleFactor);
    cardinalTexts.textAlign(CENTER, CENTER);
    
    String[] points = {"N", "E", "S", "O"};
    for(int i = 0; i < 4; i++) {
      cardinalTexts.pushMatrix();
      cardinalTexts.translate(cardinalTexts.width/2, cardinalTexts.height/2);
      cardinalTexts.rotate(HALF_PI * i);
      cardinalTexts.translate(0, -120 * scaleFactor);
      
      cardinalTexts.fill(255, 200);
      cardinalTexts.noStroke();
      cardinalTexts.ellipse(0, 0, 40 * scaleFactor, 40 * scaleFactor);
      
      if (i == 0) {
        cardinalTexts.fill(232, 63, 37);
      } else {
        cardinalTexts.fill(0);
      }
      
      cardinalTexts.text(points[i], 0, 0);
      cardinalTexts.popMatrix();
    }
    cardinalTexts.endDraw();
  }
  
  private PShape createCompassShape() {
    PShape s = createShape(GROUP);
    
    for(int i = 0; i < 3; i++) {
      float yPos = (15 + i * 10) * scaleFactor;
      float diameter = 410 * scaleFactor;
      PShape layer = createShape(ELLIPSE, 0, yPos, diameter, diameter);
      layer.setFill(#d4b37a);
      layer.setStroke(false);
      s.addChild(layer);
    }
    
    PShape mainCircle = createShape(ELLIPSE, 0, 0, 400 * scaleFactor, 400 * scaleFactor);
    mainCircle.setFill(#f9e1b6);
    mainCircle.setStroke(false);
    s.addChild(mainCircle);
    
    PShape ring = createShape(ELLIPSE, 0, 0, 370 * scaleFactor, 370 * scaleFactor);
    ring.setFill(false);
    ring.setStroke(#dcbf8e);
    ring.setStrokeWeight(30 * scaleFactor);
    s.addChild(ring);
    
    PShape centerCircle = createShape(ELLIPSE, 0, 0, 100 * scaleFactor, 100 * scaleFactor);
    centerCircle.setFill(255);
    centerCircle.setStroke(false);
    s.addChild(centerCircle);
    
    PShape decor = createShape(GROUP);
    
    // Triangles
    for(int i = 0; i < 360; i += 30) {
      PShape tri = createShape();
      tri.beginShape(TRIANGLE);
      tri.fill(#a38b5a);
      tri.noStroke();
      
      if(i % 90 == 0) {
        tri.vertex(-8 * scaleFactor, 0);
        tri.vertex(8 * scaleFactor, 0);
        tri.vertex(0, 15 * scaleFactor);
      } else {
        tri.vertex(-4 * scaleFactor, 0);
        tri.vertex(4 * scaleFactor, 0);
        tri.vertex(0, 10 * scaleFactor);
      }
      tri.endShape();
      
      PShape positionedTri = createShape(GROUP);
      positionedTri.translate(0, -170 * scaleFactor);
      positionedTri.rotateZ(radians(i));
      positionedTri.addChild(tri);
      decor.addChild(positionedTri);
    }
    
    // Lignes
    for(int i = 0; i < 360; i += 10) {
      PShape lineShape = createShape(LINE, 0, -120 * scaleFactor, 0, -140 * scaleFactor);
      lineShape.setStroke(#c0a87c);
      lineShape.setStrokeWeight(1.5 * scaleFactor);
      
      PShape positionedLine = createShape(GROUP);
      positionedLine.rotateZ(radians(i));
      positionedLine.addChild(lineShape);
      decor.addChild(positionedLine);
    }
    
    // texture (sableux)
    PShape dots = createShape(GROUP);
    for(int i = 0; i < 200; i++) {
      float angle = random(TWO_PI);
      float radius = random(140 * scaleFactor, 180 * scaleFactor);
      float x = cos(angle) * radius;
      float y = sin(angle) * radius;
      
      PShape dot = createShape(ELLIPSE, x, y, 2 * scaleFactor, 2 * scaleFactor);
      dot.setFill(#d4b37a);
      dot.setStroke(false);
      dots.addChild(dot);
    }
    decor.addChild(dots);
    s.addChild(decor);
    
    return s;
  }
  
  private void drawAnimatedArrow() {
    pushMatrix();
    translate(0, 0, 1);
    rotateZ(calculateCurrentAngle());
    
    // Flèche
    fill(#FF0000);
    noStroke();
    beginShape();
    vertex(-12 * scaleFactor, -80 * scaleFactor);
    vertex(0, -110 * scaleFactor);
    vertex(12 * scaleFactor, -80 * scaleFactor);
    vertex(0, -65 * scaleFactor);
    endShape(CLOSE);
    
    fill(255, 150);
    noStroke();
    beginShape();
    vertex(-6 * scaleFactor, -80 * scaleFactor);
    vertex(0, -105 * scaleFactor);
    vertex(6 * scaleFactor, -80 * scaleFactor);
    endShape(CLOSE);

    // Contour métallique
    stroke(255);
    strokeWeight(1.5 * scaleFactor);
    noFill();
    beginShape();
    vertex(-12 * scaleFactor, -80 * scaleFactor);
    vertex(0, -110 * scaleFactor);
    vertex(12 * scaleFactor, -80 * scaleFactor);
    endShape(CLOSE);
    popMatrix();
  }
  
  private float calculateCurrentAngle() {
    if (isRotating) {
      float startAngle = currentDirection * HALF_PI;
      float endAngle = targetDirection * HALF_PI;
      
      float diff = endAngle - startAngle;
      if (abs(diff) > PI) {
        endAngle += diff > 0 ? -TWO_PI : TWO_PI;
      }
      
      return lerp(startAngle, endAngle, rotationProgress);
    }
    return currentDirection * HALF_PI;
  }
  
  private void updateAnimation() {
    if (isRotating) {
      rotationProgress = min(rotationProgress + rotationSpeed, 1.0);
      if (rotationProgress == 1.0) {
        currentDirection = targetDirection;
        isRotating = false;
        rotationProgress = 0;
      }
    }
  }
}
