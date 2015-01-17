[VXAce] Tressailleur d'évènements (Buzzer)
====================

Refonte (et amélioration) d'un script réalisé par Fabien, de la Factory (R.I.P) pour RPG Maker XP. Premièrement réécrit par XHTMLBoy pour VX et réécrit par moi pour VXAce (avec beaucoup des options en plus). Il s'agit d'un outil pour faire vibrer les évènements comme dans Golden Sun.

![Exemple](http://nukifw.github.io/images/scripts/buzzer.gif)


###Installation
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/Buzzer/script.rb) dans votre éditeur de script 
Au dessus de __Main__, dans la rubrique __Materials__. Vous pouvez lui attribuer un emplacement réservé. Et le nommer
comme vous l'entendez. Personnellement, j'ai choisi le nom `Buzzer` (original :P !).  

###Faire tressaillir des évènements
Il suffit d'appeller les commandes décrites ci dessous dans un appel de script et au moment où l'appel de script sera exécuté, le tressaillement aura lieu.

* `buzz 1` : fera tressaillir l'évènement 1
* `buzz 0` : fera tressaillir le héros
* `buzz 1, 7, 2, 10, 0` fera tressaillir les évènements 1, 7, 2, 10 et le héros. (com
me vous pouvez le voir, vous pouvez combiner les tressaillements).
* `buzz_followers` fera tressaillir tous les followers (dans la chenille)
* `buzz_followers 0` ne fera tressaillir que le premier des followers
* `buzz_followers 1, 2, 3` ne fera tressaillir que les followers de 1 à 3 (le premier étant le 0)

###Paramétrer le tressaillement
Il est possible de paramétrer un tressaillement par sa durée, son amplitude et sa longueur. 
*  `buzz_config(durée, amplitude, longueur).buzz 0, 1, 2` 
Vous pouvez utilisé n'importer quelle méthode énoncée ci-dessus. Je vous invite à tester des valeur pour la configuration pour adapter vos tressaillement au milimètre près. Les valeurs par défaut sont `buzz_config(16, 0.1, 16)`.

###Chainage des tressaillement
Admettons que vous ayez créer votre tressaillement personnalisé, vous pouvez chainer les tressaillements. Par exemple : 
*  `buzz_config(18, 0.1, 16).buzz_followers.buzz 0` pour faire tressaillir tous les followers et le héros de la même manère. 
* 	ou encore `buzz_config(18, 0.2, 160).buzz_followers.buzz 0, 1, 2, 3`