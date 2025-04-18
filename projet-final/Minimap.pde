public class Minimap {
  
  private static final int VIEW_DISTANCE = 3;  // Rayon de visibilité autour du joueur
  
  private Labyrinthe labyrinthe;
  private int boxSize;
  private boolean[][] discovered;
  private PShader shader;
  
  // Position du joueur
  private int playerX;
  private int playerY;
  
  // Direction du joueur (pour l'orientation de la flèche)
  private int dirX;
  private int dirY;
  
  // Liste des momies à afficher
  private ArrayList<Momie> momies;
  
  public Minimap(Labyrinthe labyrinthe, ArrayList<Momie> momies) {
    this.labyrinthe = labyrinthe;
    this.shader = loadShader("assets/shaders/LabyColor.glsl", "assets/shaders/LabyTexture.glsl");
    this.boxSize = (width / labyrinthe.getSize()) - 5;
    
    // Initialisation de la matrice des zones découvertes
    this.discovered = new boolean[labyrinthe.getSize()][labyrinthe.getSize()];
    
    // Position initiale du joueur
    this.playerX = 1;
    this.playerY = 0;
    
    this.dirX = 0;
    this.dirY = 1;
    
    this.momies = momies;
    
    // Marquer la zone initiale comme découverte
    updateDiscoveredArea();
  }
  
  public void drawMinimap() {
    pushMatrix();
  
    // Passer en mode HUD : réinitialiser la caméra et la perspective
    camera();
    ortho();
  
    int offsetX = 20; 
    int offsetY = 20;
  
    pushMatrix();
    setupLighting();
    shader(shader);
  
    pushMatrix();
    translate(offsetX, offsetY);  // Positionner la minimap dans le coin
    scale(0.2);
  
    // Dessiner le labyrinthe et le joueur
    drawLabyrinth();
    drawPlayer();
    
    // Dessiner les momies
    drawMomies();
  
    popMatrix();
    resetShader();
    popMatrix();
  
    popMatrix();
  }
  
  /**
   * Définit la liste des momies à afficher sur la minimap
   */
  public void setMomies(ArrayList<Momie> momies) {
    this.momies = momies;
  }
  
  /**
   * Dessine toutes les momies sur la minimap
   */
  private void drawMomies() {
    if (momies == null || momies.isEmpty()) {
      return;
    }
    
    for (Momie momie : momies) {
      // Obtenir les coordonnées de la momie
      float momieX = momie.getX();
      float momieY = momie.getY();
      
      // Vérifier si la position de la momie est découverte
      int gridX = (int)momieX;
      int gridY = (int)momieY;
      
      if (gridX >= 0 && gridX < labyrinthe.getSize() && 
          gridY >= 0 && gridY < labyrinthe.getSize() &&
          discovered[gridY][gridX]) {
        
        // Direction de la momie pour l'orientation
        float momieRotation = momie.getCurrentRotation();
        
        // Dessiner la momie
        drawMomie(momieX, momieY, momieRotation);
      }
    }
  }
  
  /**
   * Dessine une momie à la position spécifiée
   */
  private void drawMomie(float x, float y, float rotation) {
    pushMatrix();
    
    // Positionner au centre de la case de la momie
    translate(x * boxSize + boxSize / 2,
              y * boxSize + boxSize / 2,
              boxSize / 2);
    
    // Appliquer la rotation de la momie
    rotate(rotation);
    
    // Couleur jaune pour la momie
    stroke(255, 255, 0);  // Contour jaune
    strokeWeight(3);      // Épaisseur du contour
    fill(255, 255, 0, 200); // Jaune semi-transparent
    
    // Dessiner la momie comme un petit triangle orienté
    float momieSize = boxSize / 4;
    
    beginShape();
    vertex(0, -momieSize); // Pointe avant
    vertex(-momieSize, momieSize); // Coin arrière gauche
    vertex(momieSize, momieSize); // Coin arrière droit
    endShape(CLOSE);
    
    // Bandages - lignes horizontales pour symboliser une momie
    stroke(255, 255, 150);
    strokeWeight(1);
    line(-momieSize/2, -momieSize/2, momieSize/2, -momieSize/2);
    line(-momieSize/2, 0, momieSize/2, 0);
    line(-momieSize/2, momieSize/2, momieSize/2, momieSize/2);
    
    popMatrix();
  }
  
  private void setupLighting() {
    ambientLight(60, 60, 60);
    directionalLight(200, 200, 200, 0, 0, -1);
    pointLight(150, 150, 150, 
               playerX * boxSize + boxSize/2, 
               playerY * boxSize + boxSize/2, 
               boxSize * 2);
  }
  
  /**
   * Dessine l'ensemble du labyrinthe (murs et sols)
   */
  private void drawLabyrinth() {
    // Couleurs des coins pour le dégradé
    color topLeft = color(33, 28, 132);     // Bleu
    color topRight = color(232, 63, 37);    // Rouge
    color bottomLeft = color(96, 181, 255); // Cyan
    color bottomRight = color(248, 237, 140); // Jaune
    
    // Parcourir chaque case du labyrinthe
    for (int j = 0; j < labyrinthe.getSize(); j++) {
      for (int i = 0; i < labyrinthe.getSize(); i++) {
        pushMatrix();
        translate(j * boxSize, i * boxSize, 0);
        
        // Ne dessiner que les cases découvertes
        if (discovered[i][j]) {
          if (labyrinthe.getLabyrinthe()[i][j] == '#') {
            // Case mur - Appliquer un dégradé de couleur
            color wallColor = calculateGradientColor(i, j, topLeft, topRight, bottomLeft, bottomRight);
            fill(wallColor);
            noStroke();
            drawCube();
          } else {
            // Case sol
            fill(58, 58, 58);
            drawFloor();
          }
        } else {
          // Case non découverte - semi-transparente
          fill(10, 10, 10, 20);
          drawFloor();
        }
        
        popMatrix();
      }
    }
  }
  
  /**
   * Calcule la couleur d'un mur selon sa position (dégradé)
   */
  private color calculateGradientColor(int i, int j, color topLeft, color topRight, 
                                      color bottomLeft, color bottomRight) {
    float horizAmount = (float) j / (labyrinthe.getSize() - 1);
    float vertAmount = (float) i / (labyrinthe.getSize() - 1);
    
    color topColor = lerpColor(topLeft, topRight, horizAmount);
    color bottomColor = lerpColor(bottomLeft, bottomRight, horizAmount);
    return lerpColor(topColor, bottomColor, vertAmount);
  }
  
  private void drawCube() {
    beginShape(QUADS);
    
    // Face avant
    vertex(0, 0, boxSize);
    vertex(boxSize, 0, boxSize);
    vertex(boxSize, boxSize, boxSize);
    vertex(0, boxSize, boxSize);
    
    // Face arrière
    vertex(0, 0, 0);
    vertex(boxSize, 0, 0);
    vertex(boxSize, boxSize, 0);
    vertex(0, boxSize, 0);
    
    // Face gauche
    vertex(0, 0, 0);
    vertex(0, 0, boxSize);
    vertex(0, boxSize, boxSize);
    vertex(0, boxSize, 0);
    
    // Face droite
    vertex(boxSize, 0, 0);
    vertex(boxSize, 0, boxSize);
    vertex(boxSize, boxSize, boxSize);
    vertex(boxSize, boxSize, 0);
    
    // Face inférieure
    vertex(0, 0, 0);
    vertex(boxSize, 0, 0);
    vertex(boxSize, 0, boxSize);
    vertex(0, 0, boxSize);
    
    // Face supérieure
    vertex(0, boxSize, 0);
    vertex(boxSize, boxSize, 0);
    vertex(boxSize, boxSize, boxSize);
    vertex(0, boxSize, boxSize);
    
    endShape();
  }
  
  private void drawFloor() {
    beginShape(QUADS);
    vertex(0, 0, 0);
    vertex(boxSize, 0, 0);
    vertex(boxSize, boxSize, 0);
    vertex(0, boxSize, 0);
    endShape();
  }

  private void drawPlayer() {
    pushMatrix();

    // Positionner au centre de la case du joueur
    translate(playerX * boxSize + boxSize / 2,
              playerY * boxSize + boxSize / 2,
              boxSize / 2);

    // Déterminer l'angle de rotation en fonction de la direction
    float angle = 0; // Par défaut vers le haut
    
    if (dirX == 1 && dirY == 0) {
        angle = HALF_PI; // vers la droite
    } else if (dirX == -1 && dirY == 0) {
        angle = -HALF_PI; // vers la gauche
    } else if (dirX == 0 && dirY == 1) {
        angle = PI; // vers le bas
    } else if (dirX == 0 && dirY == -1) {
        angle = 0; // vers le haut
    }

    rotate(angle);

    // Effet de pulsation pour la flèche
    float pulseSize = boxSize / 3 + sin(frameCount * 0.1) * boxSize / 20;

    // Dessiner la flèche
    stroke(64, 224, 208);  // Couleur turquoise
    strokeWeight(4);  // Épaisseur de la flèche
    fill(64, 224, 208, 200);  // Remplissage semi-transparent

    // Dessiner la pointe de la flèche
    beginShape();
    vertex(0, -pulseSize / 2); // Pointe de la flèche
    vertex(-boxSize / 6, pulseSize / 2); // Côté gauche
    vertex(boxSize / 6, pulseSize / 2); // Côté droit
    endShape(CLOSE);

    // Dessiner la tige de la flèche
    rect(-boxSize/16, pulseSize / 2, boxSize / 8, pulseSize);

    // Dessiner les plumes de la flèche
    line(-boxSize / 10, pulseSize, 0, pulseSize + boxSize / 8);
    line(boxSize / 10, pulseSize, 0, pulseSize + boxSize / 8);

    popMatrix();
  }
  
  public void updateDiscoveredArea() {
    // Parcourir la zone autour du joueur selon la distance visible
    for (int y = max(0, playerY - VIEW_DISTANCE); 
         y <= min(labyrinthe.getSize() - 1, playerY + VIEW_DISTANCE); 
         y++) {

      for (int x = max(0, playerX - VIEW_DISTANCE); 
           x <= min(labyrinthe.getSize() - 1, playerX + VIEW_DISTANCE); 
           x++) {
           
        // Calcul de la distance de Manhattan
        int distance = abs(x - playerX) + abs(y - playerY);
        
        // Marquer comme découvert si dans le rayon visible
        if (distance <= VIEW_DISTANCE) {
          discovered[y][x] = true;
        }
      }
    }
  }
  
  public void updatePlayerPosition(int positionX, int positionY, int directionX, int directionY) {
      boolean update = false;
      
      if (this.playerX != positionX) {
          this.playerX = positionX;
          update = true;
      }
      
      if (this.playerY != positionY) {
          this.playerY = positionY;
          update = true;
      }
      
      // Mise à jour de la direction du joueur
      this.dirX = directionX;
      this.dirY = directionY;
      
      if (update) {
          updateDiscoveredArea();
      }
  }
}
