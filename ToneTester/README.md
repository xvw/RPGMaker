[VXAce] Testeur de teintes InGame
======================

Une fois de plus, je reprend un script de quelqu'un, qui existe déjà dans l'Event Extender. Il s'agit du script pour tester "en jeu" des teintes d'écran. Car c'est vraiment très ennuyeux de retester chaque fois le projet. Cette fois, en appuyant sur `f3` (par défaut), une petite interface graphique vous permet de tester les modifications de teintes et d'exporter la teinte dans le presse-papier, pour l'a coller, après dans n'importe quel Event.

### Installation
Cette fois, vous aurez avant tout besoin d'avoir installé le script [Mouse & Keyboard](https://github.com/nukiFW/RPGMaker/tree/master/MouseAndKeyboard). Ensuite, copiez le [script](https://github.com/nukiFW/RPGMaker/blob/master/ToneTester/script.rb) dans votre éditeur de script Au dessus de Main, dans la rubrique Materials. Vous pouvez lui attribuer un emplacement réservé. Et le nommer comme vous l'entendez. Personnellement, j'ai choisi le nom `Testeur de Teintes` (original :P !).

### Licence
Une fois de plus, ce script est entièrement libre. Vous pouvez même le supprimer quand votre jeu est fini car il n'est actif que quand le jeu est lancé depuis l'éditeur.

### Utilisation
Lorsque vous lancez votre jeu depuis l'éditeur, vous pouvez appuyez, sur une carte, sur la touche `f3` et une petite interface vous permettra de tester vos teintes. Le bouton `save` réagit au clique de la souris. Si vous cliquez dessus, la teinte que vous testez sera placée dans le presse-papier et en fermant votre jeu, vous pourrez l'a coller dans un évènement. Pour quitter cette interface, il suffit d'appuyer sur `esc` ou `f3`.

#### Changer la touche de lancement
Au début du script vous pouvez changer la touche de lancement du testeur de teintes avec toutes celles proposées dans le script de gestion de souris/clavier.
