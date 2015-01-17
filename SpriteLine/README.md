[Toute Versions] Sprite_Line
=======================

Il s'agit d'une petite classe qui permet de représenter des segments sur RPG Maker (dont on peut raffraichir la position de départ et d'arrivée). La lecture du code devrait être suffisante pour en comprendre son fonctionnemment.  

**Arguments du constructeur**
`Sprite_Line.new(xa, ya, xb, yb, len, color, *viewport)` où :
*   `xa, ya` représente le point de départ de la droite
*   `xb, yb` représente le point d'arrivée' de la droite
*   `len` la largeur de la droite
*   `color` Un objet Color pour la couleur de la droite
*   `*viewport` Le viewport de la droite (facultatif)
