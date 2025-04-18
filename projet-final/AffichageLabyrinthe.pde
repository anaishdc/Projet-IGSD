class AffichageLabyrinthe {
  private final Labyrinthe labyrinthe;
  int WALLD = 1; // Niveau de détail des murs
  
  PShape labyShape;        // Forme groupe pour tous les murs
  PShape floorShape;       // Forme pour le sol
  PShape ceilingShape;     // Forme pour les plafonds
  PShape wallCeilingShape; // Forme pour les plafonds des murs
  PImage texture;          // Texture des murs
  PImage textureSol;       // Texture du sol
  
  
  //  Map pour stocker les shapes individuelles des murs
  // associe a chaque forme pshape representant un mur une cle string 
  private HashMap<String, PShape> wallShapesMap;

  public AffichageLabyrinthe(PImage texture, Labyrinthe labyrinthe, PImage textureSol) {
    this.texture = texture;
    this.labyrinthe = labyrinthe;
    this.textureSol = textureSol;
    this.wallShapesMap = new HashMap<String, PShape>();
    createShapes();
  }

  private void createShapes() {
    float wallW = width/labyrinthe.getSize();
    float wallH = height/labyrinthe.getSize();

    labyShape = createShape(GROUP);
    floorShape = createShape();
    ceilingShape = createShape();
    wallCeilingShape = createShape();

    // Configuration des shapes
    floorShape.beginShape(QUADS);
    floorShape.texture(textureSol);
    floorShape.noStroke();
    floorShape.textureMode(NORMAL);

    ceilingShape.beginShape(QUADS);
    ceilingShape.noStroke();
    ceilingShape.fill(32);

    wallCeilingShape.beginShape(QUADS);
    wallCeilingShape.noStroke();
    wallCeilingShape.fill(32, 255, 0);

    // Parcours de la grille
    for (int j = 0; j < labyrinthe.getSize(); j++) {
      for (int i = 0; i < labyrinthe.getSize(); i++) {
        if (labyrinthe.getLabyrinthe()[j][i] == '#') {
          // Création de la shape pour ce mur spécifique
          PShape wall = createWallShape(i, j, wallW, wallH);
          
          // Stockage dans la map avec une clé unique
          String key = i + "," + j;
          wallShapesMap.put(key, wall);
          
          labyShape.addChild(wall);

          // Plafond pour ce mur
          wallCeilingShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50);
          wallCeilingShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50);
          wallCeilingShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50);
          wallCeilingShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50);
        } else {
          // Sol pour les cases vides
          float tileSize = 0.2f;
          floorShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 
                          i*tileSize, j*tileSize);
          floorShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 
                          (i+1)*tileSize, j*tileSize);
          floorShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 
                          (i+1)*tileSize, (j+1)*tileSize);
          floorShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 
                          i*tileSize, (j+1)*tileSize);

          // Plafond pour les cases vides
          ceilingShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50);
          ceilingShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50);
          ceilingShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50);
          ceilingShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50);
        }
      }
    }

    floorShape.endShape();
    ceilingShape.endShape();
    wallCeilingShape.endShape();
  }

  
    private PShape createWallShape(int i, int j, float wallW, float wallH) {
    PShape wall = createShape();
    wall.beginShape(QUADS);
    wall.texture(texture);
    wall.noStroke();
    
    // Couleur basée sur la position
    float r = map(j, 0, labyrinthe.getSize()-1, 0, 255);
    float g = map(i, 0, labyrinthe.getSize()-1, 0, 255);
    float b = abs(255 - r - g);
    wall.fill(color(r, g, b));
    wall.tint(color(r, g, b)); 
    
    
    wall.fill(128); 
    
    // Création des faces
    if (j == 0 || labyrinthe.getLabyrinthe()[j-1][i] == ' ') {
      createWallFace(wall, i, j, wallW, wallH, 0); // Face nord
    }
    if (j == labyrinthe.getSize()-1 || labyrinthe.getLabyrinthe()[j+1][i] == ' ') {
      createWallFace(wall, i, j, wallW, wallH, 1); // Face sud
    }
    if (i == 0 || labyrinthe.getLabyrinthe()[j][i-1] == ' ') {
      createWallFace(wall, i, j, wallW, wallH, 2); // Face ouest
    }
    if (i == labyrinthe.getSize()-1 || labyrinthe.getLabyrinthe()[j][i+1] == ' ') {
      createWallFace(wall, i, j, wallW, wallH, 3); // Face est
    }

    wall.endShape();
    return wall;
  }

private void createWallFace(PShape shape, int i, int j, float wallW, float wallH, int face) {
    for (int k = 0; k < WALLD; k++) {
      for (int l = -WALLD; l < WALLD; l++) {
        float bottomZ = (l+0)*50/WALLD;
        float topZ = (l+1)*50/WALLD;
        float sectionWidth = wallW/WALLD;
        float sectionHeight = wallH/WALLD;
        
        float u1 = k/(float)WALLD;
        float u2 = (k+1)/(float)WALLD;
        float v1 = (0.5+l/2.0/WALLD);
        float v2 = (0.5+(l+1)/2.0/WALLD);

        switch(face) {
          case 0: // Nord
            shape.vertex(i*wallW-wallW/2 + k*sectionWidth, j*wallH-wallH/2, bottomZ, u1*texture.width, v1*texture.height);
            shape.vertex(i*wallW-wallW/2 + (k+1)*sectionWidth, j*wallH-wallH/2, bottomZ, u2*texture.width, v1*texture.height);
            shape.vertex(i*wallW-wallW/2 + (k+1)*sectionWidth, j*wallH-wallH/2, topZ, u2*texture.width, v2*texture.height);
            shape.vertex(i*wallW-wallW/2 + k*sectionWidth, j*wallH-wallH/2, topZ, u1*texture.width, v2*texture.height);
            break;
            
          case 1: // Sud
            shape.vertex(i*wallW-wallW/2 + k*sectionWidth, j*wallH+wallH/2, topZ, u1*texture.width, v2*texture.height);
            shape.vertex(i*wallW-wallW/2 + (k+1)*sectionWidth, j*wallH+wallH/2, topZ, u2*texture.width, v2*texture.height);
            shape.vertex(i*wallW-wallW/2 + (k+1)*sectionWidth, j*wallH+wallH/2, bottomZ, u2*texture.width, v1*texture.height);
            shape.vertex(i*wallW-wallW/2 + k*sectionWidth, j*wallH+wallH/2, bottomZ, u1*texture.width, v1*texture.height);
            break;
            
          case 2: // Ouest
            shape.vertex(i*wallW-wallW/2, j*wallH-wallH/2 + k*sectionHeight, topZ, u1*texture.width, v2*texture.height);
            shape.vertex(i*wallW-wallW/2, j*wallH-wallH/2 + (k+1)*sectionHeight, topZ, u2*texture.width, v2*texture.height);
            shape.vertex(i*wallW-wallW/2, j*wallH-wallH/2 + (k+1)*sectionHeight, bottomZ, u2*texture.width, v1*texture.height);
            shape.vertex(i*wallW-wallW/2, j*wallH-wallH/2 + k*sectionHeight, bottomZ, u1*texture.width, v1*texture.height);
            break;
            
          case 3: // Est
            shape.vertex(i*wallW+wallW/2, j*wallH-wallH/2 + k*sectionHeight, bottomZ, u1*texture.width, v1*texture.height);
            shape.vertex(i*wallW+wallW/2, j*wallH-wallH/2 + (k+1)*sectionHeight, bottomZ, u2*texture.width, v1*texture.height);
            shape.vertex(i*wallW+wallW/2, j*wallH-wallH/2 + (k+1)*sectionHeight, topZ, u2*texture.width, v2*texture.height);
            shape.vertex(i*wallW+wallW/2, j*wallH-wallH/2 + k*sectionHeight, topZ, u1*texture.width, v2*texture.height);
            break;
        }
      }
    }
  }

 

 //  pour obtenir une shape de mur spécifique
  public PShape getWallShape(int x, int y) {
    String key = x + "," + y;
    return wallShapesMap.get(key);
  }

 //  méthode pour mettre à jour la couleur d'un mur
public void setWallColor(int x, int y, color c) {
    String key = x + "," + y;
    PShape wall = wallShapesMap.get(key);
    if (wall != null) {
        wall.setFill(c);
        wall.setTint(c);  // la couleur soit visible malgré la texture
    }
}

  public void display(boolean inLab) {
    shape(floorShape, 0, 0);
    shape(labyShape, 0, 0);
    
    if (inLab) {
      shape(ceilingShape, 0, 0);
    } else {
      shape(wallCeilingShape, 0, 0);
    }
  }
  
  
  // calcul de la couleur en fonction de la position du mur 
  public void applyColorToWalls() {
    for (int j = 0; j < labyrinthe.getSize(); j++) {
        for (int i = 0; i < labyrinthe.getSize(); i++) {
            if (labyrinthe.getLabyrinthe()[j][i] == '#') {
                // Calcul des composantes RGB basées sur la position
                float r = map(j, 0, labyrinthe.getSize()-1, 0, 255);
                float g = map(i, 0, labyrinthe.getSize()-1, 0, 255);
                float b = abs(255 - r - g);
                color wallColor = color(r, g, b);
                
                // Appliquer la couleur
                setWallColor(i, j, wallColor);
            }
        }
    }
}

}

  
