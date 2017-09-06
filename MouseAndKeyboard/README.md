[VXAce] Support du clavier et de la souris
=======================

Aie, encore un, un script pour le clavier et la souris. Celui de l'Event Extender sera probablement plus intéressant et plus complet, cependant, cette version
sera amenée à évoluer.

### Objectif
Pour être honnête, c'est avant tout pour m'exercer avec les API's de Windows que j'ai développé ce script. Mais aussi car je voudrais, dans un futur écrire certains scripts qui dépenderaient d'un support de la souris. C'est donc pour 
cette raison qu'est né ce script.

### Licence 
Aucune, vous en faites l'usage que vous voulez.

### Installation
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/MouseAndKeyboard/script.rb) dans votre éditeur de script Au dessus de Main, dans la rubrique Materials. Vous pouvez lui attribuer un emplacement réservé. Et le nommer comme vous l'entendez. Personnellement, j'ai choisi le nom Keyboard & mouse (original :P !)

### Gestion du clavier
Les premières "fonctions" permettent de détecter la pression d'une touche selon des comportemments différents. 

*   `Keyboard.trigger?(key)` Renverra `true` a l'instant où une touche (key) est enfoncée. (`false` sinon).
*   `Keyboard.press?(key)` Renverra `true` tant que la touche (key) est enfoncée. (`false` sinon).
*   `Keyboard.repeat?(key)` Renverra `true` tant que la touche (key) est pressée successivement. (`false` sinon).
*   `Keyboard.release?(key)` Renverra `true` à l'instant où la touche (key) est relâchée. (`false` sinon).

#### Liste des touches prises en charge

Voici la liste des touches passables (à la place de `key`) aux fonctions précédentes

`:cancel` `:backspace` `:tab` `:clear` `:enter` `:shift` `:control` `:alt` `:pause` `:caps_lock` `:hangul` `:junja` `:final` `:kanji` `:esc` `:convert` `:nonconvert` `:accept` `:modechange` `:space` `:page_up` `:page_down` `:end` `:home` `:left` `:up` `:right` `:down` `:select` `:print` `:execute` `:snapshot` `:insert` `:delete` `:help` `:0` `:1` `:2` `:3` `:4` `:5` `:6` `:7` `:8` `:9` `:a` `:b` `:c` `:d` `:e` `:f` `:g` `:h` `:i` `:j` `:k` `:l` `:m` `:n` `:o` `:p` `:q` `:r` `:s` `:t` `:u` `:v` `:w` `:x` `:y` `:z` `:lwindow` `:rwindow` `:apps` `:sleep` `:num_0` `:num_1` `:num_2` `:num_3` `:num_4` `:num_5` `:num_6` `:num_7` `:num_8` `:num_9` `:multiply` `:add` `:separator` `:substract` `:decimal` `:divide` `:f1` `:f2` `:f3` `:f4` `:f5` `:f6` `:f7` `:f8` `:f9` `:f10` `:f11` `:f12` `:f13` `:f14` `:f15` `:f16` `:f17` `:f18` `:f19` `:f20` `:f21` `:f22` `:f23` `:f24` `:num_lock` `:scroll_lock` `:lshift` `:rshift` `:lcontrol` `:rcontrol` `:lmenu` `:rmenu` `:browser_back` `:browser_forward` `:browser_refresh` `:browser_stop` `:browser_search` `:browser_favorites` `:browser_home` `:volume_mute` `:volume_down` `:volume_up` `:media_next_track` `:media_prev_track` `:media_stop` `:media_play_pause` `:launch_mail` `:launch_media_select` `:launch_app1` `:launch_app2` `:oem_1` `:oem_plus` `:oem_comma` `:oem_minus` `:oem_period` `:oem_2` `:oem_3` `:oem_4` `:oem_5` `:oem_6` `:oem_7` `:oem_8` `:oem_102` `:process` `:packet` `:attn` `:crsel` `:exsel` `:ereof` `:play` `:zoom` `:noname` `:pa1` `:oem_clear` 

__Touches RPG Maker__

`:DOWN` `:LEFT` `:RIGHT` `:UP` `:A` `:B` `:C` `:X` `:Y` `:Z` `:L` `:R` `:SHIFT` `:CTRL` `:ALT` `:F5` `:F6` `:F7` `:F8` `:F9`

En effet, vous pouvez utiliser les touches RM dans les fonctions.

#### Etats du clavier

Il existe aussi des fonctions qui testent l'état du clavier : 

*    `Keyboard.ctrl?(key)` Qui renvoi `true` si la combinaison `ctrl+touche` est 
effectuée (`false` sinon). Elle peut aussi s'utiliser sans touche `Keyboard.ctrl?` qui se contente de vérifier si une touche de contrôle est pressée.

*    `Keyboard.maj?` Qui renvoi `true` si le clavier est en majuscule (`false` sinon).
*    `Keyboard.alt_gr?` Qui renvoi `true` si la combinaison `alt-gr` est effectuée au clavier (`false` sinon).
*    `Keyboard.caps_lock?` Qui renvoi `true` si le clavier est en `Majuscules verouillées` (`false` sinon).
*    `Keyboard.num_lock?` Qui renvoi `true` si le clavier est en `Pavé numérique verouillé` (`false` sinon).
*    `Keyboard.scroll_lock?` Qui renvoi `true` si le clavier est en `Scroll verouillé` (`false` sinon).


### Gestion de la souris
Les premières "fonctions" permettent de détecter la pression d'une touche selon des comportemments différents. 

*   `Mouse.trigger?(key)` Renverra `true` a l'instant où une touche (key) est enfoncée. (`false` sinon).
*   `Mouse.press?(key)` Renverra `true` tant que la touche (key) est enfoncée. (`false` sinon).
*   `Mouse.repeat?(key)` Renverra `true` tant que la touche (key) est pressée successivement. (`false` sinon).
*   `Mouse.release?(key)` Renverra `true` à l'instant où la touche (key) est relâchée. (`false` sinon).

#### Liste des touches prises en charge

Voici la liste des touches passables (à la place de `key`) aux fonctions précédentes

`:mouse_left` `:mouse_right` `:mouse_center` `:mouse_x1` `:mouse_x2`

#### Tracker la position de la souris
Ces fonctions permettent d'avoir des informations sur la position de la souris (relative à la fenêtre de jeu).

*     `Mouse.x` Renvoi un entier correspondant à l'axe x de la souris
*     `Mouse.y` Renvoi un entier correspondant à l'axe y de la souris
*     `Mouse.x_square` Renvoi un entier correspondant à l'axe x de la case où se trouve la souris
*     `Mouse.y_square` Renvoi un entier correspondant à l'axe y de la case où se trouve la souris
*     `Mouse.over_window?` Renvoi `true` si la souris est sur l'écran, `false` sinon
*     `Mouse.hover_rect?(rect)` Renvoi `true` si la souris est sur le `Rect` passé en argument, `false` sinon

#### Afficher/Masquer le curseur du système
Il est possible que l'on veuille se servir des coordonnées de la souris pour faire un curseur personnalisé. 
En effet, il suffit de placer une image (ou un Sprite) aux coordonnées x/y de la souris. Il existe pour ça une 
commande qui masque le curseur de Windows sur la fenêtre du jeu RPG Maker:

* `Mouse.cursor_system(true ou false)` si c'est `true` qui lui est passé, le curseur de l'OS sera affiché, si c'est 
`false` il sera masqué.
