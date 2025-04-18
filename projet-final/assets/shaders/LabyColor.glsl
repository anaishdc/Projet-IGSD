// calcule la couleur finale de chaque pixel en appliquant le modèle d'éclairage

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec3 vertPosition;

void main() {
  float intensity;
  vec4 color;
  vec3 normal = normalize(vertNormal);
  
  // Ambiant
  float ambientStrength = 0.3;
  vec3 ambient = ambientStrength * vec3(1.0, 1.0, 1.0);
  
  // Diffuse
  float diff = max(dot(normal, vertLightDir), 0.0);
  vec3 diffuse = diff * vec3(1.0, 1.0, 1.0);
  
  // Specular
  float specularStrength = 0.5;
  vec3 viewDir = normalize(-vertPosition);
  vec3 reflectDir = reflect(-vertLightDir, normal);
  float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
  vec3 specular = specularStrength * spec * vec3(1.0, 1.0, 1.0);
  
  // Résultat final
  vec3 result = (ambient + diffuse + specular) * vertColor.rgb;
  gl_FragColor = vec4(result, vertColor.a);
}