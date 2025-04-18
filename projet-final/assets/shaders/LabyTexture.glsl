// calcule la position des sommets, transforme les normales et prépare les données de texture et d'éclairage pour chaque vertex qui sera rendu.

uniform mat4 transform;
uniform mat4 modelview;
uniform mat3 normalMatrix;

attribute vec4 vertex;
attribute vec4 color;
attribute vec3 normal;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec3 vertPosition;

void main() {
  gl_Position = transform * vertex;    
  vertPosition = vec3(modelview * vertex);
  vertColor = color;
  
  vertNormal = normalize(normalMatrix * normal);
  vertLightDir = normalize(vec3(0, 0, 1));
}