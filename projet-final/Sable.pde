
/*===========================================================================================*/
 /* Classe Sable : génère un sol en forme de dune de sable à l’aide d’un shader et du bruit*/
/*===========================================================================================*/

class Sable {
  
  PShader shader; // Shader pour appliquer des effets visuels (lumièr)

  int tailleGrille;        // Le nombre de points dans chaque dimension (grille carrée)
  float distance;          // Distance entre chaque point de la grille
  float amplitude;         // Hauteur maximale des vagues (relief)
  float facteurBruit;      // Fréquence du bruit (plus petit = plus détaillé)

  // Constructeur : initialise les paramètres du sable
  Sable(int tailleGrille, float distance, float amplitude, float facteurBruit) {
    this.tailleGrille = tailleGrille;
    this.distance = distance;
    this.amplitude = amplitude;
    this.facteurBruit = facteurBruit;

    // Chargement du shader depuis le fichier
    shader = loadShader("assets/shaders/sable_frag.glsl");
    
    // Direction de la lumière utilisée dans le shader
    shader.set("lightDir", 0.5, 1.0, -0.8); 
  }

  // Fonction pour dessiner le sable à l'écran
  void dessinerSable() {
    shader(shader); // Activation du shader
    background(190, 170, 255); // Couleur de fond
    noStroke(); // Pas de bordures visibles pour les formes

    pushMatrix(); // Sauvegarde de la matrice de transformation

    // Centre la grille sur l'écran, légèrement en bas et vers l'arrière
    translate(width / 2 - tailleGrille * distance / 2, height / 2 + 20, -200);

    // Parcours de la grille pour créer les bandes horizontales
    for (int i = 0; i < tailleGrille; i++) {
      beginShape(QUAD_STRIP); // pour dessiner une bande de quadrilatères

      for (int j = 0; j < tailleGrille; j++) {
        // Coordonnées X et Y du point courant
        float x1 = i * distance;
        float y1 = j * distance;

        // Calcul des hauteurs en utilisant du bruit de Perlin
        float h1 = noise(i / facteurBruit, j / facteurBruit) * amplitude;         // Point courant
        float h2 = noise((i + 1) / facteurBruit, j / facteurBruit) * amplitude;   // Point à droite

        // Ajout des deux points à la forme (deux sommets pour faire une bande)
        vertex(x1, h1, y1);                   // Premier point
        vertex(x1 + distance, h2, y1);        // Deuxième point (à droite)
      }

      endShape(); // Fin de la bande
    }

    popMatrix(); // Restauration de la matrice
    resetShader(); // Désactivation du shader
  }
}
