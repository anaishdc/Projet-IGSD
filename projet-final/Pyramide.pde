/*==================================================================================*/
/*Classe représentant une pyramide 3D composée de plusieurs étages labyrinthiques   */
/*==================================================================================*/


class Pyramide {
  
  ArrayList<DonneesEtage> etages;       // Liste des données de chaque étage (labyrinthe, position, taille)
  float tailleCellule;                  // Taille d'une cellule (case) du labyrinthe
  float hauteurNiveau;                  // Hauteur entre deux étages
  PShape groupeMurs;                    // Groupe de formes représentant les murs extérieurs (coque)
  PImage texturePierre;                 // Texture utilisée pour les murs
  PImage textureSommet;                // Texture du sommet (pointe de la pyramide)
  PImage texturePorte;                 // Texture de la porte d'entrée
  
  
//=========================================================================================================================
  /*Constructeur de la pyramide*/
//=========================================================================================================================

  Pyramide(int tailleBase, int nbEtages, float tailleCellule, float hauteurNiveau, PImage texturePierre, PImage textureSommet, PImage texturePorte) {
    this.tailleCellule = tailleCellule;
    this.hauteurNiveau = hauteurNiveau;
    
    this.texturePierre = texturePierre;
    this.textureSommet = textureSommet;
    this.texturePorte = texturePorte;
    
    this.etages = new ArrayList<DonneesEtage>();
    this.groupeMurs = createShape(GROUP); // Création du groupe pour les murs

    // Création des différents étages de la pyramide
    for (int i = 0; i < nbEtages; i++) {
      int taille = tailleBase - 2 * i;  // Chaque étage est plus petit que le précédent
      if (taille <= 0) break;

      DonneesEtage etage = new DonneesEtage();
      etage.larg = taille;
      etage.haut = taille;
      etage.laby = new int[taille][taille];

      // Génération du labyrinthe
      char[][] labyrinthe = new char[taille][taille];
      char[][][] cotes = new char[taille][taille][4];  // Infos sur les murs des cellules
      GenerateurLabyrinthe generateur = new GenerateurLabyrinthe();
      generateur.genererLabyrinthe(labyrinthe, cotes);

      // Conversion des caractères en 1 (mur) ou 0 (chemin)
      for (int y = 0; y < taille; y++) {
        for (int x = 0; x < taille; x++) {
          etage.laby[y][x] = (labyrinthe[y][x] == '#' ? 1 : 0);
        }
      }

      // Position de l'étage dans l'espace
      etage.decalX = -taille * tailleCellule / 2;
      etage.decalY = -taille * tailleCellule / 2;
      etage.decalZ = i * hauteurNiveau;

      etages.add(etage); // Ajout de l'étage à la liste
    }

    creerCoquePyramide(); // Création des murs extérieurs
  }


//=========================================================================================================================
  /* Création de la coque extérieure de la pyramide (enveloppe entre les étages)*/
//=========================================================================================================================

  void creerCoquePyramide() {
    textureMode(NORMAL);
    textureWrap(REPEAT);

    for (int i = 0; i < etages.size() - 1; i++) {
      DonneesEtage base = etages.get(i);
      DonneesEtage sommet = etages.get(i+1);


      // Coordonnées des coins de l'étage de base
      float bx0 = base.decalX;
      float bx1 = base.decalX + base.larg * tailleCellule;
      float by0 = base.decalY;
      float by1 = base.decalY + base.haut * tailleCellule;
      float bz = base.decalZ;

      // Coordonnées des coins de l'étage du dessus
      float tx0 = sommet.decalX;
      float tx1 = sommet.decalX + sommet.larg * tailleCellule;
      float ty0 = sommet.decalY;
      float ty1 = sommet.decalY + sommet.haut * tailleCellule;
      float tz = sommet.decalZ;

      // Construction des 4 murs entre deux étages
      PShape mur = createShape();
      mur.beginShape(QUADS);
      mur.texture(texturePierre);
      mur.noStroke();

      // Mur avant
      mur.vertex(bx0, by0, bz, 0, 0);
      mur.vertex(bx1, by0, bz, 1, 0);
      mur.vertex(tx1, ty0, tz, 1, 1);
      mur.vertex(tx0, ty0, tz, 0, 1);

      // Mur arrière
      mur.vertex(bx1, by1, bz, 0, 0);
      mur.vertex(bx0, by1, bz, 1, 0);
      mur.vertex(tx0, ty1, tz, 1, 1);
      mur.vertex(tx1, ty1, tz, 0, 1);

      // Mur gauche
      mur.vertex(bx0, by1, bz, 0, 0);
      mur.vertex(bx0, by0, bz, 1, 0);
      mur.vertex(tx0, ty0, tz, 1, 1);
      mur.vertex(tx0, ty1, tz, 0, 1);

      // Mur droit
      mur.vertex(bx1, by0, bz, 0, 0);
      mur.vertex(bx1, by1, bz, 1, 0);
      mur.vertex(tx1, ty1, tz, 1, 1);
      mur.vertex(tx1, ty0, tz, 0, 1);

      mur.endShape();
      groupeMurs.addChild(mur); // Ajout du mur au groupe
    }
  }


//=========================================================================================================================
  /*Fonction principale pour afficher toute la pyramide*/
//=========================================================================================================================

  void dessiner(float scalePorte) {
    dessinerEtages();
    dessinerSommetPyramide(180); // Hauteur du sommet
    dessinerPorte(scalePorte);   // Porte
  }

//=========================================================================================================================
  /* Dessine tous les sols des étages et les murs*/
//=========================================================================================================================

  void dessinerEtages() {
    shape(groupeMurs); // Affichage de la coque
  }


//=========================================================================================================================
  /*Dessine la pointe de la pyramide (le sommet final)*/
//=========================================================================================================================

  void dessinerSommetPyramide(float hauteur) {
    textureMode(NORMAL);
    textureWrap(REPEAT);

    DonneesEtage dernierEtage = etages.get(etages.size() - 1);
    float tailleBase = dernierEtage.larg;
    float demiBase = tailleBase * tailleCellule / 2;
    float zSommet = dernierEtage.decalZ + hauteur;

    float centreX = 0;
    float centreY = 0;

    float baseX0 = -demiBase;
    float baseX1 = demiBase;
    float baseY0 = -demiBase;
    float baseY1 = demiBase;

    beginShape(TRIANGLES);
    texture(textureSommet);
    noStroke();

    // 4 triangles pour chaque face du sommet
    vertex(baseX0, baseY0, dernierEtage.decalZ, 0, 1);
    vertex(baseX1, baseY0, dernierEtage.decalZ, 1, 1);
    vertex(centreX, centreY, zSommet, 0.5, 0);

    vertex(baseX1, baseY0, dernierEtage.decalZ, 0, 1);
    vertex(baseX1, baseY1, dernierEtage.decalZ, 1, 1);
    vertex(centreX, centreY, zSommet, 0.5, 0);

    vertex(baseX1, baseY1, dernierEtage.decalZ, 0, 1);
    vertex(baseX0, baseY1, dernierEtage.decalZ, 1, 1);
    vertex(centreX, centreY, zSommet, 0.5, 0);

    vertex(baseX0, baseY1, dernierEtage.decalZ, 0, 1);
    vertex(baseX0, baseY0, dernierEtage.decalZ, 1, 1);
    vertex(centreX, centreY, zSommet, 0.5, 0);

    endShape();
  }

//=========================================================================================================================
  /*Dessine une porte à la base de la pyramide*/
//=========================================================================================================================
 void dessinerPorte(float scalePorte) {
      textureMode(NORMAL);
      textureWrap(REPEAT);
  
      // Dimensions de base
      float largeurBase = tailleCellule;
      float hauteurBase = tailleCellule * 10;
      float profondeurBase = tailleCellule;
  
      // Appliquer l'échelle
      float largeurPorte = largeurBase * scalePorte;
      float hauteurPorte = hauteurBase * scalePorte;
      float profondeurPorte = profondeurBase * scalePorte;
  
      // Position (au centre du premier étage)
      DonneesEtage etage = etages.get(0);
      float xPorte = etage.decalX + etage.larg * tailleCellule / 2 - largeurPorte / 2;
      float yPorte = etage.decalY - (hauteurPorte - tailleCellule) / 2; // Centrage vertical
      float zBase = etage.decalZ;
  
      // Dessin avec push/popMatrix pour isoler les transformations
      pushMatrix();
         texture(texturePorte);
      translate(xPorte, yPorte, zBase);
      noStroke();
      texture(texturePorte);
  
      // Face avant
      beginShape(QUADS);
         texture(texturePorte);
      vertex(0, 0, profondeurPorte, 0, 0);
      vertex(largeurPorte, 0, profondeurPorte, 1, 0);
      vertex(largeurPorte, hauteurPorte, profondeurPorte, 1, 1);
      vertex(0, hauteurPorte, profondeurPorte, 0, 1);
      endShape();
  
      // Cadre (côtés et haut)
      beginShape(QUADS);
         texture(texturePorte);
      // Côté gauche
      vertex(0, 0, 0, 0, 0);
      vertex(0, 0, profondeurPorte, 1, 0);
      vertex(0, hauteurPorte, profondeurPorte, 1, 1);
      vertex(0, hauteurPorte, 0, 0, 1);
      // Côté droit
      vertex(largeurPorte, 0, 0, 0, 0);
      vertex(largeurPorte, hauteurPorte, 0, 0, 1);
      vertex(largeurPorte, hauteurPorte, profondeurPorte, 1, 1);
      vertex(largeurPorte, 0, profondeurPorte, 1, 0);
      // Haut
      vertex(0, 0, 0, 0, 0);
      vertex(largeurPorte, 0, 0, 1, 0);
      vertex(largeurPorte, 0, profondeurPorte, 1, 1);
      vertex(0, 0, profondeurPorte, 0, 1);
      endShape();
  
      popMatrix();
  }

}
