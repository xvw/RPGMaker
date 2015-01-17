[Toute version] Afficheur de texte à l'écran
=======================

###Objectif
L'objectif de ce script est de permettre l'affichage de textes à l'écran (sur une map), à la manière (simple) des images de RPGMaker. Ce script offre une routine de génération de profile et de couleur pour ne pas devoir réécrire sans arrêt les paramétres de mise en forme de la typographie.

###Licence 
Aucune, vous en faites l'usage que vous voulez.

###Installation
Ce script requiert l'installation de [StandardizeRGSS](https://github.com/nukiFW/RPGMaker/tree/master/StandardizeRGSS) pour fonctionner.  
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/DisplayText/script.rb) dans votre éditeur de script au dessus de Main, dans la rubrique Materials. Vous pouvez lui attribuer un emplacement réservé. Et le nommer comme vous l'entendez. Personnellement, j'ai choisi le nom DisplayText (original :P !)

###Gestion des profils et de la couleur
Les profiles et les couleurs permettent de sauvegarder un profile ou une couleur facilement accessible et utilisable pour mettre en forme le texte.

####Accéder à une couleur 
Pour récupérer une couleur il suffit d'utiliser la commande `get_color(:nom_de_la_couleur)`. Il existe, par défaut, dans le script, une liste de couleur déjà préparée : 

*    `get_color(:black)`
*    `get_color(:white)`
*    `get_color(:red)`
*    `get_color(:green)`
*    `get_color(:blue)`

####Accéder à un profil
Comme pour la couleur, il suffit d'utiliser la commande `get_profile(:nom_du_profil)`. Il n'existe, par défaut, qu'un seul profil, il s'agit de `get_profile(:default)` qui correspond à la mise en forme standard de texte selon RPG Maker.

####Créer une couleur
Pour créer une couleur, il suffit d'appeler la commande `create_color(R,V,B,*O).register(:nom_désiré)`.
*   `R` étant la valeur de rouge de la couleur (de 0 à 255)
*   `V` étant la valeur de vert de la couleur  (de 0 à 255)
*   `B` étant la valeur de bleu de la couleur  (de 0 à 255)
*   `*O` étant l'opacité de la couleur (de 0 à 255) (Cet argument peut être ommis, par défaut, il vaut 255).


Je conseil de créer les couleurs (comme les profils) dans un script vierge en dessous de ce script. Une fois qu'une couleur est enregistrée, elle peut être appelée via `get_color(:nom_désiré)`. 

####Créer un profil 
La commande `create_profile` crée un profil vierge (identique au profil `:default`) et `create_profil(autre_profil)` crée un profil qui a les mêmes caractéristiques que l'autre profil passé en argument.  
Les attributs d'un profil sont : 
*   `font` Le nom de la police à utiliser (ou la liste de noms de polices à utiliser)
*   `size` La taille de la police
*   `color` La couleur du texte (on peut utiliser `get_color` et utiliser une couleur prédéfinie)
*   `italic` Prend `true` pour être italic, `false` pour ne pas l'être
*   `bold` Prend `true` pour être en gras, `false` pour ne pas l'être
*   `outline` Prend `true` pour avoir un contour, `false` pour ne pas en avoir (ne fonctionne que sur vx et ace)
*   `outline_color` La couleur du contour (on peut utiliser `get_color` et utiliser une couleur prédéfinie) (ne fonctionne que sur vx et ace)
*   `shadow` Prend `true` pour avoir une ombre, `false` pour ne pas en avoir (ne fonctionne que sur ace)
*   `multiline` Prend `true` pour permettre le texte multiligne, `false` pour ne permettre que l'uni ligne

**Exemple de création de deux profils dans un script vierge en dessous du script**  
```ruby
# Création du premier profil
unprofil = create_profile
unprofil.color = get_color(:red)
unprofil.font = "impact"
unprofil.italic = false
unprofil.bold = false
unprofil.outline = false
unprofil.shadow = false
unprofil.size = 22
unprofil.register(:profilA)

# Création du second profil
unautreprofil = create_profile(get_profile(:profilA))
unautreprofil.color = get_color(:green)
unautreprofil.register(:profilB)
```

Comme vous pouvez le voir, il n'est pas nécéssaire de spécifier tous les attributs lors de la création d'un profil. Par exemple, la création du profil 2 se basera sur les données du profil 1 et seul la couleur sera changée. Quand aucun profil n'est passé en argument, c'est le profil par défaut qui est utilisé en modèle.  
Vous pouvez maintenant vous servir de ces deux profils pour mettre en forme du texte. A noter que l'on peut décrire autant de profil que l'on veut. (C'est pour ça que comme pour les couleurs, je les mets dans un script en vierge en dessous de ce script. Pour accéder rapidement à tous les profils/couleurs créé(e)s).

#####Notes sur l'attribut font
Généralement, cet attribut prend en argument une chaine de caractères, mais il est possible de lui passer une liste (`["police1", "police2" etc.]`) et si la première police n'est pas trouvée, il passe à la suivante etc. 

#####Notes sur l'attribut multiline
Pour effectuer un retour à la ligne, dans le texte (nous verrons plus tard comment en créer) il suffit de faire, dans l'appel de script, un retour à la ligne ou alors d'utiliser le caractères `\n`.

###Création et déplacement de textes
Maintenant que nous avons vu comment créer des profils et des couleurs, nous allons afficher du texte (et le déplacer) à l'écran. Les commandes s'appellent au moyen d'appels de scripts.   
Comme pour les images, les textes sont référencés par un ID (qui est un chiffre). Il n'y a pas de limitation explicite, mais attention, trop de textes différents peuvent faire laguer le jeu (comme pour les images).

####Affichage de texte 
```ruby
text_show(id, text_value, profile, x, y, zoom_x = 100, zoom_y = 100, opacity = 255, blend_type = 0, origin = 0)
```
Cette commande permet d'afficher du texte à l'écran. Voyons ses arguments : 

*    `id` correspond au nombre, ID, où afficher l'imge (de 1 à ce que vous voulez) 
*    `text_value` le texte a afficher 
*    `profile` le profil pour mettre en forme le texte (accessible via `get_profile(:nom)) 
*    `x` et `y` la position du texte 
*    `zoom_x` et `zoom_y` le pourcentage d'agrandissement (par défaut ils valent tout deux 100%)
*    `opacity` l'opacité du texte (de 0 à 255) (par défaut cet argument vaut 255)
*    `blend_type` le mode de fusion (0 = normal, 1 = addition, 2 = soustraction), par défaut il vaut normal
*    `origin` 0 pour l'origine en haut à gauche du texte, 1 pour le centre comme origine.

Les arguments de `zoom_x` sont facultatif, leur valeur est indiquée. Cependant, on ne peut profiter des valeurs par défaut que si tous les arguments sont spécifiés. On ne peut donc pas profiter de la valeur par défaut de `zoom_x` si l'on veut spécifier `zoom_y` (ce qui est logique). Voici quelques exemples d'affichages de textes (en prenant les profils précédemment créés) : 
```ruby
text_show(1, "Salut", get_profile(:profilA), 10, 15)
text_show(2, "Aurevoir", get_profile(:profilB), 30, 30, 100, 100, 120)
text_show(3, "Nuki", get_profile(:profilA), 0, 0, 75, 75, 255, 1, 1)
```

####Déplacement de texte
Cette commande fonctionne presque comme la commande déplacer une image de RPG Maker
```ruby
text_move(id, duration, wait_flag, x = -1, y = -1, zoom_x = -1, zoom_y = -1, opacity = -1, blend_type = -1, origin = -1)
``` 
*    `id` correspond au nombre, ID, où afficher l'imge (de 1 à ce que vous voulez) 
*    `duration` la durée de modification
*    `wait_flag` Si il vaut `true`, le jeu se bloquera pendant le déplacement du texte, s'il vaut `false`, le jeu continuera malgré le déplacement
*    `x` et `y` la position du texte 
*    `zoom_x` et `zoom_y` le pourcentage d'agrandissement (par défaut ils valent tout deux 100%)
*    `opacity` l'opacité du texte (de 0 à 255) (par défaut cet argument vaut 255)
*    `blend_type` le mode de fusion (0 = normal, 1 = addition, 2 = soustraction), par défaut il vaut normal
*    `origin` 0 pour l'origine en haut à gauche du texte, 1 pour le centre comme origine.

Comme pour la commande précédente, les arguments à partir de `x` (inclus) ont une valeur par défaut, il s'agit de -1, qui indique que l'attribut doit garder la même propriété. Donc par exemple : 
```ruby
text_move(1, 60, true, 500) # déplacera le texte 1 à 500px de l'écran en 60 frames (bloquant le jeu). Les autres propriétés garderont leurs valeurs.
text_move(2, 120, false, -1, -1, 200, 200) # zoomera le texte a 200% en x et 200% en 120 frames, sans bloquer le jeu, en conservant les autres propriétés.
```

####Autre fonctions
Il est aussi possible de ne modifier que le contenu du texte ou le profil et de supprimer les textes ;) : 

*    `text_erase(id)` supprime le texte dont l'id est passé en argument
*    `text_change(id, nouveau_texte)` Change le texte affiché
*    `text_change_profile(id, nouveau_profil)` Change le profil du texte passé en argument. (profils accessibles via `get_profile`)
*    `text_rotate(id, speed)` fait tourner le texte (autour de son origine) à la vitesse passée en argument. Pour inverser le sens, il suffit de mettre une vitesse négative.
*    `text_opacity(id, value)` Change l'opacité d'un texte. (De 0 à 255)

###Conclusion
Afficher des textes devient facile, flexible et manipulable. Il devient très facile d'afficher des dégats à l'écran ou encore des points de vies. Bonne utilisation.
