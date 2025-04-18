 /**
 * Exploration de Pyramide - Labyrinthe 3D
 * Programme permettant d'explorer un environnement 3D composé d'une pyramide 
 * avec plusieurs étages de labyrinthes à l'intérieur.
 */

// ==================== VARIABLES GLOBALES ====================

boolean showLevelComplete = false;
int transitionAlpha = 0;
int transitionDuration = 20; // Durée de la transition en frames

int transitionStartTime = 0;

boolean showMessage = false; // Pour afficher le message initial
boolean showTransition = false; // Pour afficher la transition
int messageStartTime = 10; // Pour le timer du message
//=============================================================
// === MODES D'AFFICHAGE ===
boolean vuealternative = false;  // Vue extérieure (désert) ou intérieure (labyrinthe)
boolean inLabyrinthe = false;    // Si le joueur est dans le labyrinthe de la pyramide

// === ÉLÉMENTS DE JEU ===
Sable sable;                     // Terrain désertique
ArrayList<Labyrinthe> labyrinthes = new ArrayList<>();  // Différents étages du labyrinthe
Labyrinthe lab;                  // Labyrinthe actuel
Minimap minimap;                 // Carte du labyrinthe pour navigation
int etageActuel = 0;             // Niveau actuel du labyrinthe
int[] taillesEtages = {21, 17, 15, 13, 11};  // Tailles des labyrinthes par étage
ArrayList<Momie> momies;
Compass compass;

// === PYRAMIDES ===
Pyramide pyramidePrincipale;     // Pyramide principale
Pyramide pyramideSecondaire1;    // Pyramide secondaire 1
Pyramide pyramideSecondaire2;    // Pyramide secondaire 2

// === TEXTURES ===
PImage texturePierre;            // Texture pour les murs extérieurs
PImage textureSommet;            // Texture pour le sommet de la pyramide
PImage texturePorte;             // Texture pour la porte d'entrée
PImage textureMur;               // Texture pour les murs du labyrinthe
PImage textureSol;               // Texture pour le sol du labyrinthe

// === CAMÉRA EXTÉRIEURE ===
float camX = 0;                  // Position X de la caméra
float camY = 0;                  // Position Y de la caméra
float camZ = -600;               // Position Z de la caméra
float porteX = 0;                // Position X de la porte
float porteY = 0;                // Position Y de la porte
float porteZ = 0;                // Position Z de la porte

// === POSITION ET MOUVEMENT DU JOUEUR ===
int iposX = 1;                   // Position initiale X
int iposY = 0;                   // Position initiale Y
int posX = iposX;                // Position actuelle X
int posY = iposY;                // Position actuelle Y
int dirX = 0;                    // Direction X (regard)
int dirY = 1;                    // Direction Y (regard)
int odirX = 0;                   // Ancienne direction X (pour animation)
int odirY = 1;                   // Ancienne direction Y (pour animation)

// === ANIMATION ===
int anim = 0;                    // Compteur d'animation
boolean animT = false;           // Animation de déplacement en cours
boolean animR = false;           // Animation de rotation en cours
boolean inLab = true;            // Vue dans le labyrinthe

// ==================== INITIALISATION ====================

void setup() {
  // Configuration de base
  randomSeed(2);
  size(1000, 700, P3D);
  
  // Chargement des textures
  chargerTextures();

  // Paramètres pour les pyramides
  int tailleBase = 21;
  int nbEtages = 9;
  float tailleCellule = 40;
  float hauteurNiveau = 60;
  
  // Création du sable du désert
  sable = new Sable(200, 5, 40, 20.0);
  
  // Création des labyrinthes pour chaque étage
  creerLabyrinthes();
  
  // Sélection du premier labyrinthe
  lab = labyrinthes.get(0);
  
  // Création des pyramides
  pyramidePrincipale = new Pyramide(tailleBase, nbEtages, tailleCellule, hauteurNiveau, texturePierre, textureSommet, texturePorte);
  pyramideSecondaire1 = new Pyramide(21, 9, 40, 60, texturePierre, textureSommet, texturePorte);
  pyramideSecondaire2 = new Pyramide(25, 10, 40, 60, texturePierre, textureSommet, texturePorte);
  
  this.momies = new ArrayList<Momie>();
  
  this.momies.add(new Momie(1, 1));
  this.momies.add(new Momie(lab.getEmptyCell(1, 1)));
  
  // Création de la minimap
  this.minimap = new Minimap(lab, momies);
  this.compass = new Compass(0.4);
}

// ==================== FONCTIONS PRINCIPALES ====================

void draw() {
  if (inLabyrinthe) {
    dessinerLabyrinthe();
    drawMessage(); // Affiche d'abord le message
    drawTransition(); // Puis la transition si elle est activée
  } else {
    if (vuealternative) {
      dessinerVueExterieure();
    } else {
      dessinerVuePyramide();
    }
  }
}

// ==================== FONCTIONS DE CHARGEMENT ====================

/**
 * Charge toutes les textures nécessaires
 */
void chargerTextures() {
  texturePierre = loadImage("assets/images/pyramide_brique.jpg");
  textureSommet = loadImage("assets/images/pyramide_haut.jpg");
  texturePorte = loadImage("assets/images/pyramide_porte.png");
  textureMur = loadImage("assets/images/mur_stones.jpg");
  textureSol=loadImage("assets/images/sol_stones.jpg");
}

/**
 * Crée les différents labyrinthes pour chaque étage
 */
void creerLabyrinthes() {
    for (int taille : taillesEtages) {
        Labyrinthe labyrinthe = new Labyrinthe(taille, textureMur, textureSol);
        
        // Appliquer les couleurs aux murs
        AffichageLabyrinthe affichage = labyrinthe.getAffichage();
        affichage.applyColorToWalls();
        
        labyrinthes.add(labyrinthe);
    }
}

// ==================== FONCTIONS DE RENDU ====================

/**
 * Dessine la vue extérieure avec le désert et les pyramides
 */
void dessinerVueExterieure() {
  float scalePorte = calculerEchellePorte();
  
  background(190, 170, 255);
  translate(width / 2 + camX, height / 2 + 100 + camY, camZ);
  rotateX(PI / 2);
  
  // Rotation progressive jusqu'à une certaine limite
  float rotationZ = min(frameCount * 0.005, 3.2);
  rotateZ(rotationZ);
  
  // Dessiner le désert et les pyramides
  drawDesert(8000, 200, 0.02, 20);
  pyramidePrincipale.dessiner(scalePorte);
  
  // Dessiner les pyramides secondaires
  dessinerPyramidesSecondaires(scalePorte);
  
  // Vérifier si on est devant la porte
  verifierEntreePyramide();
}

/**==========================================================
 * Dessine la vue avec la pyramide en haut à droite
 =========================================================*/
void dessinerVuePyramide() {
  float scalePorte = calculerEchellePorte();
  sable.dessinerSable();
  
  // Dessiner la pyramide positionnée en haut à droite
  pushMatrix();
  translate(width, height / 2 + 110, -700);
  rotateX(PI / 2);
  rotateZ(PI / 3);
  pyramidePrincipale.dessiner(scalePorte);
  popMatrix();
}
//=========================================================================

/**
 * Dessine l'intérieur du labyrinthe avec caméra subjective
 */
void dessinerLabyrinthe() {
  background(192);
  sphereDetail(6);
  if (anim > 0) anim--;

  // Configuration de la caméra et des lumières pour le labyrinthe
  setupLabyrintheCameraLights();

  // Ajuster la perspective et la caméra selon l'animation
  ajusterCameraLabyrinthe();
  
  // Dessiner les murs du labyrinthe
  noStroke();
  lab.getAffichage().display(inLab);
  
  for (Momie momie : momies) {
    momie.drawMomie();
  }
  
  // Afficher la minimap en haut à gauche
  minimap.drawMinimap();
  
  compass.drawCompass();
  
  // Vérifier si le joueur a atteint la sortie
  verifierSortieEtage();
}

// ==================== FONCTIONS AUXILIAIRES DE RENDU ====================

/**
 * Dessine les pyramides secondaires dans la vue extérieure
 */
void dessinerPyramidesSecondaires(float scalePorte) {
  pushMatrix();
  translate(500, -600, -300);
  pyramideSecondaire1.dessiner(scalePorte);
  popMatrix();
  
  pushMatrix();
  translate(-500, -600, -300);
  pyramideSecondaire1.dessiner(scalePorte);
  popMatrix();
}

/**
 * Configure la caméra et les lumières pour le labyrinthe
 */
void setupLabyrintheCameraLights() {
  perspective();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), 
         width/2.0, height/2.0, 0, 0, 1, 0);
  noLights();
  stroke(0);
}

/**
 * Ajuste la caméra du labyrinthe selon l'animation en cours
 */
void ajusterCameraLabyrinthe() {
  stroke(0);
  if (inLab) {
    float wallW = width/lab.getSize();
    float wallH = height/lab.getSize();
    
    perspective(2*PI/3, float(width)/float(height), 1, 1000);
    
    if (animT) {
      // Animation de déplacement
      camera((posX-dirX*anim/20.0)*wallW, (posY-dirY*anim/20.0)*wallH, -15+2*sin(anim*PI/5.0), 
             (posX-dirX*anim/20.0+dirX)*wallW, (posY-dirY*anim/20.0+dirY)*wallH, -15+4*sin(anim*PI/5.0), 0, 0, -1);
    } else if (animR) {
      // Animation de rotation
      camera(posX*wallW, posY*wallH, -15, 
            (posX+(odirX*anim+dirX*(20-anim))/20.0)*wallW, (posY+(odirY*anim+dirY*(20-anim))/20.0)*wallH, -15-5*sin(anim*PI/20.0), 0, 0, -1);
    } else {
      // Vue normale
      camera(posX*wallW, posY*wallH, -15, 
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15, 0, 0, -1);
    }
    lightFalloff(0.0, 0.01, 0.0001);
  } else {
    lightFalloff(0.0, 0.05, 0.0001);
  }
  
  // Ajouter une lumière à la position du joueur
  float wallW = width/lab.getSize();
  float wallH = height/lab.getSize();
  pointLight(255, 255, 255, posX*wallW, posY*wallH, 15);
}

// ==================== FONCTIONS DE CALCUL ====================

/**
 * Calcule l'échelle de la porte en fonction de la distance de la caméra
 */
float calculerEchellePorte() {
  float scalePorte = map(abs(camZ), 200, 800, 2.0, 0.5);
  return constrain(scalePorte, 0.5, 2.0);
}

/**
 * Vérifie si le joueur est assez proche pour entrer dans la pyramide
 */
void verifierEntreePyramide() {
  if (dist(camX, camY, camZ, porteX, porteY, porteZ) < 99) {
    inLabyrinthe = true;
  }
}

/**============================================================================================================
 * Vérifie si le joueur a atteint la sortie de l'étage actuel
 // millis():retourne le nombre de millisecondes écoulées depuis que le programme a commencé à s'exécuter
=============================================================================================================== */
 
void verifierSortieEtage() {
  if (posX == lab.getSize()-1 && posY == lab.getSize()-2) {
    if (!showMessage && !showTransition) {
      showMessage = true;
      messageStartTime = millis();
    }
  }
}

/**
 * Passe au niveau suivant du labyrinthe
 */
void passerEtageSuivant() {
  
  this.lab = labyrinthes.get(etageActuel);
  
  this.momies.clear();
  this.momies.add(new Momie(1, 1));
  this.momies.add(new Momie(lab.getEmptyCell(1, 1)));
  
  this.minimap = new Minimap(lab, momies);
  
  // Réinitialiser la position et la direction du joueur
  posX = 1; 
  posY = 0;
  dirX = 0; 
  dirY = 1;
  
  // Réinitialisation graphique
  resetMatrix();
  textureMode(NORMAL);
}

// ==================== GÉNÉRATION DU TERRAIN ====================

/**
 * Génère terrain désertique
 */
void drawDesert(float size, int resolution, float scale, float height) {
  noStroke();
  textureMode(NORMAL);
  fill(184, 134, 11);  // Couleur sable

  for (int z = 0; z < resolution; z++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x <= resolution; x++) {
      float xPos = map(x, 0, resolution, -size / 2, size / 2);
      float zPos = map(z, 0, resolution, -size / 2, size / 2);
      float zPos2 = map(z + 1, 0, resolution, -size / 2, size / 2);

      // Utilisation du bruit de Perlin pour la hauteur
      float h1 = noise((xPos + 1000) * scale, (zPos + 1000) * scale) * height;
      float h2 = noise((xPos + 1000) * scale, (zPos2 + 1000) * scale) * height;

      vertex(xPos, zPos, h1);
      vertex(xPos, zPos2, h2);
    }
    endShape();
  }
}

// ==================== GESTION DES ENTRÉES UTILISATEUR ====================

void keyPressed() {
  if (inLabyrinthe) {
    if (showMessage && keyCode == 32) {
      startTransition();
    } else if (!showMessage && !showTransition) {
      gererTouchesLabyrinthe();
    }
  } else {
    gererTouchesExterieur();
  }
}

/**
 * Gère les touches pour la navigation dans le labyrinthe
 */
void gererTouchesLabyrinthe() {
  if (anim == 0) {
    if (keyCode == UP) {
      deplacerJoueurAvant();
    } else if (keyCode == DOWN) {
      deplacerJoueurArriere();
    } else if (keyCode == LEFT) {
      tournerJoueurGauche();
    } else if (keyCode == RIGHT) {
      tournerJoueurDroite();
    }
    
    minimap.updatePlayerPosition(posX, posY, dirX, dirY);
  }
  
  minimap.updateDiscoveredArea();
}

/**
 * Gère les touches pour la navigation extérieure
 */
void gererTouchesExterieur() {
  if (key == 32) { // Barre d'espace pour changer de vue
    vuealternative = !vuealternative;
  }

  if (vuealternative) {
    if (key == CODED) {
      if (keyCode == UP) {
        camZ += 50;      // Avancer
      } else if (keyCode == DOWN) {
        camZ -= 50;      // Reculer
      } else if (keyCode == LEFT) {
        camX += 50;      // Gauche
      } else if (keyCode == RIGHT) {
        camX -= 50;      // Droite
      }
    }
  }
}

// ==================== FONCTIONS DE DÉPLACEMENT DU JOUEUR ====================

void deplacerJoueurAvant() {
  if (!lab.isWall(posX+dirX, posY+dirY)) {
    posX += dirX; 
    posY += dirY;
    anim = 20;
    animT = true;
    animR = false;
  }
}

void deplacerJoueurArriere() {
  if (!lab.isWall(posY-dirY, posX-dirX)) {
    posX -= dirX;
    posY -= dirY;
  }
}

void tournerJoueurGauche() {
  odirX = dirX;
  odirY = dirY;
  anim = 20;
  int tmp = dirX; 
  dirX = dirY; 
  dirY = -tmp;
  animT = false;
  animR = true;
  
  compass.rotateToNextDirection(false);
}

void tournerJoueurDroite() {
  odirX = dirX;
  odirY = dirY;
  anim = 20;
  animT = false;
  animR = true;
  int tmp = dirX; 
  dirX = -dirY; 
  dirY = tmp;
  
  compass.rotateToNextDirection(true);
}




//=======================================================================================================================
  //                         Dessiner un effet de transition visuel
//=======================================================================================================================
void drawTransitionEffect() {
if (!showTransition) return;
  
  //charge les pixels de l'écran dans un tableau interne afin de pouvoir les manipuler directement
  loadPixels();
  
  float center = width/((transitionAlpha % 10) + 1);
  float r = 0.5, g = 0.3, b = 0.1; // Couleur ambre/or
  
  //Modification de la couleur des pixels 
  for (int i = 0; i < width; ++i) {
    for (int j = 0; j < height; ++j) {
      float re = (255 - (1 - r) * abs(center - dist(width/2., height/2., i, j)) / 2.) % 256;
      float gr = (255 - (1 - g) * abs(center - dist(width/2., height/2., i, j)) / 2.) % 256;
      float bl = (255 - (1 - b) * abs(center - dist(width/2., height/2., i, j)) / 2.) % 256;
      color pxl_color = color(re, gr, bl, transitionAlpha);
      pixels[j * width + i] = pxl_color;
    }
  }
  //mise a jour des pixels 
  updatePixels();
  
  if (transitionAlpha < 255) {
    transitionAlpha += 5;
  }
}


//=======================================================================================================================
void drawTransition() {
  if (!showTransition) return;
  drawTransitionEffect();
  // La transition dure 3 secondes
  if (millis() - transitionStartTime > 3000) {
    passerAuNiveauSuivant();
  }
}



//=======================================================================================================================
void passerAuNiveauSuivant() {
  etageActuel++;
  if (etageActuel < labyrinthes.size()) {
    passerEtageSuivant();
  } else {
    inLabyrinthe = false;
  }
 showTransition = false;
}


//=======================================================================================================================
void drawMessage() {
  if (!showMessage) return;
  
  pushMatrix();
  pushStyle(); // pour les styles graphiques 
  
  // Configuration de base
  camera();
  hint(DISABLE_DEPTH_TEST); // désactive le test de profondeur
  noLights();
  ortho();//definit une projection orthographique
  
  // Fond avec dégradé moderne
  rectMode(CORNER);
  //parcourt chaque ligne de l'écran 
  for (int i = 0; i < height; i++) {
    float inter = map(i, 0, height, 0, 1); // melange des couleur en fonction de la hauteur 
    fill(lerpColor(color(20, 30, 50, 200), color(10, 15, 25, 220), inter));
    noStroke();
    rect(0, i, width, 1);
  }
  
  // Cadre stylisé au tour du message 
  fill(255, 255, 255, 30);
  stroke(150, 180, 255, 150);
  strokeWeight(3);
  rect(width/2 - 310, height/2 - 70, 620, 140, 15);
  
  // Style du texte
  textAlign(CENTER, CENTER);
  
  // Titre principal - Effet néon bleu
  textSize(42);
  fill(#4DF2FF); // Bleu cyan vif
  text("Niveau Terminé", width/2, height/2 - 25);
  
  // Animation de lueur pour le titre
  
  fill(#4DF2FF, 50);
  for (int i = 0; i < 3; i++) {
    text("Niveau Terminé", width/2, height/2 - 25);
  }
  
  // Texte d'instruction - Dégradé violet/orange
  textSize(28);
  fill(255);
  text("Appuyez sur", width/2 - 80, height/2 + 25);
  
  // Bouton ENTRER stylisé
  float pulse = sin(frameCount * 0.15) * 5 + 5;
  textSize(30 + pulse);
  fill(#FF6EC7); // Rose fluo
  text("ESPACE", width/2 + 70, height/2 + 25);
  
  // Contour pulsant du bouton
  noFill();
  stroke(#FF6EC7, 150);
  strokeWeight(1 + pulse/10);
  rect(width/2 + 15, height/2 + 5, 120, 30, 5);
  
  hint(ENABLE_DEPTH_TEST);
  popStyle();
  popMatrix();
  
  // Transition automatique après délai
  if (millis() - messageStartTime > 20000) {
    startTransition();
  }
}


//=======================================================================================================================
void startTransition() {
  showMessage = false;
  showTransition = true;
  transitionAlpha = 0;
  transitionStartTime = millis();
}
