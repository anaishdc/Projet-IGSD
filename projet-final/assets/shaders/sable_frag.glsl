#ifdef GL_ES
precision mediump float; // precision des types de nombre flottants utilisés
#endif

uniform vec3 lightDir; // calculer l'Éclairage , la direction de la lumiere 

void main() {

    // On calcule la position du pixel courant dans l’écran normalisée (valeurs entre 0 et 1)
    //gl_FragCoord.xy donne la position en pixels sur l’écran.
    vec2 screenPos = gl_FragCoord.xy / vec2(1000.0, 500.0);
    

    // definition de la couleur de sable 
    // on divise par 255 pour passer de la plage  0-255 a 0-1
    vec3 sandColor = vec3(184.0/255.0, 134.0/255.0, 11.0/255.0);


    // Génération de grain (3 couches de bruit)
    // dot=produit scalaire ; fract : la partie entiere 
    float grain = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453);
    grain += fract(sin(dot(gl_FragCoord.xy * 0.7, vec2(89.123, 45.678))) * 65432.123) * 0.5;
    grain += fract(sin(dot(gl_FragCoord.xy * 0.3, vec2(34.567, 12.345))) * 98765.432) * 0.3;
    grain /= 1.8; // Normalisation

    // controle de l'Intensité: 
    // Le haut de l’écran a moins de grain, le bas en a plus (comme si la lumière rendait le haut plus "lisse")
    float grainIntensity = 1.0 - smoothstep(0.0, 0.55, screenPos.y);
    grainIntensity = pow(grainIntensity, 0.5); // un peu plus lisible 

    // Appliquer l'effet de grain et l'éclairage
    //on mélange entre pas de grain (1.0) et du grain (grain * 1.5), selon l’intensité qu’on a calculée.
    float grainEffect = mix(1.0, grain * 1.5, grainIntensity);
    float light = max(dot(normalize(lightDir), vec3(0.0, 1.0, 0.0)), 0.7) + 0.3;
    
    vec3 finalColor = sandColor * grainEffect * light;
    
    // l’affiche à l’écran avec une opacité de 1.0
    gl_FragColor = vec4(finalColor, 1.0);
}
