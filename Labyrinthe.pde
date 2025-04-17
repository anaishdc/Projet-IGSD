class Labyrinthe {
  
  private final char[][] labyrinthe;
  private final char[][][] cotes;
  private final int size;
  
  private final AffichageLabyrinthe affichageLabyrinthe;
  
  public Labyrinthe(int size, PImage texture, PImage textureSol) {
    this.labyrinthe = new char[size][size];
    this.cotes = new char[size][size][4];
    this.size = size;
    
    new GenerateurLabyrinthe().genererLabyrinthe(labyrinthe, cotes);
    
    this.affichageLabyrinthe = new AffichageLabyrinthe(texture, this,textureSol);
  }
  
  public boolean isWall(int x, int y) {
    if (x < 0 || x >= size || y < 0 || y >= size) {
      return true;
    }
    return labyrinthe[y][x] == '#';
  }
  

  
  public char[][] getLabyrinthe() {
    return labyrinthe;
  }

   public char[][][] getCotes() {
    return cotes;
  }
  
  public int getSize() {
    return size;
  }
  
  public AffichageLabyrinthe getAffichage() {
    return affichageLabyrinthe;
  }
  

  public PVector getEmptyCell(int currX, int currY) {
    int x, y;
    int attempts = 0;
    int maxAttempts = 100; // Éviter une boucle infinie
    
    do {
        x = int(random(getSize()));
        y = int(random(getSize()));
        attempts++;
        
        // Si on atteint le nombre maximum de tentatives, on utilise une case libre à proximité
        if (attempts >= maxAttempts) {
            return getNearbyEmptyCell(int(x), int(y));
        }
    } while (lab.isWall(x, y) || (x == int(currX) && y == int(currY)));
    
    return new PVector(x, y);
  }

  public PVector getNearbyEmptyCell(int currentX, int currentY) {
      int[][] directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}, {1, 1}, {-1, -1}, {1, -1}, {-1, 1}};
      for (int[] dir : directions) {
          int newX = currentX + dir[0];
          int newY = currentY + dir[1];
          if (!lab.isWall(newX, newY)) {  // Parenthèse fermante ajoutée ici
              return new PVector(newX, newY);
          }
      }
      // Si aucune case libre n'est trouvée, retourne la position actuelle (solution de repli)
      return new PVector(currentX, currentY);
  }
  
}

class GenerateurLabyrinthe {
  
  void genererLabyrinthe(char[][] labyrinthe, char[][][] cotes) {
    int taille = labyrinthe.length;
    int aCreuser = 0;
      
    initialiserLabyrinthe(labyrinthe, cotes, taille);
    aCreuser = compterZonesACreuser(labyrinthe, taille);
    creuserLabyrinthe(labyrinthe, taille, aCreuser);
    definirEntreesSorties(labyrinthe, taille);
    definirCotes(labyrinthe, cotes, taille);
  }

  
  void initialiserLabyrinthe(char[][] labyrinthe, char[][][] cotes, int taille) {
    for (int j = 0; j < taille; j++) {
      for (int i = 0; i < taille; i++) {
        for (int k = 0; k < 4; k++) {
          cotes[j][i][k] = 0;
        }
        labyrinthe[j][i] = (j % 2 == 1 && i % 2 == 1) ? '.' : '#';
      }
    }
  }
  
  int compterZonesACreuser(char[][] labyrinthe, int taille) {
    int count = 0;
    for (int j = 1; j < taille; j += 2) {
      for (int i = 1; i < taille; i += 2) {
        if (labyrinthe[j][i] == '.') {
          count++;
        }
      }
    }
    return count;
  }
  
  void creuserLabyrinthe(char[][] labyrinthe, int taille, int aCreuser) {
    int posX = 1, posY = 1;
    while (aCreuser > 0) {
      int ancienX = posX, ancienY = posY;
      int alea = floor(random(4));
      
      switch (alea) {
        case 0: if (posX > 1) posX -= 2; break;
        case 1: if (posY > 1) posY -= 2; break;
        case 2: if (posX < taille - 2) posX += 2; break;
        case 3: if (posY < taille - 2) posY += 2; break;
      }
      
      if (labyrinthe[posY][posX] == '.') {
        aCreuser--;
        labyrinthe[posY][posX] = ' ';
        labyrinthe[(posY + ancienY) / 2][(posX + ancienX) / 2] = ' ';
      }
    }
  }
  
  void definirEntreesSorties(char[][] labyrinthe, int taille) {
    labyrinthe[0][1] = ' ';
    labyrinthe[taille - 2][taille - 1] = ' ';
  }
  
  void definirCotes(char[][] labyrinthe, char[][][] cotes, int taille) {
    for (int j = 1; j < taille - 1; j++) {
      for (int i = 1; i < taille - 1; i++) {
        if (labyrinthe[j][i] == ' ') {
          boolean hautMur = labyrinthe[j-1][i] == '#';
          boolean basMur = labyrinthe[j+1][i] == '#';
          boolean gaucheMur = labyrinthe[j][i-1] == '#';
          boolean droiteMur = labyrinthe[j][i+1] == '#';
      
          if (hautMur && !basMur && gaucheMur && droiteMur) 
              cotes[j-1][i][0] = 1; // Mur en haut
      
          if (!hautMur && basMur && gaucheMur && droiteMur) 
              cotes[j+1][i][3] = 1; // Mur en bas
      
          if (hautMur && basMur && !gaucheMur && droiteMur) 
              cotes[j][i+1][1] = 1; // Mur à droite
      
          if (hautMur && basMur && gaucheMur && !droiteMur) 
              cotes[j][i-1][2] = 1; // Mur à gauche
          }
      }
    }
  }
}
