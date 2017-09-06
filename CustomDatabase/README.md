> Ce script est un outil qui est assez difficile à utiliser pour un néophyte. Personnellement, ce script me servira à produire plus rapidement d'autres scripts qui repose sur le stockage et la structuration de données. Cependant, il est possible pour un Event Maker de s'en sortir.

> Des grammarnahzzi comme Hiino (que j'apprécie tout plein) se moqueront de mon aurtaugraf, et bien ils n'ont qu'a pull request des corrections :v bisous mes lapinous !!

[VXAce] Base de données personnalisable
=======================

Une fois de plus je fais dans la refonte, reprenant un ancien script que j'avais déjà réalisé, m'inspirant de Grim, qui lui même 
s'était inspiré de Avygeil. Son objectif est de proposer une manière élégante d'étendre la base de données original de RPG Maker.  
Comme je l'ai (et d'autres) l'ont souvent dit, la base de données de RPG Maker possède une structure statique, on peut y ajouter des 
enregistrements (sans limite, enfin presque), mais il est impossible d'altérer sa structure. Les champs sont donc défini de manière
immuable. L'objectif de ce script est donc d'offrir une manière de représenter des données structurées (et triées). 

#### Statique et Dynamique
Contrairement aux autres scripts de Base de données étendu, celui-ci offre, en plus d'une base de données statique (qui représente toutes les 
données qui ne changent pas en cours de jeu, comme la base de données native de RPG Maker), il existe une base de données dynamique 
qui est mise à jours continuellement au fil du jeu (et qui peut représenter des inventaires, par exemple). La procédure de création de table est 
presque identique pour la base de données dynamique ou statique. 

#### Terminologie 
Pour bien comprendre le fonctionnement de ce script, voici un petit rappel terminologique (volé de la présentation d'un autre script :) )
Une table est une structure de données qui est constituée d'enregistrements (records) qui sont eux-mêmes constitués de champs (fields). Par exemple, dans la base de données standard de RPG Maker : 

![Représentation de la base de données RM](http://nukifw.github.io/images/ee5/db1.png)

En effet, avec cette base de données, il n'est possible que de rajouter des enregistrements, impossible de créer une nouvelle table ou de décorer une table de nouveaux champs.  

### Installation 

Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/CustomDatabase/script.rb) dans votre éditeur de script 
Au dessus de __Main__, dans la rubrique __Materials__. Vous pouvez lui attribuer un emplacement réservé. Et le nommer
comme vous l'entendez. Personnellement, j'ai choisi le nom `Autres Bases de données` (original :P !).  
Je vous conseil de créer un emplacement vide en dessous de ce script qui contiendra le mapping de vos bases de données.

### Création d'une table
Comme je l'ai dit précédemment, il existe deux types de tables. Les tables __statiques__ qui ne sont pas changeables en cours de jeu. En effet, elle représente des données statiques. On peut en créer de la structure que l'on désire et elle serve à représenter des données similaire à celles de la base de données classique de RPG Maker, des objets, des classes, des armes par exemple et les tables __dynamiques__ qui elles représentent des données qui changent en cours de route. Des inventaires par exemple. 

#### Créer une table (statique ou dynamique)
La procédure de création d'une table est presque identique pour les deux types :
```ruby
class Nom_de_la_table < Type::Table
	type :champ1
	type :champ2
	type :champ3
	define_primary_key :champ1
end
```
Par exemple, pour la création d'une table Quest, qui représentera des quêtes : 
```ruby
class Quest < Static::Table
	integer :id 
	string :name
	string :description
	integer :gold
	integer :exp
	define_primary_key :id
end
```
Voici une table de quête qui représente une quête selon un ID, un nom, une déscription, un gain d'or, d'expérience et dont la clé primaire est l'id.  
La clé primaire permet l'indexation des enregistrements de la table, elle est obligatoire et doit être un champ existant. Il serait possible de compresser l'écriture de cette manière : 
```ruby
class Quest < Static::Table
	define_pk integer :id 
	string :name
	string :description
	integer :gold
	integer :exp
end
```
En effet, l'ont peut appeller la fonction de définition de clé primaire directement sur un champ. Et elle possède plusieurs noms : `define_primary_key`, `define_pk` ou encore simplement `pk`.   

Pour la version dynamique de cette table, on pourrait proposer : 
```ruby
class Game_Quest < Dynamic::Table
	pk integer :quest_id
	boolean :finished
end
```
Où la clé primaire serait l'id de la Quête représenté statiquement.  
Chaque champ doit impérativement être typé pour qu'a chaque insertion, il y ait une conversion dans le bon type (si possible).

#### Survol des types possibles
Les types sont une petite coquetterie (mise en place par éthique et moral !) qui permettent plus de fiabilité dans la réalisation d'une base de données. Avant de se lancer dans la création d'une table, il est donc nécéssaire de bien réfléchir à son système de type :)

*    `integer` type qui représente les nombre entiers
     * _Autre nom_ : `int` `natural` `fixnum`

*    `float` type qui représente les nombre à virgule
     * _Autre nom_ : `double` `real` `numeric`

*    `string` type qui représente les textes
     * _Autre nom_ : `text` `raw`

*    `boolean` type qui représente les booléens (true ou false)
     * _Autre nom_ : `bool` `switch`

*    `poly` type qui une donnée RGSS quelconque (donc un affreux type qui peut prendre n'importe quel type... beurk)
     * _Autre nom_ : `polymorphic` `script` `rgss`

##### Types issu du RGSS
Les types du RGSS sont un petit peu particulier, car il stocke juste l'ID d'un élément de la base de données originales et lorsque on les appellent, ils donnent l'objet Ruby s'y réferrant. (C'est un outil pratique pour faire des relations avec la base de données de RM de manière propre)

*    `actor` type qui représente un actor (un héros)
*    `klass` type qui représente les classes de personnages
*    `item` type qui représente les objets
*    `weapon` type qui représente les armes
*    `armor` type qui représente les armures
*    `enemy` type qui représente les enemis
*    `troop` type qui représente les groupes d'ennemis
*    `state` type qui représente les états
*    `animation` type qui représente les animations
*    `tileset` type qui représente les tileset
*    `mapinfo` type qui représente les infos de map
*    `map` type qui représente une map

Comme dit dans l'introduction de cette section ces types permettent de faciliter l'accès à des données statique de RPG Maker. Ils ne peuvent pas être utilisés comme des clés primaires.

##### Le type particulier, la Liste
Il arrive parfois qu'un champ doive être une liste de données, pour ça il existe un constructeur de type qui prend une liste : 
*    `list :type, :nom` : Il est aussi possible d'imbriquer les listes (de faire des listes de listes de listes d'entiers par exemple), mais pour ceux qui ne veulent pas s'embêter avec de la déduction de type, vous n'avez qu'a utiliser l'__affreux type polymorphe__ :)

##### Un dernier exemple pour la route
```ruby
# Une table super cheloue
class Table_Louche < Static::Table
	pk integer :id
	string :name
	string :nickname
	boolean :male
	list :integer, :parents_ids
	actor :heroes
end
```

##### Connaitre le schéma d'une table
InGame, il est possible de connaitre le schéma d'une table, sans devoir aller le lire dans l'éditeur de script. En effet, il suffit de faire : `Table.schema`, où Table est le nom de la table. Par exemple, pour notre exemple précédent, il faudrait faire `Table_Louche.schema`. 

### Remplir la Base de données
Généralement, la base de données __statique__ ne se remplit que dans un script vierge en dessous du mapping (ou juste en dessous du mapping) et aucune insertion n'est effectuée (car elles ne seraient pas sauvegardées). Quand à la base de données __dynamique__, il est possible d'effectuer des sauvegarde à tout moment. Pour les deux types de table, la sémantique est identique. Il suffit de faire : 
```ruby
Ma_Table.insert(arguments séparés par des virgules)
```
Il faut obligatoirement que les insertions soient effectuées dans le même ordre que celle de la déclaration des champs dans le schéma de la base de données. Voici par exemple des enregistrement (dans la table Quest créée précédemment) qui sont valides :
```ruby

# Rappel de la classe Quest
class Quest < Static::Table
	integer :id 
	string :name
	string :description
	integer :gold
	integer :exp
	define_primary_key :id
end

# Insertion
Quest.insert(1, "Tuer les slimes", "Il faut tuer 10 slimes", 100, 200)
Quest.insert(2, "Quete du chat", "Il faut trouver le chat de mamy", 10, 20)
Quest.insert(3, "Potion magique", "Faire une potion magique", 100, 200)
```

Pour représenter des inventaires, il faut suffit de créer une table dynamique et de faire des insertion dedans au fil du jeu ;)

### Accès aux champs
>Pour cette partie, une connaissance des `tableaux`/`hash` est fortemment conseillé ;)

C'est bien mignon de pouvoir faire des insertion, mais si l'on ne peut récupérer des informations d'une table, ça ne sert pas à grand chose : 

##### Nombre d'enregistrement dans une table
Il est très facile de connaitre le nombre d'enregistrement d'une table, il suffit d'utiliser la méthode `count` sur cette table. Par exemple, pour avoir le nombre de quêtes sauvées : `Quest.count`. 

##### Accéder à un record en particulier
Pour cela, il suffit de faire : `Table[Sa clé primaire]`. Par exemple, `Quest[1]` renverra l'objet Quest `(1, "Tuer les slimes", "Il faut tuer 10 slimes", 100, 200)`. De même, pour accéder à un champ, il suffit de le faire suivre du champ. Si je veux le nom de la Quête 1, je n'ai qu'a faire `Quest[1].name`.

##### Itération sur une table
Il est possible d'effectuer une itération sur une table, au moyen de `Table.each{|pk, record| faite ce que vous voulez ici}`, par exemple, pour afficher le nom de toutes les quêtes via leur clé primaire, il suffit de faire : 
```ruby
Quest.each do |pk, record|
	p "#{pk} -> #{record.name}"
end
```
L'itération sur une table fonctionne comme l'itération sur un Hash, ou l'index est la clé primaire du record.

##### Renvoyer tous les records
Il suffit d'utiliser `Table.all`, par exemple : `Quest.all` renvoi tous les objets quests.

### Cas particuliers dans le mode Dynamique
Comme il a été dit dans les sections précédentes, la base de données __dynamique__ permet, a contrario de la base de données __statique__ de tenir en compte les changements en cours de jeu. Il est donc possible de modifier les enregistrements. Ajouter/Supprimer/Editer des records. La procédure d'insertion est la même que pour la base de données statique. Mais elle peut être utilisée partout et sauvegarde les changements.

*    `Table.delete(Primary_key)` Supprimera de la table le record correspondant à la clée primaire passée en argument.
*    `Table.delete_if{|pk, record| prédicat}` Supprimera de la table tous les records correspondant au prédicat passé en argument.

Par exemple, pour supprimer toutes les quêtes (`Game_Quest` cette fois) dont l'or rapporté est superieur à 10 :  
`Game_Quest.delete_if{|pk, rec| Quest[rec.quest_id].gold > 10}` (Il s'agit d'une requête composée qui va interroger la table statique `Quest`).

Pour la modification des champs, il suffit d'accèder au champ et d'en modifier la valeur. Démonstration : 

`Game_Quest[10].finished = true`, la quête dynamique dont l'ID est 10 aura l'attribut `finished` mis à `true`. Rien de bien compliqué.

###Mapping de la base de données standard
Histoire de faire profiter de la très agréable syntaxe du système de base de données à toutes les données RM, le script construit des tables (statiques) référentes à la base de données standard de RPG Maker. Elles sont préfixées de `VXACE_` et leur nom est en majuscule : 

*    `VXACE_ACTOR`
*    `VXACE_CLASS`
*    `VXACE_SKILL`
*    `VXACE_ITEM`
*    `VXACE_WEAPON`
*    `VXACE_ARMOR`
*    `VXACE_ENEMY`
*    `VXACE_TROOP`
*    `VXACE_STATE`
*    `VXACE_ANIMATION`
*    `VXACE_TILESET`
*    `VXACE_MAP`

Toutes ces tables sont disponnibles et ont peut leur appliquer les mêmes fonctions qu'aux tables statiques. Pour connaitre leur champ, il suffit de se rendre dans la documentation du module `RPG` de RPG Maker VX Ace. Leur type a été inféré intelligemment et donc les données sont typées (y comprit les listes).

#### Spécification de la table VXACE_MAP
Cette table est un peu particulière car elle fusionne les informations de `MapInfo` et `Map`. Il est donc possible d'accéder aux champs des deux structures via un seul record. Par exemple, obtenir les notes d'une carte revient à faire : `VXACE_MAP[ID].note`.

### Conclusion
Ce script est assez long et peut paraitre totalement inutile pour les gens non expérimentés. Mais il permet d'offrir un moyen structuré de gerer des structures de données. Je pense que plusieurs de mes scripts reposeront sur ce dernier (par exemple, un système de quête facile à prendre en main).  
J'espère que vous y trouverez un intérêt. Bien à vous.
