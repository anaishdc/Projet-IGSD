class Momie {
  
  private float da = PI / 50.; // angle pour la rotation

  private PShape momie;
  private float x, y; 
  private float targetX, targetY;
  private float previousX, previousY; 
  private float currentRotation; 
  private float targetRotation; 
  private int direction; // 0: Haut, 1: Droite, 2: Bas, 3: Gauche
  private float animationProgress; 
  private float animationDuration = 2.0; // Durée de l'animation en secondes
  private float rotationDuration = 0.8; // Durée de la rotation en secondes
  private boolean isRotating; 
  private boolean isMoving; 
  
  // Variables pour l'algorithme A*
  private ArrayList<PVector> path; // Chemin calculé par A*
  private int currentPathIndex; // Index actuel dans le chemin
  private PVector destination; // Destination finale
  private boolean pathCalculated; // Indique si un chemin a été calculé
  
  // Buffers pour éviter les erreurs d'affichage
  private float renderX, renderY; // Position d'affichage
  private float renderRotation; // Rotation d'affichage
  
  public Momie(int x, int y) {
    initMomie();
    
    this.x = x;
    this.y = y;
    this.targetX = x;
    this.targetY = y;
    this.previousX = x;
    this.previousY = y;
    this.renderX = x;
    this.renderY = y;
    
    this.direction = int(random(4)); // Initialiser avec une direction aléatoire
    this.currentRotation = direction * PI / 2;
    this.targetRotation = currentRotation;
    this.animationProgress = 0;
    this.isRotating = false;
    this.isMoving = false;
    this.renderRotation = currentRotation;
    
    this.path = new ArrayList<PVector>();
    this.currentPathIndex = 0;
    this.pathCalculated = false;
    
    // Définir une première destination aléatoire
    selectNewDestination();
  }
  
  public Momie(PVector vector) {
    this(int(vector.x), int(vector.y));
  }
  
  private void initMomie() {
    momie = createShape(GROUP);
    PShape corps = creerCorpsMomie();
    PShape tete = creerTeteMomie();
    PShape yeux = creerYeuxMomie();
    PShape bras = creerBrasMomie();
    PShape mains = creerMainsMomie();
  
    momie.addChild(corps);
    momie.addChild(tete);
    momie.addChild(yeux);
    momie.addChild(bras);
    momie.addChild(mains);
  }
  
  public void drawMomie() {
    // Mettre à jour les positions et rotations d'affichage en fonction des animations en cours
    updateRenderState();
    
    pushMatrix();
    float wallW = width / lab.getSize();
    float wallH = height / lab.getSize();

    translate(renderX * wallW, renderY * wallH, -25);
    rotateX(-PI / 2);
    rotateY(renderRotation);
    scale(0.13);

    shape(momie);
    popMatrix();

    // Gestion de la progression de l'animation
    if (isRotating || isMoving) {
      animationProgress += (1.0 / ((isRotating ? rotationDuration : animationDuration) * 60));
      
      if (animationProgress >= 1.0) {
        animationProgress = 0;
        
        if (isRotating) {
          // Fin de la rotation
          isRotating = false;
          currentRotation = targetRotation;
          
          // Commencer à se déplacer vers la prochaine position
          startMovingToTarget();
        } else if (isMoving) {
          // Fin du déplacement
          isMoving = false;
          x = targetX;
          y = targetY;
          
          // Passer à la prochaine étape du chemin
          moveToNextPathStep();
        }
      }
    }
    
    // Si la momie n'est ni en rotation ni en mouvement, et qu'aucun chemin n'est calculé,
    // alors on calcule un nouveau chemin
    if (!isRotating && !isMoving && !pathCalculated) {
      selectNewDestination();
    }
  }
  
  // Mise à jour des positions et rotations d'affichage
  private void updateRenderState() {
    if (isRotating) {
      // En rotation: on reste sur place mais on tourne
      renderX = x;
      renderY = y;
      renderRotation = lerpAngle(currentRotation, targetRotation, animationProgress);
    } else if (isMoving) {
      // En mouvement: on se déplace
      renderX = lerp(x, targetX, animationProgress);
      renderY = lerp(y, targetY, animationProgress);
      renderRotation = currentRotation;
    } else {
      // Au repos: position et rotation fixes
      renderX = x;
      renderY = y;
      renderRotation = currentRotation;
    }
  }

  // Interpolation d'angle (pour éviter les problèmes avec les angles)
  private float lerpAngle(float a, float b, float t) {
    // Normaliser les angles entre 0 et 2*PI
    a = normalizeAngle(a);
    b = normalizeAngle(b);
    
    // Trouver le chemin le plus court
    float diff = b - a;
    if (diff > PI) diff -= TWO_PI;
    if (diff < -PI) diff += TWO_PI;
    
    return a + diff * t;
  }
  
  // Normaliser un angle entre 0 et 2*PI
  private float normalizeAngle(float angle) {
    while (angle < 0) angle += TWO_PI;
    while (angle >= TWO_PI) angle -= TWO_PI;
    return angle;
  }

  // Commencer à se déplacer vers la cible
  private void startMovingToTarget() {
    // Démarrer l'animation de déplacement
    isMoving = true;
    animationProgress = 0;
  }
  
  private void selectNewDestination() {
      PVector newDest = lab.getEmptyCell(int(x), int(y));
      destination = newDest;
      calculatePath();
  }
  
  // Calculer le chemin avec A* vers la destination
  private void calculatePath() {
    path = findPath(new PVector(x, y), destination);
    currentPathIndex = 0;
    pathCalculated = true;
    
    if (path.size() > 0) {
      // Commencer à suivre le chemin
      moveToNextPathStep();
    } else {
      // Si aucun chemin n'est trouvé, on reste sur place et on cherchera une nouvelle destination au prochain cycle
      pathCalculated = false;
    }
  }
  
  // Passer à la prochaine étape du chemin
  private void moveToNextPathStep() {
    if (path.size() == 0 || currentPathIndex >= path.size()) {
      // Si on a atteint la destination ou si le chemin est vide, on réinitialise
      pathCalculated = false;
      return;
    }
    
    PVector nextPos = path.get(currentPathIndex);
    previousX = x;
    previousY = y;
    targetX = nextPos.x;
    targetY = nextPos.y;
    
    // Déterminer la nouvelle direction
    int newDirection;
    if (targetX > x) newDirection = 1; // Droite
    else if (targetX < x) newDirection = 3; // Gauche
    else if (targetY > y) newDirection = 0; // Haut
    else newDirection = 2; // Bas
    
    // Vérifier si la direction a changé
    if (newDirection != direction) {
      // Mettre à jour la direction et la rotation cible
      direction = newDirection;
      targetRotation = direction * PI / 2;
      
      // Commencer l'animation de rotation
      isRotating = true;
      animationProgress = 0;
    } else {
      // Même direction, on peut directement se déplacer
      startMovingToTarget();
    }
    
    currentPathIndex++;
  }
  
  // Algorithme A* pour trouver le chemin le plus court
  private ArrayList<PVector> findPath(PVector start, PVector goal) {
    ArrayList<PVector> path = new ArrayList<PVector>();
    
    // Si la destination est la même que la position de départ, retourner un chemin vide
    if (int(start.x) == int(goal.x) && int(start.y) == int(goal.y)) {
      return path;
    }
    
    // Initialiser les listes ouvertes et fermées
    ArrayList<Node> openList = new ArrayList<Node>();
    ArrayList<Node> closedList = new ArrayList<Node>();
    
    // Créer le nœud de départ
    Node startNode = new Node(int(start.x), int(start.y), null);
    startNode.g = 0;
    startNode.h = heuristic(startNode, int(goal.x), int(goal.y));
    startNode.f = startNode.g + startNode.h;
    
    // Ajouter le nœud de départ à la liste ouverte
    openList.add(startNode);
    
    // Limiter le nombre d'itérations pour éviter les calculs trop longs
    int maxIterations = 1000;
    int iterations = 0;
    
    while (!openList.isEmpty() && iterations < maxIterations) {
      iterations++;
      
      // Trouver le nœud avec le coût F le plus bas dans la liste ouverte
      Node current = getLowestFCostNode(openList);
      
      // Si nous avons atteint la destination
      if (current.x == int(goal.x) && current.y == int(goal.y)) {
        // Reconstruire le chemin
        while (current != null) {
          path.add(0, new PVector(current.x, current.y));
          current = current.parent;
        }
        
        // Retirer le premier nœud (position actuelle)
        if (path.size() > 0) {
          path.remove(0);
        }
        
        return path;
      }
      
      // Déplacer le nœud actuel de la liste ouverte à la liste fermée
      openList.remove(current);
      closedList.add(current);
      
      // Examiner tous les voisins
      int[][] directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}; // Haut, Droite, Bas, Gauche
      
      for (int[] dir : directions) {
        int neighborX = current.x + dir[0];
        int neighborY = current.y + dir[1];
        
        // Vérifier si c'est une position valide
        if (lab.isWall(neighborX, neighborY)) {
          continue;
        }
        
        // Vérifier si le voisin est déjà dans la liste fermée
        boolean inClosedList = false;
        for (Node node : closedList) {
          if (node.x == neighborX && node.y == neighborY) {
            inClosedList = true;
            break;
          }
        }
        
        if (inClosedList) {
          continue;
        }
        
        // Calculer le coût G pour ce voisin
        int newG = current.g + 1; // Coût de 1 pour se déplacer d'une case
        
        // Vérifier si le voisin est dans la liste ouverte
        Node neighbor = null;
        for (Node node : openList) {
          if (node.x == neighborX && node.y == neighborY) {
            neighbor = node;
            break;
          }
        }
        
        if (neighbor == null) {
          // Si le voisin n'est pas dans la liste ouverte, l'ajouter
          neighbor = new Node(neighborX, neighborY, current);
          neighbor.g = newG;
          neighbor.h = heuristic(neighbor, int(goal.x), int(goal.y));
          neighbor.f = neighbor.g + neighbor.h;
          openList.add(neighbor);
        } else if (newG < neighbor.g) {
          // Si nous avons trouvé un meilleur chemin vers le voisin
          neighbor.parent = current;
          neighbor.g = newG;
          neighbor.f = neighbor.g + neighbor.h;
        }
      }
    }
    
    // Si aucun chemin n'est trouvé ou si le nombre maximum d'itérations est atteint
    return new ArrayList<PVector>();
  }
  
  // Fonction heuristique pour A* (distance de Manhattan)
  private int heuristic(Node node, int goalX, int goalY) {
    return abs(node.x - goalX) + abs(node.y - goalY);
  }
  
  // Obtenir le nœud avec le coût F le plus bas dans une liste
  private Node getLowestFCostNode(ArrayList<Node> list) {
    Node lowestFCostNode = list.get(0);
    
    for (Node node : list) {
      if (node.f < lowestFCostNode.f) {
        lowestFCostNode = node;
      }
    }
    
    return lowestFCostNode;
  }
  
  // Classe interne pour représenter un nœud dans l'algorithme A*
  private class Node {
    int x, y;
    int g; // Coût du départ à ce nœud
    int h; // Estimation heuristique du coût de ce nœud à la destination
    int f; // g + h
    Node parent;
    
    Node(int x, int y, Node parent) {
      this.x = x;
      this.y = y;
      this.parent = parent;
    }
  }
  
  PShape creerMainsMomie() {
    PShape mains = createShape(GROUP);
  
    for (int i = -1; i <= 1; i += 2) {
      PShape main = createShape(GROUP);
      
      main.addChild(loadShape("assets/models/hand" + (i == 1 ? "1" : "2") + ".obj"));
      main.rotateX(-0.3);
      main.rotateZ(i * 0.8);
      main.translate(i * -20, -12, 18);
  
      main.scale(5);
      main.setFill(color(141.3, 141.3, 75));
      main.setStroke(color(50, 40, 30)); // Bordures légèrement plus sombres
  
      mains.addChild(main);
    }

    return mains;
  }


  // Quadstrip ressemblant plus à des bandages si possible (quadstrip en forme de rectangle)
  PShape creerCorpsMomie() {
    float baseRadius = 60;
    float noiseScale = 5.; // variation de couleur
    float heightOffset = PI / 6.;
    int stepSize = 25;
  
    PShape corps = createShape();
    corps.beginShape(QUAD_STRIP);
    corps.noStroke();
    corps.rotateX(PI / 2); // rotation pour aligner correctement la forme
  
    for (int i = -200; i <= 200; i++) {
      float angleA = i / 20.0 * TWO_PI;
      float angleB = i / 30.0 * TWO_PI;
      float heightGap = 3 + cos(heightOffset);
      float noiseValue = 55 + 155 * noise(i / noiseScale); // augmenter min et diminuer max
  
      corps.fill(noiseValue, noiseValue, 75);
  
      float radiusVariation = 8 * cos(i * PI / 200.);
      float outerRadius = baseRadius + radiusVariation;
      float finalRadius = outerRadius + cos(angleB);
  
      corps.vertex(finalRadius * cos(angleA), finalRadius * sin(angleA), heightGap + i); // Premier sommet
  
      radiusVariation = 8 * cos((i + stepSize) * PI / 200.); // second sommet
      outerRadius = baseRadius + radiusVariation;
      finalRadius = outerRadius + cos(angleB);
  
      corps.vertex(finalRadius * cos(angleA + da), finalRadius * sin(angleA + da), heightGap + (i + stepSize)); // second sommet
    }
  
    corps.endShape(CLOSE);
    return corps;
  }

  PShape creerTeteMomie() {
    PShape head = createShape();
    head.beginShape(QUAD_STRIP);
    head.noStroke();
    head.rotateX(PI / 2);
  
    // Dessiner la tête en utilisant une bande de quads
    for (int i = -100; i <= 90; i++) {
      float angle1 = i / 22.0f * TWO_PI;
      float angle2 = i / 32.0f * TWO_PI;
      float noiseValue = 55 + 155 * noise(i / 11.f);
      float depth = 255 + cos(28.0f);
  
      head.fill(noiseValue, noiseValue, 55);
  
      // rayons pour les sommets
      float radius2 = 16 + 34 * cos(i * PI / 195) + cos(angle2);
  
      // Ajouter les sommets à la forme
      head.vertex(radius2 * cos(angle1), radius2 * sin(angle1), depth + i);
  
      radius2 = 15 + 35 * cos((i + 25) * PI / 195) + cos(angle2);
  
      head.vertex(radius2 * cos(angle1 + da), radius2 * sin(angle1 + da), depth + i + 24);
    }
  
    head.endShape(CLOSE);
    return head;
  }
  
  // Suggestion prof : un PShape pour l'oeil et l'autre pour la pupille
  PShape creerYeuxMomie() {
    PShape eyes = createShape(GROUP);
  
    for (int i = -1; i <= 1; i += 2) {
      float xPosition = i * 16;
  
      PShape eye = createShape(SPHERE, 10);
      eye.scale(1.7, 1., 1.);
      eye.translate(xPosition, -280, 35);
      eye.setStroke(false);
  
      PShape eyeball = createShape(SPHERE, 3);
      eyeball.scale(1., 1.7, 1.);
      eyeball.translate(xPosition + i * 7, -280, 42);
  
      eyeball.setFill(color(0));
  
      eyes.addChild(eye);
      eyes.addChild(eyeball);
    }
  
    return eyes;
  }
  
  PShape creerBrasMomie() {
    PShape bras = createShape(GROUP);
  
    for (int direction = -1; direction <= 1; direction += 2) {
      PShape brasForme = createShape();
      brasForme.beginShape(QUAD_STRIP);
      brasForme.noStroke();
      brasForme.rotateX(PI / 2);
  
      for (int i = -100; i <= 100; i++) {
        float angleA = i / 20.0 * TWO_PI;
        float angleB = i / 30.0 * TWO_PI;
        float noiseValue = 55 + 155 * noise(i / 5.);
  
        float radiusVariation = 8 * cos(i * PI / 100.);
        float outerRadius = 20 + radiusVariation;
        float finalRadius = outerRadius + cos(angleB);
  
        brasForme.fill(noiseValue, noiseValue, 75);
  
        // Épaules plus volumineuses
        if (i < -50) {
          finalRadius *= 1.5;
        }
        // Coudes plus petits
        else if (i > -50 && i < 0) {
          finalRadius *= 0.7;
        }
        // Avant-bras plus volumineux
        else if (i > 0 && i < 50) {
          finalRadius *= 1.3;
        }
  
        brasForme.vertex(finalRadius * cos(angleA), finalRadius * sin(angleA), i);
        brasForme.vertex(finalRadius * cos(angleA + da), finalRadius * sin(angleA + da), i + 25);
      }
  
      brasForme.endShape(CLOSE);
      brasForme.rotateZ(-direction * PI / 3); // Rotation de ±90 degrés autour de l'axe Z
      brasForme.rotateY(-direction * PI / 4);
      brasForme.translate(direction * 80, -100, 50);
      bras.addChild(brasForme);
    }
  
    return bras;
  }
  
  public float getX() {
    return this.x;
  }
  
  public float getY() {
    return this.y;
  }
  
  public float getCurrentRotation() {
    return this.currentRotation;
  }
}
