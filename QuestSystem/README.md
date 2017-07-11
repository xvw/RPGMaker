[Read me in English](https://github.com/nukiFW/RPGMaker/blob/master/QuestSystem/READMEUK.md)

# Système de quêtes avancé
Il s'agit d'un script de création de quêtes qui se veut très paramétrable et flexible. Je remercie _Zangther_, _Hiino_ et _Altor_ pour leurs aides respectives. 

### Licence 
*   Libre pour toute utilisation. Idéalement créditer l'auteur, en l'occurence moi (Nuki).

### Installation
Ce script requiert l'installation de [CustomDatabase](https://github.com/nukiFW/RPGMaker/tree/master/CustomDatabase) pour fonctionner.  
Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/QuestSystem/script.rb) dans votre éditeur de script au dessus de Main, dans la rubrique Materials. Vous pouvez lui attribuer un emplacement réservé. Et le nommer comme vous l'entendez. Personnellement, j'ai choisi le nom *QuestSystem* (original :P !).
Je conseille de préparer un espace script en-dessous de ce script qui servira à insérer les quêtes (je l'ai nommé *QuestList*).

### Images des vues par défaut

#### Journal de quêtes

![Journal](https://raw.githubusercontent.com/nukiFW/RPGMaker/master/QuestSystem/journal.png)

#### Magasin de quête

![Magasin](https://raw.githubusercontent.com/nukiFW/RPGMaker/master/QuestSystem/shop.png)

### Utilisation du script

#### Création d'une quête
Comme conseillé dans la directive d'installation, il est recommandé de créer un espace libre en-dessous du script qui servira à écrire les quêtes. Lorsque je parlerai de création de quêtes, je partirai du principe que vous les décrivez dans cet espace. 

##### Syntaxe de création d'une quête
Pour créer une quête, il suffit d'ajouter ceci dans l'espace libre : 
```ruby
Quest.create(
  :id => NUMERO_DE_LA_QUETE,
  :name => "Nom de la quête", 
  :desc => "Description de la quête"
)
```
Il s'agit de la syntaxe minimale pour créer une quête. Cependant, il existe une foultitude de paramètres en plus. 

##### Paramètres complémentaires
Les paramètres complémentaires permettent de spécialiser une quête pour lui permettre par exemple, de définir les récompenses, la condition de déclenchement, ou encore le prix de la quête (car nous verrons plus tard que les quêtes peuvent être achetées).
Chaque paramètre doit être séparé par une virgule.

###### :gold
Il est possible de paramétrer la quantité d'Or que rendra la quête une fois terminée. Pour cela, il suffit d'ajouter l'option `:gold => QUANTITE_DOR_RECUE`.

###### :exp
Une quête peut aussi faire gagner de l'expérience à l'équipe une fois terminée au moyen de l'option `:exp => NOMBRE_DE_POINT_D_EXPERIENCE_RECUS`.

**Exemple de quêtes donnant de l'expérience et de l'or**
```ruby
Quest.create(
  :id => 1,
  :name => "Rencontrer Pierre", 
  :desc => "Aller parler à Pierre, au nord du Village",
  :gold => 200,
  :exp  => 120
)
```

###### :items
Comme pour l'or et l'expérience il est possible de paramétrer une liste d'objets à recevoir en cas de succès de la quête : `:items => [listes des identifiants d'objets à recevoir séparé par une virgule]`.

###### :weapons
Comme pour les objets il est possible de paramétrer une liste d'armes à recevoir en cas de succès de la quête : `:weapons => [listes des identifiants d'armes à recevoir séparé par une virgule]`.

###### :armors
Comme pour les armes il est possible de paramétrer une liste d'armures à recevoir en cas de succès de la quête : `:armors => [listes des identifiants d'armures à recevoir séparé par une virgule]`.

**Exemple de quêtes donnant de l'expérience et de l'or et des objets**
```ruby
Quest.create(
  :id => 1,
  :name => "Rencontrer Pierre", 
  :desc => "Aller parler à Pierre, au nord du Village",
  :gold => 200,
  :exp  => 120,
  :items => [1,1,2],
  :weapons => [2],
  :armors => [3]
)
```
Voici une quête qui donne en cas de réussite, 200 d'or, 120 points d'expérience à toute l'équipe, 2 fois l'objet 1, une fois l'objet 2, l'arme 2 et l'armure 3.

###### :label

Généralement, les quêtes sont référencées par leur `id`. Nous verrons plus tard comment démarrer des quêtes, ou vérifier si une quête est finie, en nous servant de leur id. Cependant, les ids étant des nombres, on peut leur attribuer un label, qui est un petit mot pour qu'elles soient plus faciles à référencer. Le label est très utile lorsqu'on a une très grande collection de quêtes à manipuler. Il s'ajoute de cette manière :
`:label => :nom_du_label`. Par défaut, le label d'une quête est `:quest_` suivi de son ID, par exemple `:quest_1`.

###### :cost

La notion de coût d'une quête intervient lorsque l'on verra les magasins de quêtes, pour qu'une quête soit accessible dans un magasin, elle doit impérativement avoir un coût, c'est le prix d'achat de la quête. Le coût s'ajoute avec `:cost => PRIX_DE_LA_QUETE`. Si une quête n'a pas de coût, elle se sera pas affichable dans un magasin malgré la possibilité que celui-ci la contienne dans son stock.

###### :repeatable

Par défaut, une quête déjà lancée (donc présente dans le journal de quêtes) ne peut être relancée. Une quête répétable sera donc, une fois terminée, supprimée du journal de quête et pourra être relancée. On ajoute cette option de cette manière : `:repeatable => true` (Ou alors `false`. Cependant, autant ne pas spécifier l'option de répétition si une quête ne doit pas l'être).

###### :need_confirmation
Cet attribut est un peu particulier. En effet, il distingue la réussite d'une quête d'avec sa complétude. Par exemple, si une quête est achetée en magasin, une fois terminée, le joueur recevra automatiquement les récompenses. Si elle doit être complétée (via l'option : `:need_confirmation => true`), le joueur devra se rendre dans un magasin qui peut vendre cette quête pour la compléter. Il est aussi possible de compléter manuellement une quête (via un appel de script que nous détaillerons plus tard).
La confirmation des quêtes permet de forcer le joueur à retourner au lieu de démarrage de la quête pour gagner ses récompenses. Dans le menu des quêtes (le journal), on distingue une quête complète d'une quête finie.

#### Conditions internes
Les conditions internes sont des éléments qui rendent la création d'un jeu plus facile. En effet, lorsque je présente un exemple de quête, "tuer 3 slimes", le souci c'est que la condition de réussite de la quête est extrêmement compliquée à représenter. Nous allons voir qu'il est possible d'automatiser le succès (ou l'échec) d'une quête dans certains contextes.

###### :success_trigger
L'option `:success_trigger => condition_de_fin_avec_succes` permet de définir une condition de succès d'une quête. Nous verrons comment concevoir des conditions de déclenchement un peu plus tard.

###### :fail_trigger
L'option `:fail_trigger => condition_de_fin_avec_echec` permet de définir une condition d'échec d'une quête.

##### Créer une condition

###### var_check(id, value)
Cette primitive permet de vérifier la valeur d'une variable. En effet, la primitive `var_check(5, 10)` sera considérée comme étant valide quand la variable 5 sera égale à 10. Il est possible de spécifier des opérateurs en 3ème argument :
*    `var_check(5, 10)` => vérifie que la variable 5 est égale à 10
*    `var_check(5, 10, :>)` => vérifie que la variable 5 est plus grande que 10
*    `var_check(5, 10, :<)` => vérifie que la variable 5 est plus petite que 10
*    `var_check(5, 10, :>=)` => vérifie que la variable 5 est plus grande ou égale à 10
*    `var_check(5, 10, :<=)` => vérifie que la variable 5 est plus petite ou égale à 10
*    `var_check(5, 10, :!=)` => vérifie que la variable 5 est différente 10

###### switch_check(id, :activated | :deactivated)
Cette primitive permet de vérifier si un interrupteur est activé ou non.
*    `switch_check(2, :activated)` => vérifie si l'interrupteur 2 est activé
*    `switch_check(2, :deactivated)` => vérifie si l'interrupteur 2 est désactivé

###### Conditions de possessions d'objets
*    `has_item(id, total)` => vérifie que le joueur possède bien l'objet référencé par `id`, au moins un certain nombre de fois (défini par `total`)
*    `has_weapon(id, total)` => vérifie que le joueur possède bien l'arme référencée par `id`, au moins un certain nombre de fois (défini par `total`)
*    `has_armor(id, total)` => vérifie que le joueur possède bien l'armure référencée par `id`, au moins un certain nombre de fois (défini par `total`)

###### monster_killed(id, total)
A partir du déclenchement de la quête, cette primitive oblige de battre un nombre de fois (défini par `total`) le monstre référencé par `id`.

###### Opérations logiques entre les primitives
Avec ces primitives, il n'est pas possible de représenter par exemple, comme condition, le meurtre de 5 slimes __ET__ la possession de l'arme 1. De même qu'il n'est pas possible de représenter la disjonction "tuer 5 slimes __OU__ posséder 5 objets de peaux de slimes". C'est pour ça que ce script permet de lier les primitives entre elles au moyen de connecteurs logiques. Soit `&` pour représenter le ET, et `|` pour représenter le OU.
Par exemple, imaginons une quête qui est réussie par la mort de 5 monstres 1 et par la possession de l'arme 1 : `:success_trigger => monster_killed(1, 5) & has_weapon(1, 1)`. De même que l'on pourrait admettre qu'une quête est réussie si la variable 10 est plus grande que 7 et si l'interrupteur 10 est activé, ou que l'arme 10 est possédée en 13 exemplaires : `:success_trigger => (var_check(10, 7, :>) & switch_check(10, :activated)) | has_weapon(10, 13)`. Il est possible de composer des motifs vraiment raffinés de quêtes pour ne pas devoir coder, en _eventmaking_, chaque embranchement d'une quête. Cependant, il est tout de même possible de terminer manuellement ces quêtes.

**Exemple de quêtes avec succès automatique**

```ruby
Quest.create(
  :id => 2,
  :name => "Le slime et la potion", 
  :desc => "Tuer deux slimes et trouver une potion",
  :gold => 100,
  :exp  => 100,
  :success_trigger => monster_killed(1, 2) & has_item(1, 1)
)
```

Cette quête se terminera une fois que le joueur aura tué deux slimes et possèdera une potion. Il ne faut pas implémenter le test, et les récompenses seront données automatiquement. Un autre exemple serait :

```ruby
Quest.create(
  :id => 2,
  :name => "Le slime et la potion", 
  :desc => "Tuer deux slimes et trouver une potion",
  :gold => 100,
  :exp  => 100,
  :success_trigger => monster_killed(1, 2) & has_item(1, 1),
  :fail_trigger => switch_check(3, :activated)
)
```
Qui échouerait si l'interrupteur 3 est activé.

###### Condition de lancement d'une quête
Il est aussi possible d'avoir une condition de déclenchement (ou d'achat, dans les magasins) de quêtes. Pour cette section, il vaut mieux avoir des connaissances en Ruby, ou se servir de l'Event Extender pour avoir des fonctionnalités plus faciles. Il s'agit de l'option : `:verify => check{condition de lancement}`. Par exemple, pour qu'une quête soit lançable seulement si le niveau du premier héros est plus grand que 3: `:verify => check{$game_actors[1].level > 3}`. (Les connecteurs logiques && et || sont utilisables, évidemment).

###### Déclenchement d'action en fin de quête
Une fois qu'une quête est finie, il est possible de lancer une action, via l'option : `:end_action => action{Liste d'actions à effectuer en fin de quête}` (L'action est déclenchée après la finition de la quête, il est donc possible de savoir, dans les actions, si la quête a été finie ou non).

#### Usage des appels de scripts
Dans cette section, tous les arguments `id` peuvent être remplacés par le label d'une quête.
*    `Quest.start(id)` : Démarre la quête référencée par son id (même si la condition de lancement n'est pas respectée)
*    `Quest.finished?(id)` : Renvoie `true` si la quête est finie, `false` sinon
*    `Quest.succeeded?(id)` : Renvoie `true` si la quête a été finie avec succès, `false` sinon
*    `Quest.failed?(id)` : Renvoie `true` si la quête a été finie avec échec, `false` sinon
*    `Quest.ongoing?(id)` : Renvoie `true` si la quête est en cours, `false` sinon
*    `Quest.finish(id)` : Finit la quête avec succès
*    `Quest.fail(id)` : Finit la quête avec échec
*    `Quest.need_confirmation?(id)` : Renvoie `true` si la quête demande une confirmation, `false` sinon
*    `Quest.confirm(id)` : Confirme une quête finie, donne la récompense
*    `Quest.launchable?(id)` : Renvoie `true` si la condition de lancement de la quête est respectée, `false` sinon
*    `SceneManager.questShop([liste_des_quetes_vendables])` : Lance un magasin de quêtes, avec un stock, la liste des quêtes passée en argument.

#### Configuration du script
En début de script, il existe un module de configuration, qui permet de changer le vocabulaire du script, mais aussi l'accès au journal des quêtes dans le menu.

#### Journal des quêtes et magasins
Le script dispose d'un journal des quêtes, basé sur le menu d'objets (respectant son architecture visuelle) et d'un magasin de quêtes, ressemblant aux magasins natifs. Je vous invite tout de même à faire votre propre script de magasin/journal, pour avoir quelque chose de très original.


Bonne utilisation !
