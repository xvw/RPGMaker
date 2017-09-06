[Toute Versions] Standardisation du RGSS
=======================

Ce script a pour objectif de proposer une tentative raisonnable de standardiser certaines fonctionnalités du RGSS pour les rendre "cross-version" et que l'écriture de scripts multi-platforme soit plus aisé.

## Installation
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/StandardizeRGSS/script.rb) dans votre éditeur de script au dessus de Main, dans la rubrique Materials. Vous pouvez lui attribuer un emplacement réservé. Et le nommer comme vous l'entendez. Personnellement, j'ai choisi le nom StandardRGSS (original :P !).  
**Idéalement, placez ce script au dessus de tous les autres des scripts customs**


## Contributeurs

*    Nuki 
*    Grim (Implémentation de la console)
*    Zeus81 (Aide divers)

## Fonctions proposées par le script 
Voici la liste des fonctions proposées.

### RPGMAKER
Liste des fonctions relatives au module RPGMAKER.

*    `RPGMAKER.version`  
     Renvoi un symbole correspondant à la version de RPG Maker `:vxace`, `:vx` ou `:xp`.  
     Si aucune version n'est inférée, le script lance une exception `"Unknown RPG Maker Version"`.

*    `RPGMAKER.vxace?`  
     Retourne `true` si la version est RPG MAKER VXAce, `false` sinon. 

*    `RPGMAKER.vx?`  
     Retourne `true` si la version est RPG MAKER VX, `false` sinon. 

*    `RPGMAKER.xp?`  
     Retourne `true` si la version est RPG MAKER XP, `false` sinon. 

### RGSS
Fonctions utiles et récurrentes

*    `RGSS.from_editor?`  
     Retourne `true` si le jeu est lancé depuis l'éditeur, `false` sinon. 

*    `RGSS.screen`  
     Retourne l'instance de `Game_Screen` courrante.

*    `RGSS.handle`  
     Retourne le `handle` de la fenêtre de jeu (usage pour les `Win32API's`)

### SceneManager
Ce module est un ajout uniquement pour VX et XP qui offre un traitement similaire à VXAce pour les scènes.

*    `SceneManager.scene`  
     Retourne la scène courante. 

*    `SceneManager.scene_is?(Scene)`  
     Retourne `true` si scène courante est une instance de la scène passée en argument, `false` sinon. 

*    `SceneManager.goto(Scene)`  
     Renvoie à la scène passée en argument.

*    `SceneManager.call(Scene)`  
     Renvoie à la scène passée en argument en conservant la scène précédente dans un historique.

*    `SceneManager.return`  
     Renvoie à la scène précédente (via l'historique).

*    `SceneManager.clear`  
     Supprime l'historique de scènes.

*    `SceneManager.exit`  
     Quitte le jeu.

### Ajout divers

*    `Graphics.width` retourne 640 pour RMXP
*    `Graphics.height` retourne 480 pour RMXP

Ajout de divers données dans la classe Font qui ne change rien mais propose mais prévient des bogues.


### Ajout de classes pour RMXP

*    `Game_Interpreter` : Ajout de la classe comme Alias de `Interpreter`

### Support de la console VXAce sur XP et VX
Cette fonction est activable ou désactivable au tout début du script. Elle permet d'afficher (en mode test) une console de déboguage comme sur RPG Maker VX Ace.
