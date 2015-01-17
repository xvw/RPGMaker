[VXAce] Objets Uniques
=======================

Attention, ce script est principalement réservé aux scripteurs. En effet, il ne produit pas d'effet
direct sur votre projet, mais permet d'étendre plus facilement, pour un scripteur, les possibilités
sur les objets de RPG Maker VX Ace.

Ce script a été réalisé par moi, Nuki, sur inspiration du travail de Avygeil, bien antérieur au mien ;).

###Licence
Aucune licence, vous en faites l'usage que vous voulez.

###Installation
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/ObjetsUniques/script.rb) dans votre éditeur de script 
Au dessus de __Main__, dans la rubrique __Materials__. Vous pouvez lui attribuer un emplacement réservé. Et le nommer
comme vous l'entendez. Personnellement, j'ai choisi le nom `Objets uniques` (original :P !)

###Configuration
Il est possible de choisir deux modes d'affichage des objets. Le mode classique, qui va garder l'affichage classique des 
objets, ou alors le mode "unique", qui ne va plus afficher les objets groupés, par exemple si vous avez 4 potions, il 
les affichera toutes les 4. Si vous choisissez le mode non groupé, vous pouvez choisir un nombre maximum d'objets à posséder
en fonction de tous les objets. Pour modifier ces paramètres, rendez-vous en début de script : 

```ruby
#==============================================================================
# ** Item_Config
#------------------------------------------------------------------------------
#  Configuration du script
#==============================================================================

module Item_Config
  #--------------------------------------------------------------------------
  # * Défini si les objets sont groupés ou non (dans leur affichage)
  #--------------------------------------------------------------------------
  GROUPED = false
  #--------------------------------------------------------------------------
  # * Si les objets ne sont pas groupés, le nombre d'objets maximum portables
  # (Par sac)
  #--------------------------------------------------------------------------
  MAX = 999
end
```

Où vous pouvez changer tout ça.