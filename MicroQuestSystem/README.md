[VXAce] Petit système de quêtes
=======================

###Objectif
Avant toute chose, ce script est avant tout une manière d'expérimenter la flexibilité (et le gain de temps) offert par le script de base de données personnalisable. L'objectif, ici, n'est donc pas de produire "le script le plus puissant" (le plus personnalisable et avec le plus de fonction) des systèmes de quêtes, mais plutôt un micro système, facile à prendre en main (qui donnera peut être naissance à un système plus conséquent dans le futur). Ce script permet donc de déployer rapidement des quêtes dans son projet. 

![Exemple](https://github.com/nukiFW/RPGMaker/blob/master/MicroQuestSystem/screen.png?raw=true)

###Licence 
Aucune, vous en faites l'usage que vous voulez.

###Installation
Ce script requiert l'installation de [CustomDatabase](https://github.com/nukiFW/RPGMaker/tree/master/CustomDatabase) pour fonctionner.  
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/MicroQuestSystem/QuestSystem.rb) dans votre éditeur de script au dessus de Main, dans la rubrique Materials. Vous pouvez lui attribuer un emplacement réservé. Et le nommer comme vous l'entendez. Personnellement, j'ai choisi le nom MicroQuestSystem (original :P !)  
Je conseil de préparer un espace script en dessous de ce script qui servira à insérer les quêtes.

###Utilisation du script
####Création de quêtes
Comme précisé dans l'installation, je conseilles de préparer un espace vierge en dessous du script (mais vous pouvez écrire vos quêtes à la suite du script, sans créer d'autre espace).  
La création d'une quête ne peut pas être faite ingame. Il faut impérativement les créer avant. Cependant, vous pouvez les modifier, supprimer et en ajouter durant la réalisation de votre jeu.  
#####Syntaxe de la création d'une quête : 
```ruby
Quest.insert(ID, NOM, DESCRIPTION, GOLD, EXP, ITEMS, WEAPONS, ARMORS)
```
*    `ID` Correspond à un identifiant (UNIQUE) que vous attribuerez pour accéder rapidement à une quête.
*    `NOM` Le nom de la quête. Il sera affiché dans le journal des quêtes
*    `DESCRIPTION` Une note plus explicite que le nom
*    `GOLD` et `EXP` correspondent à l'argent et l'expérience reçue quand la quête est finie.
*    `ITEMS`, `WEAPONS`, `ARMORS` sont des listes qui contiennent les ID's des objets/armes/armures à recevoir en fin de quête.

Par exemple :
```ruby
Quest.insert(1, "Tuer slimes", 
  "Il faut protéger le village en tuant des slimes", 
  100, 777, [10],[2,3],[2,2,4]
)
```
Cette quête, une fois finie, donnera 100 d'or, 777 d'expérience et l'objet 10, l'arme 2 et l'arme 3, deux armures 2 et une armure 4. Alors que celui-ci :

```ruby
Quest.insert(2, "Manger un chat", 
  "C'est très bon ... miam", 
  10, 78, [],[],[]
)
```
Ne donne que 10 d'or, 78 d'expérience et aucun objet/arme/armur.  
Vous pouvez créer autant de quêtes que vous le désirez. Il faudra utiliser l'ID pour y accéder.

####Lancer une quête
Le démarrage d'une quête indique qu'elle est en cours. Il suffit de faire : `start_quest(ID)`. Dans un appel de script (ou ailleurs). Il est donc très commode de démarrer une quête au moyen d'un appel de script dans un évènement.

####Finir une quête
Une quête ne peut être finie que si elle a été commencée. Il suffit de faire `finish_quest(ID)`. Lorsqu'une quête est finie, la distribution de l'or, de l'expérience et des objets est effectuée toute seule.  
Une quête finie est indiquée en vert dans le journal de quête, et une quête en cours est de la couleur standard.

####Fonctions annexes
*    `quest_on_the_road?(ID)` ou `quest_in_curse?(ID)` renvoi `true` si la quête est en cours, `false` sinon.
*    `quest_done?(ID)` ou `quest_finished?(ID)` renvoi `true` si la quête est finie, `false` sinon.

####Configuration complémentaire
Il est possible de modifier les textes utilisés en modifiant le module `Vocab` mais aussi d'annuler l'affichage du journal dans le menu en désactivant la constante `QUEST_IN_MENU` du module `Config`

###Conclusion
Ce script est assez "minimaliste" mais offre toute la base nécéssaire à la construction d'un système de quête. Il s'inscrit dans le RGSS et l'usage de la base de données alternative le rend très court et très facile à maintenir (mais aussi à modifier). Il ne faut pas prendre ce script comme une tentative d'évolution mais juste comme un essai de l'usage de ma petite base de données étendue. Que je risque d'utiliser encore fort souvent dans les prochains scripts que je réaliserai ! Bien à vous.