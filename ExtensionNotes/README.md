[VXAce] Extension des notes (BDD)
=======================

Premièrement, ce script est une *amélioration* du script [Typed Entities](https://github.com/Funkywork/Scripts-rm/blob/master/VXAce/Typed-Entity.rb)
produit par S4suk3. Je me suis inspiré de sa structure et de son code pour réaliser ma version (tout de même un peu mieux ;) ).

###Objectif

Une fois de plus, il s'agit d'un script utilitaire pour les scripteurs. En effet, il permet d'ajouter des informations dans la base de données, dans le
champ "note" et d'en extraire ces informations en conservant leur type.

###Licence
Aucune licence, vous en faites l'usage que vous voulez.

###Installation 

Copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/ExtensionNotes/script.rb) dans votre éditeur de script 
Au dessus de __Main__, dans la rubrique __Materials__. Vous pouvez lui attribuer un emplacement réservé. Et le nommer
comme vous l'entendez. Personnellement, j'ai choisi le nom `Extension des notes` (original :P !)

###Construire des tags dans les notes

Les tags s'écrivent dans les champs "notes" de la base de données. Ils permettent d'écrire des informations suplémentaires, qu'un scripteur pourra traiter dans un script qui demandera plus d'informations que ceux permis dans la Base de données (dont la structure est statique).

Il existe deux types de tags. Les simples et les complexes et il est possible d'en mettre plusieurs par note (dans la base de données) et donc 
de les cumuler. __la seule contrainte est de n'en n'avoir qu'un seul par ligne dans la boite de "note"__.

#####Tags simples
Les tags simples sont ceux qui ne doivent délivrer qu'une seule information, par exemple : 

```xml
<red>255</red>
<green>255</green>
<blue>255</blue>
```

Pour ajouter à un élément de la base de données une information sur sa couleur. A noter qu'il est aussi possible de "typer" la valeur d'un tag, par exemple, ici 
les valeurs seront typées : 

```xml
<red:int>255</red>
<green:int>255</green>
<blue:int>255</blue>
```

#####Tags complexes

Les tags complexes offrent plusieurs valeurs. Par exemple : 

```xml
<color red="255" green="255" blue="255" />
```

Ou encore avec du type : 

```xml
<color red:int="255" green:int="255" blue:int="255" />
```

#####Types autorisés

Lorsque que l'on force un type (au moyen des : après le nom du tag), les valeurs seront converties dans le bon type. En sachant que parfois, si la valeur n'a rien avoir, par exemple ce tag-ci `<test:int>ahahah</test>` transformera la valeur en 0.

Il existe plusieurs type choissable:
* `int` (ou `integer`) : pour décrire les nombres entiers
* `float` (ou `double`) : pour décrire les nombres à virgule
* `bool` (ou `boolean`) : pour décrire les booléens (`true` ou `false`)
* `string` (ou `text`) : pour décrire du texte (une chaine de caractères)

Les listes transforment les champs "1,2,3" en [1,2,3]. Le séparateur est la virgule:
* `string_list` (ou `strings`, `text_list`, `texts`) : pour décrire une liste de texte (séparé par de , )
* `int_list` (ou `ints`, `integer_list`, `integers`) : pour décrire une liste d'entiers (séparé par de , )
* `float_list` (ou `floats`) : pour décrire une liste de nombre à virgule (utilisant un . comme virgule) (séparé par de , )
* `bool_list` (ou `bools`, `boolean_list`, `booleans`) : pour décrire une liste de booleens (séparé par de , )

Si aucune indication de type n'est spécifié, le type par défaut est le type `string`.

###Récuperer la valeur des tags

Pour les instances qui possèdent l'attribut `note`, une méthode `tags` est disponnible. Pour accéder à la valeur d'un tag simple, il suffit de faire `mon_objet.tags[:keyword].value`. Par exemple, pour obtenir le champ blue dans l'exemple précédent : `mon_objet.tags[:blue].value`.

Pour un champ complexe, c'est un peu le même procédé, sauf qu'on ne doit pas utiliser la méthode value. Par exemple, pour l'exemple avec _color_ : `mon_objet[:color].blue`. Grâce au typage, les valeurs sorties sont directement typé comme il le faut (si une indication de typage a été fournie).
