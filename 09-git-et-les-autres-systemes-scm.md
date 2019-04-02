# Git et les autres systèmes

<!-- toc -->

Le monde n’est pas parfait. Habituellement, vous ne pouvez pas basculer
immédiatement sous Git tous les projets que vous pourriez rencontrer.
Quelques fois, vous êtes bloqué sur un projet utilisant un autre VCS et
vous regrettez que ce ne soit pas Git. Dans la première partie de ce
chapitre, nous traiterons de la manière d’utiliser git comme client pour
les projets utilisant un autre système.

À un moment, vous voudrez convertir votre projet à Git. La seconde
partie de ce chapitre traite la migration de votre projet dans Git
depuis certains systèmes spécifiques et enfin par un script d’import
personnalisé pour les cas non-standards.

## Git comme client

Git fournit de si bonnes sensations aux développeurs que de nombreuses
personnes ont cherché à l’utiliser sur leur station de travail, même si
le reste de leur équipe utilise un VCS complètement différent. Il existe
un certain nombre d’adaptateurs appelés « passerelles ». Nous allons en
décrire certains des plus communs.

### Git et Subversion

Aujourd’hui, la majorité des projets de développement libre et un grand
nombre de projets dans les sociétés utilisent Subversion pour gérer leur
code source. Il a été le VCS libre le plus populaire depuis une bonne
décennie et a été considéré comme le choix *de facto* pour les projets
open-source. Il est aussi très similaire à CVS qui a été le grand chef
des gestionnaires de source avant lui.

Une des grandes fonctionnalités de Git est sa passerelle vers
Subversion, `git svn`. Cet outil vous permet d’utiliser Git comme un
client valide d’un serveur Subversion pour que vous puissiez utiliser
les capacités de Git en local puis pousser sur le serveur Subversion
comme si vous utilisiez Subversion localement. Cela signifie que vous
pouvez réaliser localement les embranchements et les fusions, utiliser
l’index, utiliser le rebasage et le picorage de *commits*, etc, tandis
que vos collaborateurs continuent de travailler avec leurs méthodes
ancestrales et obscures. C’est une bonne manière d’introduire Git dans
un environnement professionnel et d’aider vos collègues développeurs à
devenir plus efficaces tandis que vous ferez pression pour une
modification de l’infrastructure vers l’utilisation massive de Git. La
passerelle Subversion n’est que la première dose vers la drogue du monde
des DVCS.

#### `git svn`

La commande de base dans Git pour toutes les commandes de passerelle est
`git svn`. Vous préfixerez tout avec cette paire de mots. Les
possibilités étant nombreuses, nous traiterons des plus communes pendant
que nous détaillerons quelques petits modes de gestion.

Il est important de noter que lorsque vous utilisez `git svn`, vous
interagissez avec Subversion qui est un système fonctionnant très
différemment de Git. Bien que vous **puissiez** réaliser des branches
locales et les fusionner, il est généralement conseillé de conserver
votre historique le plus linéaire possible en rebasant votre travail et
en évitant des activités telles qu’interagir dans le même temps avec un
dépôt Git distant.

Ne réécrivez pas votre historique avant d’essayer de pousser à nouveau
et ne poussez pas en parallèle dans un dépôt Git pour collaborer avec
vos collègues développant avec Git. Subversion ne supporte qu’un
historique linéaire et il est très facile de l’égarer. Si vous
travaillez avec une équipe dont certains membres utilisent SVN et
d’autres utilisent Git, assurez-vous que tout le monde n’utilise que le
serveur SVN pour collaborer, cela vous rendra service.

#### Installation

Pour montrer cette fonctionnalité, il faut un serveur SVN sur lequel
vous avez des droits en écriture. Pour copier ces exemples, vous avez
besoin de faire une copie inscriptible d’un dépôt SVN de test
accessible. Dans cette optique, vous pouvez utiliser un outil appelé
`svnsync` qui est livré avec les versions les plus récentes de
Subversion — il devrait être distribué avec les versions à partir de
1.4.

En préparation, créez un nouveau dépôt local Subversion :

``` highlight
$ mkdir /tmp/test-svn
$ svnadmin create /tmp/test-svn
```

Ensuite, autorisez tous les utilisateurs à changer les revprops — le
moyen le plus simple consiste à ajouter un script `pre-revprop-change`
qui renvoie toujours 0 :

``` highlight
$ cat /tmp/test-svn/hooks/pre-revprop-change
#!/bin/sh
exit 0;
$ chmod +x /tmp/test-svn/hooks/pre-revprop-change
```

Vous pouvez à présent synchroniser ce projet sur votre machine locale en
lançant `svnsync init` avec les dépôts source et cible.

``` highlight
$ svnsync init file:///tmp/test-svn http://votre-serveur-svn.org/svn/
```

Cela initialise les propriétés nécessaires à la synchronisation. Vous
pouvez ensuite cloner le code en lançant :

``` highlight
$ svnsync sync file:///tmp/test-svn
Committed revision 1.
Copied properties for revision 1.
Transmitting file data .............................[...]
Committed revision 2.
Copied properties for revision 2.
[…]
```

Bien que cette opération ne dure que quelques minutes, si vous essayez
de copier le dépôt original sur un autre dépôt distant au lieu d’un
dépôt local, le processus durera près d’une heure, en dépit du fait
qu’il y a moins de 100 *commits*. Subversion doit cloner révision par
révision puis pousser vers un autre dépôt — c’est ridiculement
inefficace mais c’est la seule possibilité.

#### Démarrage

Avec des droits en écriture sur un dépôt Subversion, vous voici prêt à
expérimenter une méthode typique. Commençons par la commande
`git svn clone` qui importe un dépôt Subversion complet dans un dépôt
Git local. Souvenez-vous que si vous importez depuis un dépôt Subversion
hébergé sur Internet, il faut remplacer l’URL `file://tmp/test-svn`
ci-dessous par l’URL de votre dépôt Subversion :

``` highlight
$ git svn clone file:///tmp/test-svn -T trunk -b branches -t tags
Initialized empty Git repository in /private/tmp/progit/test-svn/.git/
r1 = dcbfb5891860124cc2e8cc616cded42624897125 (refs/remotes/origin/trunk)
    A   m4/acx_pthread.m4
    A   m4/stl_hash.m4
    A   java/src/test/java/com/google/protobuf/UnknownFieldSetTest.java
    A   java/src/test/java/com/google/protobuf/WireFormatTest.java
…
r75 = 556a3e1e7ad1fde0a32823fc7e4d046bcfd86dae (refs/remotes/origin/trunk)
Found possible branch point: file:///tmp/test-svn/trunk => file:///tmp/test-svn/branches/my-calc-branch, 75
Found branch parent: (refs/remotes/origin/my-calc-branch) 556a3e1e7ad1fde0a32823fc7e4d046bcfd86dae
Following parent with do_switch
Successfully followed parent
r76 = 0fb585761df569eaecd8146c71e58d70147460a2 (refs/remotes/origin/my-calc-branch)
Checked out HEAD:
  file:///tmp/test-svn/trunk r75
```

Cela équivaut à lancer `git svn init` suivi de `git svn fetch` sur l’URL
que vous avez fournie. Cela peut prendre un certain temps. Le projet de
test ne contient que 75 *commits* et la taille du code n’est pas
extraordinaire, ce qui prend juste quelques minutes. Cependant, Git doit
extraire chaque version, une par une et les valider individuellement.
Pour un projet contenant des centaines ou des milliers de *commits*,
cela peut prendre littéralement des heures ou même des jours à terminer.

La partie `-T trunk -b branches -t tags` indique à Git que ce dépôt
Subversion suit les conventions de base en matière d’embranchement et
d’étiquetage. Si vous nommez votre trunk, vos branches ou vos étiquettes
différemment, vous pouvez modifier ces options. Comme cette organisation
est la plus commune, ces options peuvent être simplement remplacées par
`-s` qui signifie structure standard. La commande suivante est
équivalente :

``` highlight
$ git svn clone file:///tmp/test-svn -s
```

À présent, vous disposez d’un dépôt Git valide qui a importé vos
branches et vos étiquettes :

``` highlight
$ git branch -a
* master
  remotes/origin/my-calc-branch
  remotes/origin/tags/2.0.2
  remotes/origin/tags/release-2.0.1
  remotes/origin/tags/release-2.0.2
  remotes/origin/tags/release-2.0.2rc1
  remotes/origin/trunk
```

Il est important de remarquer comment cet outil sous-classe vos
références distantes différemment. Voyons de plus près avec la commande
Git de plomberie `show-ref` :

``` highlight
$ git show-ref
556a3e1e7ad1fde0a32823fc7e4d046bcfd86dae refs/heads/master
0fb585761df569eaecd8146c71e58d70147460a2 refs/remotes/origin/my-calc-branch
bfd2d79303166789fc73af4046651a4b35c12f0b refs/remotes/origin/tags/2.0.2
285c2b2e36e467dd4d91c8e3c0c0e1750b3fe8ca refs/remotes/origin/tags/release-2.0.1
cbda99cb45d9abcb9793db1d4f70ae562a969f1e refs/remotes/origin/tags/release-2.0.2
a9f074aa89e826d6f9d30808ce5ae3ffe711feda refs/remotes/origin/tags/release-2.0.2rc1
556a3e1e7ad1fde0a32823fc7e4d046bcfd86dae refs/remotes/origin/trunk
```

Git ne fait pas cela quand il clone depuis un serveur Git ; voici à quoi
ressemble un dépôt avec des étiquettes juste après le clonage :

``` highlight
$ git show-ref
c3dcbe8488c6240392e8a5d7553bbffcb0f94ef0 refs/remotes/origin/master
32ef1d1c7cc8c603ab78416262cc421b80a8c2df refs/remotes/origin/branch-1
75f703a3580a9b81ead89fe1138e6da858c5ba18 refs/remotes/origin/branch-2
23f8588dde934e8f33c263c6d8359b2ae095f863 refs/tags/v0.1.0
7064938bd5e7ef47bfd79a685a62c1e2649e2ce7 refs/tags/v0.2.0
6dcb09b5b57875f334f61aebed695e2e4193db5e refs/tags/v1.0.0
```

Git entrepose les étiquettes directement dans `refs/tags`, plutôt que de
les traiter comme des branches distantes.

#### Valider en retour sur le serveur Subversion

Comme vous disposez d’un dépôt en état de marche, vous pouvez commencer
à travailler sur le projet et pousser vos *commits* en utilisant
efficacement Git comme client SVN. Si vous éditez un des fichiers et le
validez, vous créez un *commit* qui existe localement dans Git mais qui
n’existe pas sur le serveur Subversion :

``` highlight
$ git commit -am 'Adding git-svn instructions to the README'
[master 4af61fd] Adding git-svn instructions to the README
 1 file changed, 5 insertions(+)
```

Ensuite, vous avez besoin de pousser vos modifications en amont.
Remarquez que cela modifie la manière de travailler par rapport à
Subversion — vous pouvez réaliser plusieurs validations en mode
déconnecté pour ensuite les pousser toutes en une fois sur le serveur
Subversion. Pour pousser sur un serveur Subversion, il faut lancer la
commande `git svn dcommit` :

``` highlight
$ git svn dcommit
Committing to file:///tmp/test-svn/trunk ...
    M   README.txt
Committed r77
    M   README.txt
r77 = 95e0222ba6399739834380eb10afcd73e0670bc5 (refs/remotes/origin/trunk)
No changes between 4af61fd05045e07598c553167e0f31c84fd6ffe1 and refs/remotes/origin/trunk
Resetting to the latest refs/remotes/origin/trunk
```

Cette commande rassemble tous les *commits* que vous avez validés
par-dessus le code du serveur Subversion et réalise un *commit* sur le
serveur pour chacun, puis réécrit l’historique Git local pour y ajouter
un identifiant unique. Cette étape est à souligner car elle signifie que
toutes les sommes de contrôle SHA-1 de vos *commits* locaux ont changé.
C’est en partie pour cette raison que c’est une idée très périlleuse de
vouloir travailler dans le même temps avec des serveurs Git distants.
L’examen du dernier *commit* montre que le nouveau `git-svn-id` a été
ajouté :

``` highlight
$ git log -1
commit 95e0222ba6399739834380eb10afcd73e0670bc5
Author: ben <ben@0b684db3-b064-4277-89d1-21af03df0a68>
Date:   Thu Jul 24 03:08:36 2014 +0000

    Adding git-svn instructions to the README

    git-svn-id: file:///tmp/test-svn/trunk@77 0b684db3-b064-4277-89d1-21af03df0a68
```

Remarquez que la somme de contrôle SHA qui commençait par `4af61fd`
quand vous avez validé commence à présent par `95e0222`. Si vous
souhaitez pousser à la fois sur un serveur Git et un serveur Subversion,
il faut obligatoirement pousser (`dcommit`) sur le serveur Subversion en
premier, car cette action va modifier vos données des *commits*.

#### Tirer des modifications

Quand vous travaillez avec d’autres développeurs, il arrive à certains
moments que ce qu’un développeur a poussé provoque un conflit lorsqu’un
autre voudra pousser à son tour. Cette modification sera rejetée jusqu’à
ce qu’elle soit fusionnée. Dans `git svn`, cela ressemble à ceci :

``` highlight
$ git svn dcommit
Committing to file:///tmp/test-svn/trunk ...

ERROR from SVN:
Transaction is out of date: File '/trunk/README.txt' is out of date
W: d5837c4b461b7c0e018b49d12398769d2bfc240a and refs/remotes/origin/trunk differ, using rebase:
:100644 100644 f414c433af0fd6734428cf9d2a9fd8ba00ada145 c80b6127dd04f5fcda218730ddf3a2da4eb39138 M  README.txt
Current branch master is up to date.
ERROR: Not all changes have been committed into SVN, however the committed
ones (if any) seem to be successfully integrated into the working tree.
Please see the above messages for details.
```

Pour résoudre cette situation, vous pouvez lancer la commande
`git svn rebase` qui tire depuis le serveur toute modification apparue
entre temps et rebase votre travail sur le sommet de l’historique du
serveur :

``` highlight
$ git svn rebase
Committing to file:///tmp/test-svn/trunk ...

ERROR from SVN:
Transaction is out of date: File '/trunk/README.txt' is out of date
W: eaa029d99f87c5c822c5c29039d19111ff32ef46 and refs/remotes/origin/trunk differ, using rebase:
:100644 100644 65536c6e30d263495c17d781962cfff12422693a b34372b25ccf4945fe5658fa381b075045e7702a M  README.txt
First, rewinding head to replay your work on top of it...
Applying: update foo
Using index info to reconstruct a base tree...
M   README.txt
Falling back to patching base and 3-way merge...
Auto-merging README.txt
ERROR: Not all changes have been committed into SVN, however the committed
ones (if any) seem to be successfully integrated into the working tree.
Please see the above messages for details.
```

À présent, tout votre travail se trouve au-delà de l’historique du
serveur et vous pouvez effectivement réaliser un `dcommit` :

``` highlight
$ git svn dcommit
Committing to file:///tmp/test-svn/trunk ...
    M   README.txt
Committed r85
    M   README.txt
r85 = 9c29704cc0bbbed7bd58160cfb66cb9191835cd8 (refs/remotes/origin/trunk)
No changes between 5762f56732a958d6cfda681b661d2a239cc53ef5 and refs/remotes/origin/trunk
Resetting to the latest refs/remotes/origin/trunk
```

Il est important de se souvenir qu’à la différence de Git qui requiert
une fusion avec les modifications distantes non présentes localement
avant de pouvoir pousser, `git svn` ne vous y contraint que si vos
modifications provoquent un conflit (de la même manière que `svn`). Si
une autre personne pousse une modification à un fichier et que vous
poussez une modification à un autre fichier, votre `dcommit` passera
sans problème :

``` highlight
$ git svn dcommit
Committing to file:///tmp/test-svn/trunk ...
    M   configure.ac
Committed r87
    M   autogen.sh
r86 = d8450bab8a77228a644b7dc0e95977ffc61adff7 (refs/remotes/origin/trunk)
    M   configure.ac
r87 = f3653ea40cb4e26b6281cec102e35dcba1fe17c4 (refs/remotes/origin/trunk)
W: a0253d06732169107aa020390d9fefd2b1d92806 and refs/remotes/origin/trunk differ, using rebase:
:100755 100755 efa5a59965fbbb5b2b0a12890f1b351bb5493c18 e757b59a9439312d80d5d43bb65d4a7d0389ed6d M  autogen.sh
First, rewinding head to replay your work on top of it...
```

Il faut s’en souvenir car le résultat de ces actions est un état du
dépôt qui n’existait pas sur aucun des ordinateurs quand vous avez
poussé. Si les modifications sont incompatibles mais ne créent pas de
conflits, vous pouvez créer des défauts qui seront très difficiles à
diagnostiquer. C’est une grande différence avec un serveur Git — dans
Git, vous pouvez tester complètement l’état du projet sur votre système
client avant de le publier, tandis qu’avec SVN, vous ne pouvez jamais
être totalement certain que les états avant et après validation sont
identiques.

Vous devrez aussi lancer cette commande pour tirer les modifications
depuis le serveur Subversion, même si vous n’êtes pas encore prêt à
valider. Vous pouvez lancer `git svn fetch` pour tirer les nouveaux
*commits*, mais `git svn rebase` tire non seulement les *commits*
distants mais rebase aussi vos *commits* locaux.

``` highlight
$ git svn rebase
    M   autogen.sh
r88 = c9c5f83c64bd755368784b444bc7a0216cc1e17b (refs/remotes/origin/trunk)
First, rewinding head to replay your work on top of it...
Fast-forwarded master to refs/remotes/origin/trunk.
```

Lancer `git svn rebase` de temps en temps vous assure que votre travail
est toujours synchronisé avec le serveur. Vous devrez cependant vous
assurer que votre copie de travail est propre quand vous la lancez. Si
vous avez des modifications locales, il vous faudra soit remiser votre
travail, soit valider temporairement vos modifications avant de lancer
`git svn rebase`, sinon la commande s’arrêtera si elle détecte que le
rebasage provoquerait un conflit de fusion.

#### Le problème avec les branches Git

Après vous être habitué à la manière de faire avec Git, vous souhaiterez
sûrement créer des branches thématiques, travailler dessus, puis les
fusionner. Si vous poussez sur un serveur Subversion via `git svn`, vous
souhaiterez à chaque fois rebaser votre travail sur une branche unique
au lieu de fusionner les branches ensemble. La raison principale en est
que Subversion gère un historique linéaire et ne gère pas les fusions
comme Git y excelle. De ce fait, `git svn` suit seulement le premier
parent lorsqu’il convertit les instantanés en *commits* Subversion.

Supposons que votre historique ressemble à ce qui suit. Vous avez créé
une branche `experience`, avez réalisé deux validations puis les avez
fusionnées dans `master`. Lors du `dcommit`, vous voyez le résultat
suivant :

``` highlight
$ git svn dcommit
Committing to file:///tmp/test-svn/trunk ...
    M   CHANGES.txt
Committed r89
    M   CHANGES.txt
r89 = 89d492c884ea7c834353563d5d913c6adf933981 (refs/remotes/origin/trunk)
    M   COPYING.txt
    M   INSTALL.txt
Committed r90
    M   INSTALL.txt
    M   COPYING.txt
r90 = cb522197870e61467473391799148f6721bcf9a0 (refs/remotes/origin/trunk)
No changes between 71af502c214ba13123992338569f4669877f55fd and refs/remotes/origin/trunk
Resetting to the latest refs/remotes/origin/trunk
```

Lancer `dcommit` sur une branche avec un historique fusionné fonctionne
correctement, à l’exception que l’examen de l’historique du projet Git
indique qu’il n’a réécrit aucun des *commits* réalisés sur la branche
`experience`, mais que toutes les modifications introduites apparaissent
dans la version SVN de l’unique *commit* de fusion.

Quand quelqu’un d’autre clone ce travail, tout ce qu’il voit, c’est le
*commit* de la fusion avec toutes les modifications injectées en une
fois, comme si vous aviez lancé `git merge --squash`. Il ne voit aucune
information sur son origine ni sur sa date de validation.

#### Les embranchements dans Subversion

La gestion de branches dans Subversion n’a rien à voir avec celle de
Git. Évitez de l’utiliser autant que possible. Cependant vous pouvez
créer des branches et valider dessus dans Subversion en utilisant
`git svn`.

#### Créer une nouvelle branche SVN

Pour créer une nouvelle branche dans Subversion, vous pouvez utiliser la
commande `git svn branch [nom de la branche]` :

``` highlight
$ git svn branch opera
Copying file:///tmp/test-svn/trunk at r90 to file:///tmp/test-svn/branches/opera...
Found possible branch point: file:///tmp/test-svn/trunk => file:///tmp/test-svn/branches/opera, 90
Found branch parent: (refs/remotes/origin/opera) cb522197870e61467473391799148f6721bcf9a0
Following parent with do_switch
Successfully followed parent
r91 = f1b64a3855d3c8dd84ee0ef10fa89d27f1584302 (refs/remotes/origin/opera)
```

Cela est équivalent à la commande Subversion
`svn copy trunk branches/opera` et réalise l’opération sur le serveur
Subversion. Remarquez que cette commande ne vous bascule pas sur cette
branche ; si vous validez, le *commit* s’appliquera à `trunk` et non à
la branche `opera`.

#### Basculer de branche active

Git devine la branche cible des `dcommits` en se référant au sommet des
branches Subversion dans votre historique — vous ne devriez en avoir
qu’un et celui-ci devrait être le dernier possédant un `git-svn-id` dans
l’historique actuel de votre branche.

Si vous souhaitez travailler simultanément sur plusieurs branches, vous
pouvez régler vos branches locales pour que le `dcommit` arrive sur une
branche Subversion spécifique en les démarrant sur le *commit* de cette
branche importée depuis Subversion. Si vous voulez une branche `opera`
sur laquelle travailler séparément, vous pouvez lancer :

``` highlight
$ git branch opera remotes/origin/opera
```

À présent, si vous voulez fusionner votre branche `opera` dans `trunk`
(votre branche `master`), vous pouvez le faire en réalisant un
`git merge` normal. Mais vous devez préciser un message de validation
descriptif (via `-m`), ou la fusion indiquera simplement « Merge branch
opera » au lieu d’un message plus informatif.

Souvenez-vous que bien que vous utilisez `git merge` qui facilitera
l’opération de fusion par rapport à Subversion (Git détectera
automatiquement l’ancêtre commun pour la fusion), ce n’est pas un
*commit* de fusion normal de Git. Vous devrez pousser ces données
finalement sur le serveur Subversion qui ne sait pas tracer les
*commits* possédant plusieurs parents. Donc, ce sera un *commit* unique
qui englobera toutes les modifications de l’autre branche. Après avoir
fusionné une branche dans une autre, il est difficile de continuer à
travailler sur cette branche, comme vous le feriez normalement dans Git.
La commande `dcommit` qui a été lancée efface toute information sur la
branche qui a été fusionnée, ce qui rend faux tout calcul d’antériorité
pour la fusion. `dcommit` fait ressembler le résultat de `git merge` à
celui de `git merge --squash`. Malheureusement, il n’y a pas de moyen
efficace de remédier à ce problème — Subversion ne stocke pas cette
information et vous serez toujours contraints par ses limitations si
vous l’utilisez comme serveur. Pour éviter ces problèmes, le mieux reste
d’effacer la branche locale (dans notre cas, `opera`) dès qu’elle a été
fusionnée dans `trunk`.

#### Commandes Subversion

La boîte à outil `git svn` fournit des commandes de nature à faciliter
la transition vers Git en mimant certaines commandes disponibles avec
Subversion. Voici quelques commandes qui vous fournissent les mêmes
services que Subversion.

##### L’historique dans le style Subversion

Si vous êtes habitué à Subversion, vous pouvez lancer `git svn log` pour
visualiser votre historique dans un format SVN :

``` highlight
$ git svn log
------------------------------------------------------------------------
r87 | schacon | 2014-05-02 16:07:37 -0700 (Sat, 02 May 2014) | 2 lines

autogen change

------------------------------------------------------------------------
r86 | schacon | 2014-05-02 16:00:21 -0700 (Sat, 02 May 2014) | 2 lines

Merge branch 'experiment'

------------------------------------------------------------------------
r85 | schacon | 2014-05-02 16:00:09 -0700 (Sat, 02 May 2014) | 2 lines

updated the changelog
```

Deux choses importantes à connaître sur `git svn log`. Premièrement, à
la différence de la véritable commande `svn log` qui interroge le
serveur, cette commande fonctionne hors connexion. Deuxièmement, elle ne
montre que les *commits* qui ont été effectivement remontés sur le
serveur Subversion. Les *commits* locaux qui n’ont pas encore été
remontés via `dcommit` n’apparaissent pas, pas plus que ceux qui
auraient été poussés sur le serveur par des tiers entre-temps. Cela
donne plutôt le dernier état connu des *commits* sur le serveur
Subversion.

##### Annotations SVN

De la même manière que `git svn log` simule une commande `svn log`
déconnectée, vous pouvez obtenir l’équivalent de `svn annotate` en
lançant `git svn blame [fichier]`. Le résultat ressemble à ceci :

``` highlight
$ git svn blame README.txt
 2   temporal Protocol Buffers - Google's data interchange format
 2   temporal Copyright 2008 Google Inc.
 2   temporal http://code.google.com/apis/protocolbuffers/
 2   temporal
22   temporal C++ Installation - Unix
22   temporal =======================
 2   temporal
79    schacon Committing in git-svn.
78    schacon
 2   temporal To build and install the C++ Protocol Buffer runtime and the Protocol
 2   temporal Buffer compiler (protoc) execute the following:
 2   temporal
```

Ici aussi, tous les *commits* locaux dans Git ou ceux poussés sur
Subversion dans l’intervalle n’apparaissent pas.

##### Information sur le serveur SVN

Vous pouvez aussi obtenir le même genre d’information que celle fournie
par `svn info` en lançant `git svn info` :

``` highlight
$ git svn info
Path: .
URL: https://schacon-test.googlecode.com/svn/trunk
Repository Root: https://schacon-test.googlecode.com/svn
Repository UUID: 4c93b258-373f-11de-be05-5f7a86268029
Revision: 87
Node Kind: directory
Schedule: normal
Last Changed Author: schacon
Last Changed Rev: 87
Last Changed Date: 2009-05-02 16:07:37 -0700 (Sat, 02 May 2009)
```

Comme `blame` et `log`, cette commande travaille hors connexion et n’est
à jour qu’à la dernière date à laquelle vous avez communiqué avec le
serveur Subversion.

##### Ignorer ce que Subversion ignore

Si vous clonez un dépôt Subversion contenant des propriétés
`svn:ignore`, vous souhaiterez sûrement paramétrer les fichiers
`.gitignore` en correspondance pour vous éviter de valider
accidentellement des fichiers qui ne devraient pas l’être. `git svn`
dispose de deux commandes pour le faire.

La première est `git svn create-ignore` qui crée automatiquement pour
vous les fichiers `.gitignore` prêts pour l’inclusion dans votre
prochaine validation.

La seconde commande est `git svn show-ignore` qui affiche sur `stdout`
les lignes nécessaires à un fichier `.gitignore` qu’il suffira de
rediriger dans votre fichier d’exclusion de projet :

``` highlight
$ git svn show-ignore > .git/info/exclude
```

De cette manière, vous ne parsemez pas le projet de fichiers
`.gitignore`. C’est une option optimale si vous êtes le seul utilisateur
de Git dans une équipe Subversion et que vos coéquipiers ne veulent pas
voir de fichiers `.gitignore` dans le projet.

#### Résumé sur Git-Svn

Les outils `git svn` sont utiles si vous êtes bloqué avec un serveur
Subversion pour le moment ou si vous devez travailler dans un
environnement de développement qui nécessite un serveur Subversion. Il
faut cependant les considérer comme une version estropiée de Git ou vous
pourriez rencontrer des problèmes de conversion qui vous embrouilleront
vous et vos collaborateurs. Pour éviter tout problème, essayez de suivre
les principes suivants :

-   Gardez un historique Git linéaire qui ne contient pas de *commits*
    de fusion issus de `git merge`.

-   Rebasez tout travail réalisé en dehors de la branche principale sur
    celle-ci ; ne la fusionnez pas.

-   Ne mettez pas en place et ne travaillez pas en parallèle sur un
    serveur Git. Si nécessaire, montez-en un pour accélérer les clones
    pour de nouveaux développeurs mais n’y poussez rien qui n’ait déjà
    une entrée `git-svn-id`. Vous devriez même y ajouter un crochet
    `pre-receive` qui vérifie la présence de `git-svn-id` dans chaque
    message de validation et rejette les remontées dont un des *commits*
    n’en contiendrait pas.

Si vous suivez ces principes, le travail avec un serveur Subversion peut
être supportable. Cependant, si le basculement sur un vrai serveur Git
est possible, votre équipe y gagnera beaucoup.

### Git et Mercurial

L’univers des systèmes de gestion de version distribués ne se limite pas
à Git. En fait, il existe de nombreux autres systèmes, chacun avec sa
propre approche sur la gestion distribuée des versions. À part Git, le
plus populaire est Mercurial, et ces deux-ci sont très ressemblants par
de nombreux aspects.

La bonne nouvelle si vous préférez le comportement de Git côté client
mais que vous devez travailler sur un projet géré sous Mercurial, c’est
que l’on peut utiliser Git avec un dépôt géré sous Mercurial. Du fait
que Git parle avec les dépôts distants au moyen de greffons de protocole
distant, il n’est pas surprenant que cette passerelle prenne la forme
d’un greffon de protocole distant. Le projet s’appelle git-remote-hg et
peut être trouvé à l’adresse
<a href="https://github.com/felipec/git-remote-hg" class="bare">https://github.com/felipec/git-remote-hg</a>.

#### git-remote-hg

Premièrement, vous devez installer git-remote-hg. Cela revient
simplement à copier ce fichier quelque part dans votre chemin de
recherche, comme ceci :

``` highlight
$ curl -o ~/bin/git-remote-hg \
  https://raw.githubusercontent.com/felipec/git-remote-hg/master/git-remote-hg
$ chmod +x ~/bin/git-remote-hg
```

…en supposant que `~/bin` est présent dans votre `$PATH`. git-remote-hg
est aussi dépendant de la bibliothèque `Mercurial` pour Python. Si
Python est déjà installé, c’est aussi simple que :

``` highlight
$ pip install mercurial
```

Si Python n’est pas déjà installé, visitez
<a href="https://www.python.org/" class="bare">https://www.python.org/</a>
et récupérez-le.

La dernière dépendance est le client Mercurial. Rendez-vous sur
<a href="https://www.mercurial-scm.org/" class="bare">https://www.mercurial-scm.org/</a>
et installez-le si ce n’est pas déjà fait.

Maintenant, vous voilà prêt. Vous n’avez besoin que d’un dépôt Mercurial
où pousser. Heureusement, tous les dépôts Mercurial peuvent servir et
nous allons donc simplement utiliser le dépôt "hello world" dont tout le
monde se sert pour apprendre Mercurial :

``` highlight
$ hg clone http://selenic.com/repo/hello /tmp/hello
```

#### Démarrage

Avec un dépôt « côté serveur » maintenant disponible, détaillons un flux
de travail typique. Comme vous le verrez, ces deux systèmes sont
suffisamment similaires pour qu’il y ait peu de friction.

Comme toujours avec Git, commençons par cloner :

``` highlight
$ git clone hg::/tmp/hello /tmp/hello-git
$ cd /tmp/hello-git
$ git log --oneline --graph --decorate
* ac7955c (HEAD, origin/master, origin/branches/default, origin/HEAD, refs/hg/origin/branches/default, refs/hg/origin/bookmarks/master, master) Create a makefile
* 65bb417 Create a standard "hello, world" program
```

Notez bien que pour travailler avec un dépôt Mercurial, on utilise la
commande standard `git clone`. C’est dû au fait que git-remote-hg
travaille à un niveau assez bas, en utilisant un mécanisme similaire à
celui du protocole HTTP/S de Git. Comme Git et Mercurial sont tous les
deux organisés pour que chaque client récupère une copie complète de
l’historique du dépôt, cette commande réalise rapidement un clone
complet, incluant tout l’historique du projet.

La commande log montre deux *commits*, dont le dernier est pointé par
une ribambelle de refs. En fait, certaines d’entre elles n’existent par
vraiment. Jetons un œil à ce qui est réellement présent dans le
répertoire `.git` :

``` highlight
$ tree .git/refs
.git/refs
├── heads
│   └── master
├── hg
│   └── origin
│       ├── bookmarks
│       │   └── master
│       └── branches
│           └── default
├── notes
│   └── hg
├── remotes
│   └── origin
│       └── HEAD
└── tags

9 directories, 5 files
```

Git-remote-hg essaie de rendre les choses plus idiomatiquement
Git-esques, mais sous le capot, il gère la correspondance conceptuelle
entre deux systèmes légèrement différents. Par exemple, le fichier
`refs/hg/origin/branches/default` est un fichier Git de références, qui
contient le SHA-1 commençant par « ac7955c », qui est le *commit* pointé
par `master`. Donc le répertoire `refs/hg` est en quelque sorte un faux
`refs/remotes/origin`, mais il contient la distinction entre les
marque-pages et les branches.

Le fichier `notes/hg` est le point de départ pour comprendre comment
git-remote-hg fait correspondre les empreintes des *commits* Git avec
les IDs de modification de Mercurial. Explorons-le un peu :

``` highlight
$ cat notes/hg
d4c10386...

$ git cat-file -p d4c10386...
tree 1781c96...
author remote-hg <> 1408066400 -0800
committer remote-hg <> 1408066400 -0800

Notes for master

$ git ls-tree 1781c96...
100644 blob ac9117f...  65bb417...
100644 blob 485e178...  ac7955c...

$ git cat-file -p ac9117f
0a04b987be5ae354b710cefeba0e2d9de7ad41a9
```

Donc, `refs/notes/hg` pointe sur un arbre qui correspond dans la base de
données des objets de Git à une liste des autres objets avec des noms.
`git-ls-tree` affiche le mode, le type, l’empreinte de l’objet et le nom
de fichier des articles d’un arbre. Quand nous creusons un de ces
articles, nous trouvons à l’intérieur un blob appelé « ac9117f »
(l’empreinte SHA-1 du *commit* pointé par `master`), avec le contenu
« 0a04b98 » (qui est l’ID de la modification Mercurial au sommet de la
branche `default`).

La bonne nouvelle est que nous n’avons quasiment pas à nous soucier de
tout ceci. Le mode de travail ne sera pas très différent de celui avec
un serveur distant Git.

Il reste une chose à gérer avant de passer à la suite : les fichiers
`ignore`. Mercurial et Git utilisent un mécanisme très similaire pour
cette fonctionnalité, mais il est très probable que vous ne souhaitez
pas valider un fichier `.gitignore` dans un dépôt Mercurial.
Heureusement, Git dispose d’un moyen d’ignorer les fichiers d’un dépôt
local et le format Mercurial est compatible avec Git. Il suffit donc de
le copier :

``` highlight
$ cp .hgignore .git/info/exclude
```

Le fichier `.git/info/exclude` se comporte simplement comme un fichier
`.gitignore`, mais n’est pas inclus dans les *commits*.

#### Déroulement

Supposons que nous avons travaillé et validé quelques *commits* sur la
branche `master` et que nous sommes prêts à pousser ce travail sur un
dépôt distant. Notre dépôt ressemble actuellement à ceci :

``` highlight
$ git log --oneline --graph --decorate
* ba04a2a (HEAD, master) Update makefile
* d25d16f Goodbye
* ac7955c (origin/master, origin/branches/default, origin/HEAD, refs/hg/origin/branches/default, refs/hg/origin/bookmarks/master) Create a makefile
* 65bb417 Create a standard "hello, world" program
```

Notre branche `master` est en avance de deux *commits* par rapport à
`origin/master`, mais ces deux *commits* n’existent que sur notre
machine locale. Voyons si quelqu’un d’autre a poussé son travail dans le
même temps :

``` highlight
$ git fetch
From hg::/tmp/hello
   ac7955c..df85e87  master     -> origin/master
   ac7955c..df85e87  branches/default -> origin/branches/default
$ git log --oneline --graph --decorate --all
* 7b07969 (refs/notes/hg) Notes for default
* d4c1038 Notes for master
* df85e87 (origin/master, origin/branches/default, origin/HEAD, refs/hg/origin/branches/default, refs/hg/origin/bookmarks/master) Add some documentation
| * ba04a2a (HEAD, master) Update makefile
| * d25d16f Goodbye
|/
* ac7955c Create a makefile
* 65bb417 Create a standard "hello, world" program
```

Comme nous avons utilisé l’option `--all`, nous voyons les références
« notes » qui sont utilisées en interne par git-remote-hg, mais nous
pouvons les ignorer. Le reste était attendu ; `origin/master` a avancé
d’un *commit* et notre historique a divergé. À la différence d’autres
systèmes que nous décrivons dans ce chapitre, Mercurial est capable de
gérer les fusions, donc ce que nous allons faire n’a rien
d’extraordinaire.

``` highlight
$ git merge origin/master
Auto-merging hello.c
Merge made by the 'recursive' strategy.
 hello.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git log --oneline --graph --decorate
*   0c64627 (HEAD, master) Merge remote-tracking branch 'origin/master'
|\
| * df85e87 (origin/master, origin/branches/default, origin/HEAD, refs/hg/origin/branches/default, refs/hg/origin/bookmarks/master) Add some documentation
* | ba04a2a Update makefile
* | d25d16f Goodbye
|/
* ac7955c Create a makefile
* 65bb417 Create a standard "hello, world" program
```

Parfait. Nous lançons les tests et tout passe, et nous voilà prêts à
partager notre travail avec l’équipe :

``` highlight
$ git push
To hg::/tmp/hello
   df85e87..0c64627  master -> master
```

C’est fini ! Si vous inspectez le dépôt Mercurial, vous verrez que le
résultat se présente comme attendu :

``` highlight
$ hg log -G --style compact
o    5[tip]:4,2   dc8fa4f932b8   2014-08-14 19:33 -0700   ben
|\     Merge remote-tracking branch 'origin/master'
| |
| o  4   64f27bcefc35   2014-08-14 19:27 -0700   ben
| |    Update makefile
| |
| o  3:1   4256fc29598f   2014-08-14 19:27 -0700   ben
| |    Goodbye
| |
@ |  2   7db0b4848b3c   2014-08-14 19:30 -0700   ben
|/     Add some documentation
|
o  1   82e55d328c8c   2005-08-26 01:21 -0700   mpm
|    Create a makefile
|
o  0   0a04b987be5a   2005-08-26 01:20 -0700   mpm
     Create a standard "hello, world" program
```

La modification numérotée *2* a été faite par Mercurial et celles
numérotées *3* et *4* ont été faites par git-remote-hg, en poussant les
*commits* réalisés avec Git.

#### Branches et marque-pages

Git n’a qu’un seul type de branche : une référence qui se déplace quand
des *commits* sont ajoutés. Dans Mercurial, ce type de référence est
appelé « marque-page » et se comporte de la même manière qu’une branche
Git.

Le concept de « branche » dans Mercurial est plus contraignant. La
branche sur laquelle une modification est réalisée est enregistrée *avec
la modification*, ce qui signifie que cette dernière sera toujours
présente dans l’historique du dépôt. Voici un exemple d’un *commit*
ajouté à la branche `develop` :

``` highlight
$ hg log -l 1
changeset:   6:8f65e5e02793
branch:      develop
tag:         tip
user:        Ben Straub <ben@straub.cc>
date:        Thu Aug 14 20:06:38 2014 -0700
summary:     More documentation
```

Notez la ligne qui commence par « branch ». Git ne peut pas vraiment
répliquer ce comportement (il n’en a pas besoin ; les deux types de
branches peuvent être représentés par une ref Git), mais git-remote-hg a
besoin de comprendre cette différence, puisque qu’elle a du sens pour
Mercurial.

La création de marque-pages Mercurial est aussi simple que la création
de branches Git. Du côté Git :

``` highlight
$ git checkout -b featureA
Switched to a new branch 'featureA'
$ git push origin featureA
To hg::/tmp/hello
 * [new branch]      featureA -> featureA
```

C’est tout ce qui est nécessaire. Du côté Mercurial, cela ressemble à
ceci :

``` highlight
$ hg bookmarks
   featureA                  5:bd5ac26f11f9
$ hg log --style compact -G
@  6[tip]   8f65e5e02793   2014-08-14 20:06 -0700   ben
|    More documentation
|
o    5[featureA]:4,2   bd5ac26f11f9   2014-08-14 20:02 -0700   ben
|\     Merge remote-tracking branch 'origin/master'
| |
| o  4   0434aaa6b91f   2014-08-14 20:01 -0700   ben
| |    update makefile
| |
| o  3:1   318914536c86   2014-08-14 20:00 -0700   ben
| |    goodbye
| |
o |  2   f098c7f45c4f   2014-08-14 20:01 -0700   ben
|/     Add some documentation
|
o  1   82e55d328c8c   2005-08-26 01:21 -0700   mpm
|    Create a makefile
|
o  0   0a04b987be5a   2005-08-26 01:20 -0700   mpm
     Create a standard "hello, world" program
```

Remarquez la nouvelle étiquette `[featureA]` sur la révision 5. Elle se
comporte exactement comme une branche Git du côté Git, avec une
exception : vous ne pouvez pas effacer un marque-page depuis le côté Git
(c’est une limitation des greffons de gestion distante).

Vous pouvez travailler aussi sur une branche « lourde » Mercurial :
placez une branche dans l’espace de nom `branches` :

``` highlight
$ git checkout -b branches/permanent
Switched to a new branch 'branches/permanent'
$ vi Makefile
$ git commit -am 'A permanent change'
$ git push origin branches/permanent
To hg::/tmp/hello
 * [new branch]      branches/permanent -> branches/permanent
```

Voici à quoi ça ressemble du côté Mercurial :

``` highlight
$ hg branches
permanent                      7:a4529d07aad4
develop                        6:8f65e5e02793
default                        5:bd5ac26f11f9 (inactive)
$ hg log -G
o  changeset:   7:a4529d07aad4
|  branch:      permanent
|  tag:         tip
|  parent:      5:bd5ac26f11f9
|  user:        Ben Straub <ben@straub.cc>
|  date:        Thu Aug 14 20:21:09 2014 -0700
|  summary:     A permanent change
|
| @  changeset:   6:8f65e5e02793
|/   branch:      develop
|    user:        Ben Straub <ben@straub.cc>
|    date:        Thu Aug 14 20:06:38 2014 -0700
|    summary:     More documentation
|
o    changeset:   5:bd5ac26f11f9
|\   bookmark:    featureA
| |  parent:      4:0434aaa6b91f
| |  parent:      2:f098c7f45c4f
| |  user:        Ben Straub <ben@straub.cc>
| |  date:        Thu Aug 14 20:02:21 2014 -0700
| |  summary:     Merge remote-tracking branch 'origin/master'
[...]
```

Le nom de branche « permanent » a été enregistré avec la modification
marquée *7*.

Du côté Git, travailler avec les deux styles de branches revient au
même : employez les commandes `checkout`, `commit`, `fetch`, `merge`,
`pull` et `push` comme vous feriez normalement. Une chose à savoir
cependant est que Mercurial ne supporte pas la réécriture de
l’historique mais seulement les ajouts. Voici à quoi ressemble le dépôt
Mercurial après un rebasage interactif et une poussée forcée :

``` highlight
$ hg log --style compact -G
o  10[tip]   99611176cbc9   2014-08-14 20:21 -0700   ben
|    A permanent change
|
o  9   f23e12f939c3   2014-08-14 20:01 -0700   ben
|    Add some documentation
|
o  8:1   c16971d33922   2014-08-14 20:00 -0700   ben
|    goodbye
|
| o  7:5   a4529d07aad4   2014-08-14 20:21 -0700   ben
| |    A permanent change
| |
| | @  6   8f65e5e02793   2014-08-14 20:06 -0700   ben
| |/     More documentation
| |
| o    5[featureA]:4,2   bd5ac26f11f9   2014-08-14 20:02 -0700   ben
| |\     Merge remote-tracking branch 'origin/master'
| | |
| | o  4   0434aaa6b91f   2014-08-14 20:01 -0700   ben
| | |    update makefile
| | |
+---o  3:1   318914536c86   2014-08-14 20:00 -0700   ben
| |      goodbye
| |
| o  2   f098c7f45c4f   2014-08-14 20:01 -0700   ben
|/     Add some documentation
|
o  1   82e55d328c8c   2005-08-26 01:21 -0700   mpm
|    Create a makefile
|
o  0   0a04b987be5a   2005-08-26 01:20 -0700   mpm
     Create a standard "hello, world" program
```

Les modifications *8*, *9* et *10* ont été créées et appartiennent à la
branche `permanent` mais les anciennes modifications sont toujours
présentes. Ça a toutes les chances de perdre vos collègues qui utilisent
Mercurial, donc c’est à éviter à tout prix.

#### Résumé Mercurial

Git et Mercurial sont suffisamment similaires pour que le travail
pendulaire entre les deux se passe sans accroc. Si vous évitez de
modifier l’historique qui a déjà quitté votre machine (comme il l’est
recommandé), vous pouvez tout simplement ignorer que le dépôt distant
fonctionne avec Mercurial.

### Git et Bazaar

Parmi tous les systèmes de contrôle de version distribués, un des plus
connus est [Bazaar](http://bazaar.canonical.com/). Bazaar est libre et
open source, et fait partie du [Projet GNU](http://www.gnu.org/). Il a
un comportement très différent de Git. Parfois, pour faire la même chose
que Git, il vous faudra utiliser un mot-clé différent, et quelques
mots-clés communs n’ont pas la même signification. En particulier, la
gestion des branches est très différente et peut être déroutante,
surtout pour quelqu’un qui viendrait du monde de Git. Toutefois, il est
possible de travailler sur un dépôt Bazaar depuis un dépôt Git.

Il y a plein de projets qui permettent d’utiliser Git comme client d’un
dépôt Bazaar. Ici nous utiliserons le projet de Felipe Contreras que
vous pouvez trouver à l’adresse
<a href="https://github.com/felipec/git-remote-bzr" class="bare">https://github.com/felipec/git-remote-bzr</a>.
Pour l’installer, il suffit de télécharger le fichier `git-remote-bzr`
dans un dossier de votre `$PATH` et de le rendre exécutable :

``` highlight
$ wget https://raw.github.com/felipec/git-remote-bzr/master/git-remote-bzr -O ~/bin/git-remote-bzr
$ chmod +x ~/bin/git-remote-bzr
```

Vous devez aussi avoir Bazaar installé. C’est tout !

#### Créer un dépôt Git depuis un dépôt Bazaar

C’est simple à utiliser. Il suffit de cloner un dépôt Bazaar en
préfixant son nom par `bzr::`. Puisque Git et Bazaar font des copies
complètes sur votre machine, il est possible de lier un clone Git à
votre clone Bazaar local, mais ce n’est pas recommandé. Il est beaucoup
plus facile de lier votre clone Git directement au même endroit que
l’est votre clone Bazaar ‒ le dépôt central.

Supposons que vous travailliez avec un dépôt distant qui se trouve à
l’adresse `bzr+ssh://developpeur@monserveurbazaar:monprojet`. Alors vous
devez le cloner de la manière suivante :

``` highlight
$ git clone bzr::bzr+ssh://developpeur@monserveurbazaar:monprojet monProjet-Git
$ cd monProjet-Git
```

A ce stade, votre dépôt Git est créé mais il n’est pas compacté pour un
usage optimal de l’espace disque. C’est pourquoi vous devriez aussi
nettoyer et compacter votre dépôt Git, surtout si c’est un gros dépôt :

``` highlight
$ git gc --aggressive
```

#### Les branches Bazaar

Bazaar ne vous permet de cloner que des branches, mais un dépôt peut
contenir plusieurs branches, et `git-remote-bzr` peut cloner les deux.
Par exemple, pour cloner une branche :

``` highlight
$ git clone bzr::bzr://bzr.savannah.gnu.org/emacs/trunk emacs-trunk
```

Et pour cloner le dépôt entier :

``` highlight
$ git clone bzr::bzr:/bzr.savannah.gnu.org/emacs emacs
```

La seconde commande clone toutes les branches contenues dans le dépôt
emacs ; néanmoins il est possible de spécifier quelques branches :

``` highlight
$ git config remote-bzr.branches 'trunk, xwindow'
```

Certains dépôts ne permettent pas de lister leurs branches, auquel cas
vous devez les préciser manuellement, et même si vous pourriez spécifier
la configuration dans la commande de clonage, vous pourriez trouver ceci
plus facile :

``` highlight
$ git init emacs
$ git remote add origin bzr::bzr://bzr.savannah.gnu.org/emacs
$ git config remote-bzr.branches 'trunk, xwindow'
$ git fetch
```

#### Ignorer ce qui est ignoré avec .bzrignore

Puisque vous travaillez sur un projet géré sous Bazaar, vous ne devriez
pas créer de fichier `.gitignore` car vous pourriez le mettre
accidentellement en gestion de version et les autres personnes
travaillant sous Bazaar en seraient dérangées. La solution est de créer
le fichier `.git/info/exclude`, soit en tant que lien symbolique, soit
en tant que véritable fichier. Nous allons voir plus loin comment
trancher cette question.

Bazaar utilise le même modèle que Git pour ignorer les fichiers, mais
possède en plus deux particularités qui n’ont pas d’équivalent dans Git.
La description complète se trouve dans [la
documentation](http://doc.bazaar.canonical.com/bzr.2.7/en/user-reference/ignore-help.html).
Les deux particularités sont :

1.  le "!!" en début de chaîne de caractères qui prévaut sur le "!" en
    début de chaîne, ce qui permet d’ignorer des fichiers qui auraient
    été inclus avec "!"

2.  les chaînes de caractères commençant par "RE:". Ce qui suit "RE:"
    est une [expression
    rationnelle](http://doc.bazaar.canonical.com/bzr.2.7/en/user-reference/patterns-help.html).
    Git ne permet pas d’utiliser des expressions rationnelles, seulement
    les globs shell.

Par conséquent, il y a deux situations différentes à envisager :

1.  Si le fichier `.bzrignore` ne contient aucun de ces deux préfixes
    particuliers, alors vous pouvez simplement faire un lien symbolique
    vers celui-ci dans le dépôt.

2.  Sinon, vous devez créer le fichier `.git/info/exclude` et l’adapter
    pour ignorer exactement les mêmes fichiers que dans `.bzrignore`.

Quel que soit le cas de figure, vous devrez rester vigilant aux
modifications du fichier `.bzrignore` pour faire en sorte que le fichier
`.git/info/exclude` reflète toujours `.bzrignore`. En effet, si le
fichier `.bzrignore` venait à changer et comporter une ou plusieurs
lignes commençant par "!!" ou "RE:", Git ne pouvant interpréter ces
lignes, il vous faudra adapter le fichier `.git/info/exclude` pour
ignorer les mêmes fichiers que ceux ignorés avec `.bzrignore`. De
surcroît, si le fichier `.git/info/exclude` était un lien symbolique
vers `.bzrignore`, il vous faudra alors d’abord détruire le lien
symbolique, copier le fichier `.bzrignore` dans `.git/info/exclude` puis
adapter ce dernier. Attention toutefois à son élaboration car avec Git
il est impossible de ré-inclure un fichier dont l’un des dossiers parent
a été exclu.

#### Récupérer les changements du dépôt distant

Pour récupérer les changements du dépôt distant, vous tirez les
modifications comme d’habitude, en utilisant les commandes Git. En
supposant que vos modifications sont sur la branche `master`, vous
fusionnez ou rebasez votre travail sur la branche `origin/master` :

``` highlight
$ git pull --rebase origin
```

#### Pousser votre travail sur le dépôt distant

Comme Bazaar a lui aussi le concept de *commits* de fusion, il n’y aura
aucun problème si vous poussez un *commit* de fusion. Donc vous créez
vos branches et travaillez dessus, vous testez et validez votre travail
par l’intermédiaire de *commits* comme d’habitude, puis vous fusionnez
vos modifications dans `master` et vous poussez votre travail sur le
dépôt Bazaar :

``` highlight
$ git push origin master
```

#### Mise en garde

Le cadriciel de l’assistant de dépôt distant de Git a des limitations
qui s’imposent. En particulier, les commandes suivantes ne fonctionnent
pas :

-   git push origin :branche-à-effacer (Bazaar n’accepte pas de
    supprimer une branche de cette façon)

-   git push origin ancien:nouveau (il poussera *ancien*)

-   git push --dry-run origin branch (il poussera)

#### Résumé

Comme les modèles de Git et de Bazaar sont similaires, il n’y a pas
beaucoup de difficulté à travailler à la frontière. Tant que vous faites
attention aux limitations, et tant que vous êtes conscient que le dépôt
distant n’est pas nativement Git, tout ira bien.

### Git et Perforce

Perforce est un système de version très populaire dans les
environnements professionnels. Il existe depuis 1995, ce qui en fait le
système le plus ancien abordé dans ce chapitre. Avec cette information
en tête, il apparaît construit avec les contraintes de cette époque ; il
considère que vous êtes toujours connecté à un serveur central et une
seule version est conservée sur le disque dur local. C’est certain, ses
fonctionnalités et ses contraintes correspondent à quelques problèmes
spécifiques, mais de nombreux projets utilisent Perforce là où Git
fonctionnerait réellement mieux.

Il y a deux options pour mélanger l’utilisation de Perforce et de Git.
La première que nous traiterons est le pont « Git Fusion » créé par les
développeurs de Perforce, qui vous permet d’exposer en lecture-écriture
des sous-arbres de votre dépôt Perforce en tant que dépôts Git. La
seconde s’appelle git-p4, un pont côté client qui permet d’utiliser Git
comme un client Perforce, sans besoin de reconfigurer le serveur
Perforce.

#### Git Fusion

Perforce fournit un produit appelé Git Fusion (disponible sur
<a href="http://www.perforce.com/git-fusion" class="bare">http://www.perforce.com/git-fusion</a>),
qui synchronise un serveur Perforce avec des dépôts Git du côté serveur.

##### Installation

Pour nos exemples, nous utiliserons la méthode d’installation de Git
Fusion la plus facile qui consiste à télécharger une machine virtuelle
qui embarque le *daemon* Perforce et Git Fusion. Vous pouvez obtenir la
machine virtuelle depuis
<a href="http://www.perforce.com/downloads/Perforce/20-User" class="bare">http://www.perforce.com/downloads/Perforce/20-User</a>,
et une fois téléchargée, importez-la dans votre logiciel favori de
virtualisation (nous utiliserons VirtualBox).

Au premier lancement de la machine, il vous sera demandé de
personnaliser quelques mots de passe pour trois utilisateurs Linux
(`root`, `perforce` et `git`), et de fournir un nom d’instance qui peut
être utilisé pour distinguer cette installation des autres sur le même
réseau. Quand tout est terminé, vous verrez ceci :

![L’écran de démarrage de la machine virtuelle Git
Fusion.](images/git-fusion-boot.png)

Figure 146. L’écran de démarrage de la machine virtuelle Git Fusion.

Prenez note de l’adresse IP qui est indiquée ici, car nous en aurons
besoin plus tard. Ensuite, nous allons créer l’utilisateur Perforce.
Sélectionnez l’option « Login » en bas de l’écran et appuyez sur
*Entrée* (ou connectez-vous en SSH à la machine), puis identifiez-vous
comme `root`. Ensuite, utilisez ces commandes pour créer un
utilisateur :

``` highlight
$ p4 -p localhost:1666 -u super user -f john
$ p4 -p localhost:1666 -u john passwd
$ exit
```

La première commande va ouvrir un éditeur VI pour personnaliser
l’utilisateur, mais vous pouvez accepter les valeurs par défaut en
tapant `:wq` et en appuyant sur *Entrée*. La seconde vous demandera
d’entrer le mot de passe deux fois. C’est tout ce qu’il faut faire
depuis une invite de commande, et on peut quitter la session.

L’action suivante consiste à indiquer à Git de ne pas vérifier les
certificats SSL. L’image Git Fusion contient un certificat, mais
celui-ci ne correspond pas au domaine de l’adresse IP de votre machine
virtuelle, donc Git va rejeter la connexion HTTPS. Pour une installation
permanente, consultez le manuel Perforce Git Fusion pour installer un
certificat différent ; pour l’objet de notre exemple, ceci suffira :

``` highlight
$ export GIT_SSL_NO_VERIFY=true
```

Maintenant, nous pouvons tester que tout fonctionne correctement.

``` highlight
$ git clone https://10.0.1.254/Talkhouse
Cloning into 'Talkhouse'...
Username for 'https://10.0.1.254': john
Password for 'https://john@10.0.1.254':
remote: Counting objects: 630, done.
remote: Compressing objects: 100% (581/581), done.
remote: Total 630 (delta 172), reused 0 (delta 0)
Receiving objects: 100% (630/630), 1.22 MiB | 0 bytes/s, done.
Resolving deltas: 100% (172/172), done.
Checking connectivity... done.
```

La machine virtuelle contient un projet exemple que vous pouvez cloner.
Ici, nous clonons via HTTPS, avec l’utilisateur `john` que nous avons
créé auparavant ; Git demande le mot de passe pour cette connexion, mais
le cache d’identifiant permettra de sauter cette étape par la suite.

##### Configuration de Fusion

Une fois que Git Fusion est installé, vous désirerez sûrement modifier
la configuration. C’est assez facile à faire via votre client Perforce
favori ; rapatriez simplement le répertoire `//.git-fusion` du serveur
Perforce dans votre espace de travail. La structure du fichier ressemble
à ceci :

``` highlight
$ tree
.
├── objects
│   ├── repos
│   │   └── [...]
│   └── trees
│       └── [...]
│
├── p4gf_config
├── repos
│   └── Talkhouse
│       └── p4gf_config
└── users
    └── p4gf_usermap

498 directories, 287 files
```

Le répertoire `objects` est utilisé en interne par Git Fusion pour faire
correspondre les objets Perforce avec Git et vice versa et il n’y a pas
lieu d’y toucher. Il y a un fichier `p4gf_config` global dans ce
répertoire, ainsi qu’un fichier pour chaque dépôt. Ce sont les fichiers
de configuration qui déterminent comment Git Fusion se comporte.
Examinons le fichier à la racine :

``` highlight
[repo-creation]
charset = utf8

[git-to-perforce]
change-owner = author
enable-git-branch-creation = yes
enable-swarm-reviews = yes
enable-git-merge-commits = yes
enable-git-submodules = yes
preflight-commit = none
ignore-author-permissions = no
read-permission-check = none
git-merge-avoidance-after-change-num = 12107

[perforce-to-git]
http-url = none
ssh-url = none

[@features]
imports = False
chunked-push = False
matrix2 = False
parallel-push = False

[authentication]
email-case-sensitivity = no
```

Nous ne nous étendrons pas sur les significations des différents
paramètres, mais on voit que c’est un simple fichier INI, du même style
que ceux utilisés par Git. Ce fichier spécifie les options globales, qui
peuvent être surchargées par chaque fichier de configuration spécifique
à un dépôt, tel que `repos/Talkhouse/p4gf_config`. Si vous ouvrez ce
fichier, vous verrez une section `[@repo]` contenant des paramétrages
différents des paramètres globaux par défaut. Vous verrez aussi des
sections ressemblant à ceci :

``` highlight
[Talkhouse-master]
git-branch-name = master
view = //depot/Talkhouse/main-dev/... ...
```

C’est la correspondance entre une branche Perforce et une branche Git.
Le nom de la section est libre, du moment qu’il est unique.
`git-branch-name` vous permet de convertir un chemin du dépôt qui serait
encombrant sous Git en quelque chose de plus utilisable. L’entrée `view`
contrôle comment les fichiers Perforce sont transformés en dépôts Git,
en utilisant la syntaxe standard de description de vue. Des
correspondances multiples peuvent être indiquées, comme dans cet
exemple :

``` highlight
[multi-project-mapping]
git-branch-name = master
view = //depot/project1/main/... project1/...
       //depot/project2/mainline/... project2/...
```

De cette manière, si votre montage d’espace de travail normal change de
structure de répertoires, vous pouvez répliquer cette modification dans
le dépôt Git.

Le dernier fichier que nous examinerons est `users/p4gf_usermap`, qui
fait correspondre les utilisateurs Perforce avec les utilisateurs Git,
et qui n’est même pas nécessaire. Quand une modification Perforce est
convertie en *commit* Git, le comportement par défaut de Git Fusion
consiste à rechercher l’utilisateur Perforce et à utiliser son adresse
de courriel et son nom complet comme champs d’auteur/validateur dans
Git. Dans l’autre sens, le comportement par défaut consiste à rechercher
l’utilisateur Perforce correspondant à l’adresse de courriel stockée
dans le champ auteur du *commit* Git et de soumettre une modification
avec cet identifiant (si les permissions l’accordent). Dans la plupart
des cas, ce comportement suffira, mais considérons tout de même le
fichier de correspondance suivant :

``` highlight
john john@example.com "John Doe"
john johnny@appleseed.net "John Doe"
bob employeeX@example.com "Anon X. Mouse"
joe employeeY@example.com "Anon Y. Mouse"
```

Chaque ligne est de la forme `<utilisateur> <courriel> <nom complet>` et
crée une correspondance unique. Les deux premières lignes font
correspondre deux adresses de courriel distinctes avec le même
utilisateur Perforce. C’est utile si vous avez créé des *commits* Git
sous plusieurs adresses de courriel (ou modifié votre adresse de
courriel), mais que vous voulez les faire correspondre au même
utilisateur Perforce. À la création d’un *commit* Git depuis une
modification Perforce, la première ligne correspondant à l’utilisateur
Perforce est utilisée pour fournir l’information d’auteur à Git.

Les deux dernières lignes masquent les noms réels de Bob et Joe dans les
*commits* Git créés. C’est très utile si vous souhaitez ouvrir les
sources d’un projet interne, mais que vous ne souhaitez pas rendre
public le répertoire de vos employés. Notez que les adresses de courriel
et les noms complets devraient être uniques, à moins que vous ne
souhaitiez publier tous les *commits* Git avec un auteur unique fictif.

##### Utilisation

Perforce Git Fusion est une passerelle à double-sens entre les contrôles
de version Perforce et Git. Voyons comment cela se passe du côté Git.
Nous supposerons que nous avons monté le projet « Jam » en utilisant le
fichier de configuration ci-dessus, et que nous pouvons le cloner comme
ceci :

``` highlight
$ git clone https://10.0.1.254/Jam
Cloning into 'Jam'...
Username for 'https://10.0.1.254': john
Password for 'https://ben@10.0.1.254':
remote: Counting objects: 2070, done.
remote: Compressing objects: 100% (1704/1704), done.
Receiving objects: 100% (2070/2070), 1.21 MiB | 0 bytes/s, done.
remote: Total 2070 (delta 1242), reused 0 (delta 0)
Resolving deltas: 100% (1242/1242), done.
Checking connectivity... done.
$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/rel2.1
$ git log --oneline --decorate --graph --all
* 0a38c33 (origin/rel2.1) Create Jam 2.1 release branch.
| * d254865 (HEAD, origin/master, origin/HEAD, master) Upgrade to latest metrowerks on Beos -- the Intel one.
| * bd2f54a Put in fix for jam's NT handle leak.
| * c0f29e7 Fix URL in a jam doc
| * cc644ac Radstone's lynx port.
[...]
```

La première fois que vous le faites, cela peut durer un certain temps.
Ce qui se passe, c’est que Git Fusion convertit toutes les modifications
concernées de l’historique Perforce en *commits* Git. Cela se passe
localement sur le serveur, donc c’est plutôt rapide, mais si votre
historique est long, ce n’est pas immédiat. Les récupérations
subséquentes ne lancent que des conversions incrémentales, ce qui
devrait correspondre à la vitesse native de Git.

Comme vous pouvez le voir, notre dépôt ressemble complètement à un autre
dépôt Git. Il y a trois branches et Git a utilement créé une branche
`master` locale qui suit la branche `origin/master`. Travaillons un peu
et créons une paire de *commits* :

``` highlight
# ...
$ git log --oneline --decorate --graph --all
* cfd46ab (HEAD, master) Add documentation for new feature
* a730d77 Whitespace
* d254865 (origin/master, origin/HEAD) Upgrade to latest metrowerks on Beos -- the Intel one.
* bd2f54a Put in fix for jam's NT handle leak.
[...]
```

Nous avons deux nouveaux *commits*. Maintenant, vérifions si quelqu’un
d’autre a aussi travaillé :

``` highlight
$ git fetch
remote: Counting objects: 5, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (3/3), done.
From https://10.0.1.254/Jam
   d254865..6afeb15  master     -> origin/master
$ git log --oneline --decorate --graph --all
* 6afeb15 (origin/master, origin/HEAD) Update copyright
| * cfd46ab (HEAD, master) Add documentation for new feature
| * a730d77 Whitespace
|/
* d254865 Upgrade to latest metrowerks on Beos -- the Intel one.
* bd2f54a Put in fix for jam's NT handle leak.
[...]
```

Il semble bien ! Ça n’apparaît pas sur cette vue, mais le *commit*
`6afeb15` a en fait été créé en utilisant un client Perforce. Il
ressemble juste à un commit normal du point de vue de Git, ce qui est
exactement l’effet recherché. Voyons comment le serveur Perforce gère le
*commit* de fusion :

``` highlight
$ git merge origin/master
Auto-merging README
Merge made by the 'recursive' strategy.
 README | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git push
Counting objects: 9, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (9/9), done.
Writing objects: 100% (9/9), 917 bytes | 0 bytes/s, done.
Total 9 (delta 6), reused 0 (delta 0)
remote: Perforce: 100% (3/3) Loading commit tree into memory...
remote: Perforce: 100% (5/5) Finding child commits...
remote: Perforce: Running git fast-export...
remote: Perforce: 100% (3/3) Checking commits...
remote: Processing will continue even if connection is closed.
remote: Perforce: 100% (3/3) Copying changelists...
remote: Perforce: Submitting new Git commit objects to Perforce: 4
To https://10.0.1.254/Jam
   6afeb15..89cba2b  master -> master
```

Git pense que ça a marché. Voyons l’historique du fichier `README` du
point de vue de Perforce, en utilisant la fonctionnalité de graphe de
révision de `p4v` :

![Graphe de révision de Perforce résultant d’une poussée depuis
Git.](images/git-fusion-perforce-graph.png)

Figure 147. Graphe de révision de Perforce résultant d’une poussée
depuis Git.

Si vous n’avez jamais vu ceci auparavant, cela peut dérouter, mais c’est
une vue similaire à la vue graphique de l’historique Git. Nous
visualisons l’historique du fichier `README`, donc l’arbre de répertoire
en haut à gauche ne montre que ce fichier, aux endroits où il apparaît
dans différentes branches. En haut à droite, nous avons le graphe visuel
des relations entre les différentes révisions du fichier et la vue en
grand du graphe en bas à droite. Le reste de l’écran concerne la
visualisation des détails pour la révision sélectionnée (`2` dans ce
cas).

Une chose à noter est que le graphe ressemble exactement à celui de
l’historique Git. Perforce n’avait pas de branche nommée pour stocker
les *commits* `1` et `2`, il a donc créé une branche « anonymous » dans
le répertoire `.git-fusion` pour la gérer. Cela arrivera aussi pour des
branches Git nommées qui ne correspondent pas à une branche Perforce
nommée (et que vous pouvez plus tard faire correspondre à une branche
Perforce en utilisant le fichier de configuration).

Tout ceci se passe en coulisse, mais le résultat final est qu’une
personne dans l’équipe peut utiliser Git, une autre Perforce et aucune
des deux n’a à se soucier du choix de l’autre.

##### Résumé Git-Fusion

Si vous avez accès (ou pouvez avoir accès) à un votre serveur Perforce,
Git Fusion est un excellent moyen de faire parler Git et Perforce
ensemble. Cela nécessite un peu de configuration, mais la courbe
d’apprentissage n’est pas très raide. C’est une des rares sections de ce
chapitre où il est inutile de faire spécifiquement attention à ne pas
utiliser toute la puissance de Git. Cela ne signifie pas que Perforce
sera ravi de tout ce que vous lui enverrez — si vous réécrivez
l’historique qui a déjà été poussé, Git Fusion va le rejeter — Git
Fusion cherche vraiment à sembler naturel. Vous pouvez même utiliser les
sous-modules Git (bien qu’ils paraîtront étranges pour les utilisateurs
Perforce), et fusionner les branches (ce qui sera enregistré comme une
intégration du côté Perforce).

Si vous ne pouvez pas convaincre un administrateur de votre serveur
d’installer Git Fusion, il existe encore un moyen d’utiliser ces outils
ensemble.

#### Git-p4

Git-p4 est une passerelle à double sens entre Git et Perforce. Il
fonctionne intégralement au sein de votre dépôt Git, donc vous n’avez
besoin d’aucun accès au serveur Perforce (autre que les autorisations
d’utilisateur, bien sûr). Git-p4 n’est pas une solution aussi flexible
ou complète que Git Fusion, mais il permet tout de même de réaliser la
plupart des activités sans être invasif dans l’environnement serveur.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Vous aurez besoin de l’outil <code>p4</code> dans votre de chemin de recherche pour travailler avec <code>git-p4</code>. À la date d’écriture du livre, il est disponible à <a href="http://www.perforce.com/downloads/Perforce/20-User" class="bare">http://www.perforce.com/downloads/Perforce/20-User</a>.</p>
</div></td>
</tr>
</tbody>
</table>

##### Installation

Pour l’exemple, nous allons lancer le serveur Perforce depuis l’image
Git Fusion, comme indiqué ci-dessus, mais nous n’utiliserons pas le
serveur Git Fusion et nous dialoguerons avec la gestion de version
Perforce directement.

Pour utiliser le client `p4` en ligne de commande (dont `git-p4`
dépend), vous devrez définir quelques variables d’environnement :

``` highlight
$ export P4PORT=10.0.1.254:1666
$ export P4USER=john
```

##### Démarrage

Comme d’habitude avec Git, la première commande est un clonage :

``` highlight
$ git p4 clone //depot/www/live www-shallow
Importing from //depot/www/live into www-shallow
Initialized empty Git repository in /private/tmp/www-shallow/.git/
Doing initial import of //depot/www/live/ from revision #head into refs/remotes/p4/master
```

Cela crée ce qui en parlé Git s’appelle un clone « superficiel »
(**shallow**) ; seule la toute dernière révision Perforce est importée
dans Git ; souvenez-vous que Perforce n’a pas été pensé pour fournir
toutes les révisions à chaque utilisateur. C’est suffisant pour utiliser
Git comme client Perforce, mais pour d’autres utilisations, ce n’est pas
assez.

Une fois que c’est terminé, nous avons un dépôt Git complètement
fonctionnel.

``` highlight
$ cd myproject
$ git log --oneline --all --graph --decorate
* 70eaf78 (HEAD, p4/master, p4/HEAD, master) Initial import of //depot/www/live/ from the state at revision #head
```

Notez le dépôt `p4` distant pour le serveur Perforce, mais tout le reste
ressemble à un clone standard. En fait, c’est trompeur ; ce n’est pas
réellement dépôt distant.

``` highlight
$ git remote -v
```

Il n’y a pas du tout de dépôt distant. Git-p4 a créé des références qui
représentent l’état du serveur et celles-ci ressemblent à des références
de dépôts distants dans `git log`, mais elles ne sont pas gérées par Git
lui-même et vous ne pouvez pas pousser dessus.

##### Utilisation

Donc, travaillons un peu. Supposons que vous avez progressé sur une
fonctionnalité très importante et que vous êtes prêt à la montrer au
reste de votre équipe.

``` highlight
$ git log --oneline --all --graph --decorate
* 018467c (HEAD, master) Change page title
* c0fb617 Update link
* 70eaf78 (p4/master, p4/HEAD) Initial import of //depot/www/live/ from the state at revision #head
```

Nous avons réalisé deux nouveaux *commits* qui sont prêts à être soumis
au serveur Perforce. Vérifions si quelqu’un d’autre a poussé son travail
entre temps.

``` highlight
$ git p4 sync
git p4 sync
Performing incremental import into refs/remotes/p4/master git branch
Depot paths: //depot/www/live/
Import destination: refs/remotes/p4/master
Importing revision 12142 (100%)
$ git log --oneline --all --graph --decorate
* 75cd059 (p4/master, p4/HEAD) Update copyright
| * 018467c (HEAD, master) Change page title
| * c0fb617 Update link
|/
* 70eaf78 Initial import of //depot/www/live/ from the state at revision #head
```

Il semblerait que ce soit le cas, et `master` et `p4/master` ont
divergé. Le système de branchement de Perforce ne ressemble en rien à
celui de Git, donc soumettre des *commits* de fusion n’a aucun sens.
Git-p4 recommande de rebaser vos *commits* et fournit même un raccourci
pour le faire :

``` highlight
$ git p4 rebase
Performing incremental import into refs/remotes/p4/master git branch
Depot paths: //depot/www/live/
No changes to import!
Rebasing the current branch onto remotes/p4/master
First, rewinding head to replay your work on top of it...
Applying: Update link
Applying: Change page title
 index.html | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Vous pouvez déjà le deviner aux messages affichés, mais `git p4 rebase`
est un raccourci pour `git p4 sync` suivi de `git rebase p4/master`.
C’est légèrement plus intelligent que cela, spécifiquement lors de la
gestion de branches multiples, mais ça correspond bien.

À présent, notre historique est linéaire à nouveau et nous sommes prêts
à remonter nos modifications sur Perforce. La commande `git p4 submit`
va essayer de créer une nouvelle révision Perforce pour chaque *commit*
Git entre `p4/master` et `master`. Son lancement ouvre notre éditeur
favori et le contenu du fichier ouvert ressemble à ceci :

``` highlight
# A Perforce Change Specification.
#
#  Change:      The change number. 'new' on a new changelist.
#  Date:        The date this specification was last modified.
#  Client:      The client on which the changelist was created.  Read-only.
#  User:        The user who created the changelist.
#  Status:      Either 'pending' or 'submitted'. Read-only.
#  Type:        Either 'public' or 'restricted'. Default is 'public'.
#  Description: Comments about the changelist.  Required.
#  Jobs:        What opened jobs are to be closed by this changelist.
#               You may delete jobs from this list.  (New changelists only.)
#  Files:       What opened files from the default changelist are to be added
#               to this changelist.  You may delete files from this list.
#               (New changelists only.)

Change:  new

Client:  john_bens-mbp_8487

User: john

Status:  new

Description:
   Update link

Files:
   //depot/www/live/index.html   # edit


######## git author ben@straub.cc does not match your p4 account.
######## Use option --preserve-user to modify authorship.
######## Variable git-p4.skipUserNameCheck hides this message.
######## everything below this line is just the diff #######
--- //depot/www/live/index.html  2014-08-31 18:26:05.000000000 0000
+++ /Users/ben/john_bens-mbp_8487/john_bens-mbp_8487/depot/www/live/index.html   2014-08-31 18:26:05.000000000 0000
@@ -60,7 +60,7 @@
 </td>
 <td valign=top>
 Source and documentation for
-<a href="http://www.perforce.com/jam/jam.html">
+<a href="jam.html">
 Jam/MR</a>,
 a software build tool.
 </td>
```

C’est quasiment le même contenu qu’on verrait en lançant `p4 submit`,
mis à part le bloc à la fin que git-p4 a utilement inclus. Git-p4 essaye
d’honorer vos réglages Git et Perforce individuellement quand il doit
fournir un nom pour un *commit* ou une modification, mais dans certains
cas, vous voudrez le modifier. Par exemple, si le *commit* Git que vous
importez a été écrit par un contributeur qui n’a pas de compte
utilisateur dans Perforce, vous voudrez tout de même que la modification
résultante ait l’air d’avoir été écrite par lui, et non par vous.

Git-p4 a importé le message du *commit* Git comme contenu de la
modification Perforce, donc tout ce qu’il nous reste à faire et de
sauvegarder et de quitter, deux fois (une fois par *commit*). La sortie
qui en résulte ressemble à ceci :

``` highlight
$ git p4 submit
Perforce checkout for depot path //depot/www/live/ located at /Users/ben/john_bens-mbp_8487/john_bens-mbp_8487/depot/www/live/
Synchronizing p4 checkout...
... - file(s) up-to-date.
Applying dbac45b Update link
//depot/www/live/index.html#4 - opened for edit
Change 12143 created with 1 open file(s).
Submitting change 12143.
Locking 1 files ...
edit //depot/www/live/index.html#5
Change 12143 submitted.
Applying 905ec6a Change page title
//depot/www/live/index.html#5 - opened for edit
Change 12144 created with 1 open file(s).
Submitting change 12144.
Locking 1 files ...
edit //depot/www/live/index.html#6
Change 12144 submitted.
All commits applied!
Performing incremental import into refs/remotes/p4/master git branch
Depot paths: //depot/www/live/
Import destination: refs/remotes/p4/master
Importing revision 12144 (100%)
Rebasing the current branch onto remotes/p4/master
First, rewinding head to replay your work on top of it...
$ git log --oneline --all --graph --decorate
* 775a46f (HEAD, p4/master, p4/HEAD, master) Change page title
* 05f1ade Update link
* 75cd059 Update copyright
* 70eaf78 Initial import of //depot/www/live/ from the state at revision #head
```

À la sortie, c’est comme si nous avions fait un `git push`, ce qui est
l’analogie la plus proche avec ce qui s’est réellement passé.

Notez aussi que durant ce processus, les *commits* Git sont transformés
en modifications Perforce ; si vous voulez les comprimer en une seule
modification, vous pouvez le faire avec un rebasage interactif avant de
lancer `git p4 submit`. Notez aussi que les empreintes SHA-1 de tous les
*commits* qui ont été soumis comme modifications ont changé ; c’est
parce que git-p4 ajoute une ligne à la fin de chaque message de
validation qu’il convertit :

``` highlight
$ git log -1
commit 775a46f630d8b46535fc9983cf3ebe6b9aa53145
Author: John Doe <john@example.com>
Date:   Sun Aug 31 10:31:44 2014 -0800

    Change page title

    [git-p4: depot-paths = "//depot/www/live/": change = 12144]
```

Que se passe-t-il si vous essayez de soumettre un *commit* de fusion ?
Essayons pour voir. Voici la situation dans laquelle nous sommes :

``` highlight
$ git log --oneline --all --graph --decorate
* 3be6fd8 (HEAD, master) Correct email address
*   1dcbf21 Merge remote-tracking branch 'p4/master'
|\
| * c4689fc (p4/master, p4/HEAD) Grammar fix
* | cbacd0a Table borders: yes please
* | b4959b6 Trademark
|/
* 775a46f Change page title
* 05f1ade Update link
* 75cd059 Update copyright
* 70eaf78 Initial import of //depot/www/live/ from the state at revision #head
```

Les historiques Git et Perforce divergent à partir de 775a46f. Le côté
Git contient deux *commits*, puis un *commit* de fusion avec la tête
Perforce, puis un autre *commit*. Nous allons essayer de les soumettre
au sommet d’un seul changement côté Perforce. Voyons ce qui se passerait
si nous essayions de soumettre cet historique maintenant :

``` highlight
$ git p4 submit -n
Perforce checkout for depot path //depot/www/live/ located at /Users/ben/john_bens-mbp_8487/john_bens-mbp_8487/depot/www/live/
Would synchronize p4 checkout in /Users/ben/john_bens-mbp_8487/john_bens-mbp_8487/depot/www/live/
Would apply
  b4959b6 Trademark
  cbacd0a Table borders: yes please
  3be6fd8 Correct email address
```

L’option `-n` est un raccourci pour `--dry-run` qui essaie d’afficher ce
qui se passerait si la commande `submit` était réellement lancée. Dans
ce cas, il semble que nous créerions trois modifications Perforce, ce
qui correspond aux trois *commits* sans fusion qui n’existent pas encore
sur le serveur Perforce. Cela ressemble exactement à ce que nous
souhaitons, voyons comment cela se passe :

``` highlight
$ git p4 submit
[…]
$ git log --oneline --all --graph --decorate
* dadbd89 (HEAD, p4/master, p4/HEAD, master) Correct email address
* 1b79a80 Table borders: yes please
* 0097235 Trademark
* c4689fc Grammar fix
* 775a46f Change page title
* 05f1ade Update link
* 75cd059 Update copyright
* 70eaf78 Initial import of //depot/www/live/ from the state at revision #head
```

Notre historique est devenu linéaire, comme si nous avions rebasé avant
de soumettre (ce qui est exactement ce qui s’est passé). Cela signifie
que vous êtes libre de créer, modifier, jeter et fusionner les branches
du côté Git sans crainte que votre historique deviennent à un moment
incompatible avec Perforce. Si vous pouvez le rebaser, vous pourrez le
reporter dans le serveur Perforce.

##### Branche

Si votre projet Perforce a de multiples branches, vous n’êtes pas
malchanceux ; `git-p4` peut gérer cette configuration d’une manière
similaire à Git. Supposons que votre dépôt Perforce ait la forme
suivante :

``` highlight
//depot
  └── project
      ├── main
      └── dev
```

Et supposons que vous ayez une branche `dev` qui contient une *view
spec* qui ressemble à ceci :

``` highlight
//depot/project/main/... //depot/project/dev/...
```

Git-p4 peut détecter automatiquement cette situation et faire ce qu’il
faut :

``` highlight
$ git p4 clone --detect-branches //depot/project@all
Importing from //depot/project@all into project
Initialized empty Git repository in /private/tmp/project/.git/
Importing revision 20 (50%)
    Importing new branch project/dev

    Resuming with change 20
Importing revision 22 (100%)
Updated branches: main dev
$ cd project; git log --oneline --all --graph --decorate
* eae77ae (HEAD, p4/master, p4/HEAD, master) main
| * 10d55fb (p4/project/dev) dev
| * a43cfae Populate //depot/project/main/... //depot/project/dev/....
|/
* 2b83451 Project init
```

Notez le déterminant « `@all` » ; il indique à `git-p4` de cloner non
seulement la dernière modification pour ce sous-arbre, mais aussi toutes
les modifications qui ont déjà touché à ces chemins. C’est plus proche
du concept de clone dans Git, mais si vous travaillez sur un projet avec
un long historique, cela peut prendre du temps à se terminer.

L’option `--detect-branches` indique à `git-p4` d’utiliser les
spécifications de branche de Perforce pour faire correspondre aux
références Git. Si ces correspondances ne sont pas présentes sur le
serveur Perforce (ce qui est une manière tout à fait valide d’utiliser
Perforce), vous pouvez dire à `git-p4` ce que sont les correspondances
de branches, et vous obtiendrez le même résultat :

``` highlight
$ git init project
Initialized empty Git repository in /tmp/project/.git/
$ cd project
$ git config git-p4.branchList main:dev
$ git clone --detect-branches //depot/project@all .
```

Renseigner la variable de configuration `git-p4.branchList` à `main:dev`
indique à `git-p4` que `main` et `dev` sont toutes deux des branches et
que la seconde est la fille de la première.

Si nous lançons maintenant `git checkout -b dev p4/project/dev` et
ajoutons quelques *commits*, git-p4 est assez intelligent pour cibler la
bonne branche quand nous lançons `git-p4 submit`. Malheureusement,
`git-p4` ne peut pas mélanger les clones superficiels et les branches
multiples ; si vous avez un projet gigantesque et que vous voulez
travailler sur plus d’une branche, vous devrez lancer `git p4 clone` une
fois pour chaque branche à laquelle vous souhaitez soumettre.

Pour créer ou intégrer des branches, vous devrez utiliser un client
Perforce. Git-p4 ne peut synchroniser et soumettre que sur des branches
préexistantes, et il ne peut le faire qu’avec une modification linéaire
à la fois. Si vous fusionnez deux branches dans Git et que vous essayez
de soumettre la nouvelle modification, tout ce qui sera enregistré sera
une série de modifications de fichiers ; les métadonnées relatives aux
branches impliquées dans cette intégration seront perdues.

#### Résumé Git et Perforce

Git-p4 rend possible l’usage des modes d’utilisation de Git avec un
serveur Perforce, et ce, de manière plutôt réussie. Cependant, il est
important de se souvenir que Perforce gère les sources et qu’on ne
travaille avec Git que localement. Il faut rester vraiment attentif au
partage de *commits* Git ; si vous avez un dépôt distant que d’autres
personnes utilisent, ne poussez aucun *commit* qui n’a pas déjà été
soumis au serveur Perforce.

Si vous souhaitez mélanger l’utilisation de Git et de Perforce comme
clients pour la gestion de source sans restriction et si vous arrivez à
convaincre un administrateur de l’installer, Git Fusion fait de Git un
client de premier choix pour un serveur Perforce.

### Git et TFS

Git est en train de devenir populaire chez les développeurs Windows et
si vous écrivez du code pour Windows, il y a de fortes chances que vous
utilisiez *Team Foundation Server* (TFS) de Microsoft. TFS est une suite
collaborative qui inclut le suivi de tickets et de tâches, le support de
modes de développement Scrum et autres, la revue de code et la gestion
de version. Pour éviter toute confusion ultérieure, **TFS** est en fait
le serveur, qui supporte la gestion de version de sources en utilisant à
la fois Git et son propre gestionnaire de version, appelé **TFVC**
(*Team Fundation Version Control*). Le support de Git est une
fonctionnalité assez nouvelle pour TFS (introduite dans la version
2013), donc tous les outils plus anciens font référence à la partie
gestion de version comme « TFS », même s’ils ne fonctionnent réellement
qu’avec TFVC.

Si vous vous trouvez au sein d’une équipe qui utilise TFVC mais que vous
préférez utiliser Git comme client de gestionnaire de version, il y a un
projet pour votre cas.

#### Quel outil

En fait, il y en a deux : git-tf et git-tfs.

Git-tfs (qu’on peut trouver à
<a href="http://git-tfs.com" class="bare">http://git-tfs.com</a>) est un
projet .NET et ne fonctionne que sous Windows (à l’heure de la rédaction
du livre). Pour travailler avec des dépôts Git, il utilise les liaisons
.NET pour libgit2, une implémentation de Git orientée bibliothèque, qui
est très performante et qui permet de manipuler avec beaucoup de
flexibilité un dépôt Git à bas niveau. Libgit2 n’est pas une
implantation complète de Git, donc pour couvrir la différence, git-tfs
va en fait appeler directement le client Git en ligne de commande pour
certaines opérations de manière à éliminer les limites artificielles de
ce qui est réalisable sur des dépôts Git. Son support des
fonctionnalités de TFVC est très mature, puisqu’il utilise les
assemblages de Visual Studio pour les opérations avec les serveurs. Cela
implique que vous devez avoir accès à ces assemblages, ce qui signifie
que vous devez installer une version récente de Visual Studio (n’importe
quelle version depuis la version 2010, y compris la version Express
depuis la version 2012), ou le SDK (Software Development Kit) Visual
Studio.

Git-tf (dont le site est
<a href="https://gittfs.codeplex.com" class="bare">https://gittfs.codeplex.com</a>)
est un projet Java et en tant que tel peut fonctionner sur tout
ordinateur supportant l’environnement d’exécution Java. Il s’interface
avec les dépôts Git à travers JGit (une implantation sur JVM de Git), ce
qui signifie qu’il n’y a virtuellement aucune limitation en termes de
fonctionnalités Git. Cependant, le support pour TFVC est plus limité
comparé à git-tfs - il ne supporte pas les branches par exemple.

Donc chaque outil a ses avantages et ses défauts, et de nombreuses
situations favorisent l’un par rapport à l’autre. Nous décrirons
l’utilisation de base de chaque outil.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Vous aurez besoin d’un accès à un dépôt TFVC pour pouvoir suivre les instructions qui vont suivre. Il n’y en a pas beaucoup disponibles sur internet comme Git ou Subversion, et il se peut que vous deviez en créer un par vous-même. Codeplex (<a href="https://www.codeplex.com" class="bare">https://www.codeplex.com</a>) ou Visual Studio Online (<a href="http://www.visualstudio.com" class="bare">http://www.visualstudio.com</a>) sont tous deux de bons choix.</p>
</div></td>
</tr>
</tbody>
</table>

#### Démarrage : `git-tf`

La première chose à faire, comme toujours avec Git, c’est de cloner.
Voici à quoi cela ressemble avec `git-tf` :

``` highlight
$ git tf clone https://tfs.codeplex.com:443/tfs/TFS13 $/myproject/Main project_git
```

Le premier argument est l’URL de la collection TFVC, le deuxième est de
la forme `/projet/branche` et le troisième est le chemin vers le dépôt
local Git à créer (celui-ci est optionnel). Git-tf ne peut fonctionner
qu’avec une branche à la fois ; si vous voulez valider sur une branche
TFVC différente, vous devrez faire un nouveau clone de cette branche.

Cela crée un dépôt Git complètement fonctionnel :

``` highlight
$ cd project_git
$ git log --all --oneline --decorate
512e75a (HEAD, tag: TFS_C35190, origin_tfs/tfs, master) Checkin message
```

Ceci s’appelle un clone *superficiel*, ce qui signifie que seule la
dernière révision a été téléchargée. TFVC n’est pas conçu pour que
chaque client ait une copie complète de l’historique, donc git-tf ne
récupère que la dernière révision par défaut, ce qui est plus rapide.

Si vous avez du temps, il vaut peut-être le coup de cloner l’intégralité
de l’historique du projet, en utilisant l’option `--deep` :

``` highlight
$ git tf clone https://tfs.codeplex.com:443/tfs/TFS13 $/myproject/Main \
  project_git --deep
Username: domain\user
Password:
Connecting to TFS...
Cloning $/myproject into /tmp/project_git: 100%, done.
Cloned 4 changesets. Cloned last changeset 35190 as d44b17a
$ cd project_git
$ git log --all --oneline --decorate
d44b17a (HEAD, tag: TFS_C35190, origin_tfs/tfs, master) Goodbye
126aa7b (tag: TFS_C35189)
8f77431 (tag: TFS_C35178) FIRST
0745a25 (tag: TFS_C35177) Created team project folder $/tfvctest via the \
        Team Project Creation Wizard
```

Remarquez les étiquettes comprenant des noms tels que `TFS_C35189` ;
c’est une fonctionnalité qui vous aide à reconnaître quels *commits* Git
sont associés à des modifications TFVC. C’est une façon élégante de les
représenter, puisque vous pouvez voir avec une simple commande `log`
quels *commits* sont associés avec un instantané qui existe aussi dans
TFVC. Elles ne sont pas nécessaires (en fait, on peut les désactiver
avec `git config git-tf.tag false`) – git-tf conserve les
correspondances *commit*-modification dans le fichier `.git/git-tf`.

#### Démarrage : `git-tfs`

Le clonage via Git-tfs se comporte légèrement différemment. Observons :

``` highlight
PS> git tfs clone --with-branches \
    https://username.visualstudio.com/DefaultCollection \
    $/project/Trunk project_git
Initialized empty Git repository in C:/Users/ben/project_git/.git/
C15 = b75da1aba1ffb359d00e85c52acb261e4586b0c9
C16 = c403405f4989d73a2c3c119e79021cb2104ce44a
Tfs branches found:
- $/tfvc-test/featureA
The name of the local branch will be : featureA
C17 = d202b53f67bde32171d5078968c644e562f1c439
C18 = 44cd729d8df868a8be20438fdeeefb961958b674
```

Notez l’option `--with-branches`. Git-tfs est capable de faire
correspondre les branches de TFVC et Git, et cette option indique de
créer une branche Git locale pour chaque branche TFVC. C’est hautement
recommandé si vous avez déjà fait des branches et des fusions dans TFS,
mais cela ne fonctionnera pas avec un serveur plus ancien que TFS 2010 –
avant cette version, les « branches » n’étaient que des répertoires et
git-tfs ne peut pas les différencier de répertoires normaux.

Visitons le dépôt Git résultant :

``` highlight
PS> git log --oneline --graph --decorate --all
* 44cd729 (tfs/featureA, featureA) Goodbye
* d202b53 Branched from $/tfvc-test/Trunk
* c403405 (HEAD, tfs/default, master) Hello
* b75da1a New project
PS> git log -1
commit c403405f4989d73a2c3c119e79021cb2104ce44a
Author: Ben Straub <ben@straub.cc>
Date:   Fri Aug 1 03:41:59 2014 +0000

    Hello

    git-tfs-id: [https://username.visualstudio.com/DefaultCollection]$/myproject/Trunk;C16
```

Il y a deux branches locales, `master` et `featureA`, ce qui correspond
au point de départ du clone (`Trunk` dans TFVC) et à une branche enfant
(`featureA` dans TFVC). Vous pouvez voir que le « dépôt distant » `tfs`
contient aussi des références : `default` et `featureA` qui représentent
les branches TFVC. Git-tfs fait correspondre la branche que vous avez
clonée depuis `tfs/default`, et les autres récupèrent leur propre nom.

Une autre chose à noter concerne les lignes `git-tfs-id:` dans les
messages de validation. Au lieu d’étiquettes, git-tfs utilise ces
marqueurs pour faire le lien entre les modifications TFVC et les
*commits* Git. Cela implique que les *commits* Git vont avoir une
empreinte SHA-1 différente entre avant et après avoir été poussés sur
TFVC.

#### Travail avec Git-tf\[s\]

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Indépendamment de chaque outil que vous utilisez, vous devriez renseigner quelques paramètres de configuration Git pour éviter les ennuis.</p>
</div>
<div class="listingblock">
<div class="content">
<pre class="highlight"><code>$ git config set --local core.ignorecase=true
$ git config set --local core.autocrlf=false</code></pre>
</div>
</div></td>
</tr>
</tbody>
</table>

Evidemment, vous souhaitez ensuite travailler sur le projet. TFVC et TFS
ont des caractéristiques qui peuvent complexifier votre travail :

1.  Les branches thématiques qui ne sont pas représentées dans TFVC
    ajoutent un peu de complexité. Cela est dû à la manière **très**
    différente dont TFVC et Git représentent les branches.

2.  Soyez conscient que TFVC permet aux utilisateurs d'« extraire » des
    fichiers depuis le serveur en les verrouillant pour qu’aucun autre
    utilisateur ne puisse les éditer. Cela ne vous empêchera évidemment
    pas de les éditer dans votre dépôt local, mais cela pourrait être un
    obstacle au moment de pousser vos modifications sur le serveur TFVC.

3.  TFS a le concept de validations « gardées », où un cycle de
    compilation/test TFS doit se terminer avec succès pour que la
    validation soit acceptée. Cela utilise la fonction « enterrement »
    (*shelve*) dans TFVC, que nous ne détaillons pas en détail ici. Vous
    pouvez simuler ceci manuellement avec git-tf, et git-tfs fournit la
    commande `checkintool` qui connaît le concept de garde.

Pour abréger, nous n’allons traiter que le cas sans erreur, qui
contourne ou évite quasiment tous les problèmes.

#### Travail avec `git-tf`

Supposons que vous ayez travaillé et validé quelques *commits* sur
`master` et que vous êtes prêt à partager votre progression sur le
serveur TFVC. Voici notre dépôt Git :

``` highlight
$ git log --oneline --graph --decorate --all
* 4178a82 (HEAD, master) update code
* 9df2ae3 update readme
* d44b17a (tag: TFS_C35190, origin_tfs/tfs) Goodbye
* 126aa7b (tag: TFS_C35189)
* 8f77431 (tag: TFS_C35178) FIRST
* 0745a25 (tag: TFS_C35177) Created team project folder $/tfvctest via the \
          Team Project Creation Wizard
```

Nous voulons prendre l’instantané qui est dans le *commit* `4178a82` et
le pousser sur le serveur TFVC.

Tout d’abord, vérifions si un de nos collègues a fait quelque chose
depuis notre dernière connexion :

``` highlight
$ git tf fetch
Username: domain\user
Password:
Connecting to TFS...
Fetching $/myproject at latest changeset: 100%, done.
Downloaded changeset 35320 as commit 8ef06a8. Updated FETCH_HEAD.
$ git log --oneline --graph --decorate --all
* 8ef06a8 (tag: TFS_C35320, origin_tfs/tfs) just some text
| * 4178a82 (HEAD, master) update code
| * 9df2ae3 update readme
|/
* d44b17a (tag: TFS_C35190) Goodbye
* 126aa7b (tag: TFS_C35189)
* 8f77431 (tag: TFS_C35178) FIRST
* 0745a25 (tag: TFS_C35177) Created team project folder $/tfvctest via the \
          Team Project Creation Wizard
```

Il semble que c’est le cas et nous avons maintenant un historique
divergent. C’est là où Git brille, mais nous avons deux options :

1.  Faire un *commit* de fusion semble naturel pour un utilisateur Git
    (après tout, c’est ce que `git pull` réalise), et git-tf peut faire
    cela pour vous avec un simple `git tf pull`. Gardez cependant à
    l’esprit que TFVC n’est pas conçu de cette manière et si vous
    poussez des *commits* de fusion, votre historique va commencer à
    être différent entre les deux côtés, ce qui peut être déroutant.
    Cependant, si vous comptez soumettre tout votre travail comme une
    modification unique, c’est sûrement le choix le plus simple.

2.  Rebaser pour rendre votre historique linéaire, ce qui signifie que
    nous avons l’option de convertir chaque *commit* Git en modification
    TFVC. Comme c’est l’option qui laisse le plus de possibilités
    ouvertes, c’est la méthode recommandée ;
    `` git-tf̀  facilite même cette méthode avec la commande `git tf pull --rebase ``.

Le choix reste le vôtre. Pour cet exemple, nous rebaserons :

``` highlight
$ git rebase FETCH_HEAD
First, rewinding head to replay your work on top of it...
Applying: update readme
Applying: update code
$ git log --oneline --graph --decorate --all
* 5a0e25e (HEAD, master) update code
* 6eb3eb5 update readme
* 8ef06a8 (tag: TFS_C35320, origin_tfs/tfs) just some text
* d44b17a (tag: TFS_C35190) Goodbye
* 126aa7b (tag: TFS_C35189)
* 8f77431 (tag: TFS_C35178) FIRST
* 0745a25 (tag: TFS_C35177) Created team project folder $/tfvctest via the \
          Team Project Creation Wizard
```

À présent, nous sommes prêt à valider dans le serveur TFVC. Git-tf vous
laisse le choix de faire un changement unique qui représente toutes les
modifications depuis le dernier réalisé (`--shallow`, par défaut) ou de
créer une nouvelle modification pour chaque *commit* Git (`--deep`).
Pour cet exemple, nous allons créer une modification unique :

``` highlight
$ git tf checkin -m 'Updating readme and code'
Username: domain\user
Password:
Connecting to TFS...
Checking in to $/myproject: 100%, done.
Checked commit 5a0e25e in as changeset 35348
$ git log --oneline --graph --decorate --all
* 5a0e25e (HEAD, tag: TFS_C35348, origin_tfs/tfs, master) update code
* 6eb3eb5 update readme
* 8ef06a8 (tag: TFS_C35320) just some text
* d44b17a (tag: TFS_C35190) Goodbye
* 126aa7b (tag: TFS_C35189)
* 8f77431 (tag: TFS_C35178) FIRST
* 0745a25 (tag: TFS_C35177) Created team project folder $/tfvctest via the \
          Team Project Creation Wizard
```

Il y a une nouvelle étiquette `TFS_C35348` qui indique que TFVC stocke
le même instantané que le *commit* `5a0e25e`. Il est important de noter
que chaque *commit* Git n’a pas besoin d’avoir une contrepartie exacte
dans TFVC ; le *commit* `6eb3eb5`, par exemple, n’existe pas sur le
serveur.

C’est le style de gestion principal. Gardez en tête les quelques autres
aspects de cette utilisation :

-   Il est impossible d’utiliser les branches. Git-tf ne peut créer des
    dépôts Git qu’à partir d’une branche de TFVC à la fois.

-   Le serveur central est TFVC ou Git, pas les deux. Différents clones
    git-tf du même dépôt TFVC peuvent avoir des empreintes SHA-1
    différentes, ce qui sera un casse-tête sans fin.

-   Si la gestion dans votre équipe consiste à collaborer par Git et à
    synchroniser périodiquement avec TFVC, ne connectez TFVC qu’à un
    seul dépôt Git.

#### Travailler avec `git-tfs`

Déroulons le même scénario en utilisant `git-tfs`. Voici les nouveaux
*commits* que nous avons ajoutés à la branche `master` dans notre dépôt
Git :

``` highlight
PS> git log --oneline --graph --all --decorate
* c3bd3ae (HEAD, master) update code
* d85e5a2 update readme
| * 44cd729 (tfs/featureA, featureA) Goodbye
| * d202b53 Branched from $/tfvc-test/Trunk
|/
* c403405 (tfs/default) Hello
* b75da1a New project
```

Maintenant, voyons si quelqu’un a avancé pendant que nous travaillions
de notre côté :

``` highlight
PS> git tfs fetch
C19 = aea74a0313de0a391940c999e51c5c15c381d91d
PS> git log --all --oneline --graph --decorate
* aea74a0 (tfs/default) update documentation
| * c3bd3ae (HEAD, master) update code
| * d85e5a2 update readme
|/
| * 44cd729 (tfs/featureA, featureA) Goodbye
| * d202b53 Branched from $/tfvc-test/Trunk
|/
* c403405 Hello
* b75da1a New project
```

Oui, un collègue a ajouté une nouvelle modification TFVC, qui prend la
forme du nouveau *commit* `aea74a0`, ce qui a fait avancer la branche
`tfs/default`.

De la même manière qu’avec `git-tf`, nous avons deux options pour
résoudre l’historique divergent :

1.  Rebaser pour préserver l’historique linéaire,

2.  fusionner pour préserver ce qui s’est réellement passé.

Dans cet exemple, nous allons réaliser une validation « profonde » où
chaque *commit* Git devient une modification TFVC, ce qui implique que
nous rebasions.

``` highlight
PS> git rebase tfs/default
First, rewinding head to replay your work on top of it...
Applying: update readme
Applying: update code
PS> git log --all --oneline --graph --decorate
* 10a75ac (HEAD, master) update code
* 5cec4ab update readme
* aea74a0 (tfs/default) update documentation
| * 44cd729 (tfs/featureA, featureA) Goodbye
| * d202b53 Branched from $/tfvc-test/Trunk
|/
* c403405 Hello
* b75da1a New project
```

Nous voici prêts à réintégrer notre code dans le serveur TFVC. Nous
utiliserons la commande `rcheckin` pour créer des modifications TFVC
pour chaque *commit* Git dans le parcours entre HEAD et la première
branche distante `tfs` trouvée (la commande `checkin` ne créerait qu’une
modification, comme si on compressait tous les *commits*).

``` highlight
PS> git tfs rcheckin
Working with tfs remote: default
Fetching changes from TFS to minimize possibility of late conflict...
Starting checkin of 5cec4ab4 'update readme'
 add README.md
C20 = 71a5ddce274c19f8fdc322b4f165d93d89121017
Done with 5cec4ab4b213c354341f66c80cd650ab98dcf1ed, rebasing tail onto new TFS-commit...
Rebase done successfully.
Starting checkin of b1bf0f99 'update code'
 edit .git\tfs\default\workspace\ConsoleApplication1/ConsoleApplication1/Program.cs
C21 = ff04e7c35dfbe6a8f94e782bf5e0031cee8d103b
Done with b1bf0f9977b2d48bad611ed4a03d3738df05ea5d, rebasing tail onto new TFS-commit...
Rebase done successfully.
No more to rcheckin.
PS> git log --all --oneline --graph --decorate
* ff04e7c (HEAD, tfs/default, master) update code
* 71a5ddc update readme
* aea74a0 update documentation
| * 44cd729 (tfs/featureA, featureA) Goodbye
| * d202b53 Branched from $/tfvc-test/Trunk
|/
* c403405 Hello
* b75da1a New project
```

Remarquez comment après chaque enregistrement réussi dans le serveur
TFVC, git-tfs rebase le travail restant sur ce qui vient d’être intégré.
C’est dû à l’addition du champ `git-tfs-id` au bas du message de
validation, qui modifie l’empreinte SHA-1 du *commit* dernièrement
enregistré. Cela se passe comme prévu et il n’y a pas lieu de s’en
inquiéter, mais il faut garder à l’esprit cette transformation,
spécialement si vous partagez des *commits* Git avec d’autres
développeurs.

TFS a de nombreuses fonctionnalités intégrées avec le système de gestion
de version, telles que les tâches, les revues, les enregistrements
gardés, etc. Travailler avec ces fonctionnalités à partir de la ligne de
commande peut être lourd mais heureusement, git-tfs permet de lancer
très facilement un outil d’enregistrement graphique :

``` highlight
PS> git tfs checkintool
PS> git tfs ct
```

L’outil ressemble à ceci :

![L’outil d’enregistrement git-tfs.](images/git-tfs-ct.png)

Figure 148. L’outil d’enregistrement git-tfs.

Les utilisateurs de TFS le connaissent, puisque c’est la même boîte de
dialogue que celle lancée depuis Visual Studio.

Git-tfs vous laisse aussi gérer vos branches TFVC depuis votre dépôt
Git. Par exemple, nous allons en créer une :

``` highlight
PS> git tfs branch $/tfvc-test/featureBee
The name of the local branch will be : featureBee
C26 = 1d54865c397608c004a2cadce7296f5edc22a7e5
PS> git lga
* 1d54865 (tfs/featureBee) Creation branch $/myproject/featureBee
* ff04e7c (HEAD, tfs/default, master) update code
* 71a5ddc update readme
* aea74a0 update documentation
| * 44cd729 (tfs/featureA, featureA) Goodbye
| * d202b53 Branched from $/tfvc-test/Trunk
|/
* c403405 Hello
* b75da1a New project
```

Créer une branche dans TFVC signifie ajouter une modification où cette
branche existe à présent, ce qui se traduit par un *commit* Git. Notez
aussi que git-tfs a **créé** la branche distante `tfs/featureBee`, mais
`HEAD` pointe toujours sur `master`. Si vous voulez travailler sur la
toute nouvelle branche, vous souhaiterez baser vos nouveaux *commits*
sur `1d54865`, peut-être en créant une branche thématique sur ce
*commit*.

#### Résumé Git et TFS

Git-tf et Git-tfs sont tous deux des grands outils pour s’interfacer
avec un serveur TFVC. Ils vous permettent d’utiliser la puissance de Git
localement, vous évitant d’avoir sans arrêt à faire des aller-retours
avec le serveur central TFVC et simplifie votre vie de développeur, sans
forcer toute l’équipe à passer sous Git. Si vous travaillez sous Windows
(ce qui est très probable si votre équipe utilise TFS), vous souhaiterez
utiliser git-tfs car ses fonctionnalités sont les plus complètes, mais
si vous travaillez avec une autre plate-forme, vous utiliserez git-tf
qui est plus limité. Comme avec la plupart des outils vus dans ce
chapitre, vous avez intérêt à vous standardiser sur un de ces systèmes
de gestion de version et à utiliser l’autre comme miroir ‒ soit Git,
soit TFVC doivent être le centre de collaboration, pas les deux.

## Migration vers Git

Si vous avez une base de code existant dans un autre Système de Contrôle
de Version (SCV) mais que vous avez décidé de commencer à utiliser Git,
vous devez migrer votre projet d’une manière ou d’une autre. Cette
section passe en revue quelques importateurs pour des systèmes communs,
et ensuite démontre comment développer votre propre importateur
personnalisé. Vous apprendrez comment importer les données depuis
plusieurs des plus gros systèmes de gestion de configuration logicielle
(*SCM*, *Software Configuration Management*) utilisés
professionnellement, parce qu’ils comportent la majorité des
utilisateurs qui basculent, et parce que des outils de haute qualité
dédiés sont faciles à se procurer.

### Subversion

Si vous avez lu la section précédente concernant l’utilisation de
`git svn`, vous pouvez utiliser facilement ces instructions pour
`git svn clone` un dépôt ; ensuite, vous pouvez arrêter d’utiliser le
serveur Subversion, pousser vers un nouveau serveur Git, et commencer à
l’utiliser. Si vous voulez l’historique, vous pouvez obtenir cela aussi
rapidement que vous pouvez tirer les données hors du serveur Subversion
(ce qui peut prendre un bout de temps).

Cependant, l’import n’est pas parfait ; et comme ça prendra tant de
temps, autant le faire correctement. Le premier problème est
l’information d’auteur. Dans Subversion, chaque personne qui crée un
*commit* a un utilisateur sur le système qui est enregistré dans
l’information de *commit*. Les exemples dans la section précédente
montrent `schacon` à quelques endroits, comme la sortie de `blame` et
`git svn log`. Si vous voulez faire correspondre cela à une meilleure
donnée d’auteur Git, vous avez besoin d’une transposition des
utilisateurs Subversion vers les auteurs Git. Créez un fichier appelé
`users.txt` qui a cette correspondance dans un format tel que celui-ci :

``` highlight
schacon = Scott Chacon <schacon@geemail.com>
selse = Someo Nelse <selse@geemail.com>
```

Pour obtenir une liste des noms d’auteur que SVN utilise, vous pouvez
lancer ceci :

``` highlight
$ svn log --xml | grep author | sort -u | \
  perl -pe 's/.*>(.*?)<.*/$1 = /'
```

Cela génère la sortie log dans le format XML, puis garde seulement les
lignes avec l’information d’auteur, rejette les doublons, enlève les
étiquettes XML. (Bien sûr, cela ne marche que sur une machine ayant
`grep`, `sort` et `perl` installés.) Ensuite, redirigez cette sortie
dans votre fichier users.txt afin que vous puissiez ajouter
l’information d’utilisateur Git équivalente près de chaque entrée.

Vous pouvez fournir ce fichier à `git svn` pour l’aider à faire
correspondre la donnée d’auteur plus précisément. Vous pouvez aussi
demander à `git svn` de ne pas inclure les metadonnées que Subversion
importe normalement, en passant `--no-metadata` à la commande `clone` ou
`init`. Ceci fait ressembler votre commande `import` à ceci :

``` highlight
$ git-svn clone http://my-project.googlecode.com/svn/ \
      --authors-file=users.txt --no-metadata -s my_project
```

Maintenant vous devriez avoir un import Subversion plus joli dans votre
dossier `my_project`. Au lieu de *commits* qui ressemblent à ceci

``` highlight
commit 37efa680e8473b615de980fa935944215428a35a
Author: schacon <schacon@4c93b258-373f-11de-be05-5f7a86268029>
Date:   Sun May 3 00:12:22 2009 +0000

    fixed install - go to trunk

    git-svn-id: https://my-project.googlecode.com/svn/trunk@94 4c93b258-373f-11de-
    be05-5f7a86268029
```

ils ressemblent à ceci :

``` highlight
commit 03a8785f44c8ea5cdb0e8834b7c8e6c469be2ff2
Author: Scott Chacon <schacon@geemail.com>
Date:   Sun May 3 00:12:22 2009 +0000

    fixed install - go to trunk
```

Non seulement le champ Auteur a l’air beaucoup mieux, mais le
`git-svn-id` n’est plus là non plus.

Vous devriez aussi faire un peu de ménage post-import. D’abord, vous
devriez nettoyer les références bizarres que `git svn` a installées.
Premièrement vous déplacerez les étiquettes afin qu’elles soient de
véritables étiquettes plutôt que d’étranges branches distantes, et
ensuite vous déplacerez le reste des branches afin qu’elles soient
locales.

Pour déplacer les étiquettes pour qu’elles soient des étiquettes Git
propres, lancez

``` highlight
$ cp -Rf .git/refs/remotes/origin/tags/* .git/refs/tags/
$ rm -Rf .git/refs/remotes/origin/tags
```

Ceci prend les références qui étaient des branches distantes qui
commençaient par `remotes/origin/tags` et en fait de vraies étiquettes
(légères).

Ensuite, déplacez le reste des références sous `refs/remotes` pour
qu’elles soient des branches locales :

``` highlight
$ cp -Rf .git/refs/remotes/origin/* .git/refs/heads/
$ rm -Rf .git/refs/remotes/origin
```

Il peut arriver que vous voyiez quelques autres branches qui sont
suffixées par `@xxx` (où xxx est un nombre), alors que dans Subversion
vous ne voyez qu’une seule branche. C’est en fait une fonctionnalité
Subversion appelée « peg-revisions », qui est quelque chose pour
laquelle Git n’a tout simplement pas d’équivalent syntaxique. Donc,
`git svn` ajoute simplement le numéro de version svn au nom de la
branche de la même façon que vous l’auriez écrit dans svn pour adresser
la « peg-revision » de cette branche. Si vous ne vous souciez plus des
« peg-revisions », supprimez-les simplement en utilisant
`git branch -d`.

Maintenant toutes les vieilles branches sont de vraies branches Git et
toutes les vieilles étiquettes sont de vraies étiquettes Git.

Il y a une dernière chose à nettoyer. Malheureusement, `git svn` crée
une branche supplémentaire appelée `trunk`, qui correspond à la branche
par défaut de Subversion, mais la ref `trunk` pointe au même endroit que
`master`. Comme `master` est plus idiomatiquement Git, voici comment
supprimer la branche supplémentaire :

``` highlight
$ git branch -d trunk
```

La dernière chose à faire est d’ajouter votre nouveau serveur Git en
tant que serveur distant et pousser vers lui. Voici un exemple d’ajout
de votre serveur en tant que serveur distant :

``` highlight
$ git remote add origin git@my-git-server:myrepository.git
```

Puisque vous voulez que vos branches et étiquettes montent, vous pouvez
maintenant lancer :

``` highlight
$ git push origin --all
$ git push origin --tags
```

Toutes vos branches et étiquettes devraient être sur votre nouveau
serveur Git dans un import joli et propre.

### Mercurial

Puisque Mercurial et Git ont des modèles assez similaires pour
représenter les versions, et puisque Git est un peu plus flexible,
convertir un dépôt depuis Mercurial vers Git est assez simple, en
utilisant un outil appelé "hg-fast-export", duquel vous aurez besoin
d’une copie :

``` highlight
$ git clone https://github.com/frej/fast-export.git
```

La première étape dans la conversion est d’obtenir un clone complet du
dépôt Mercurial que vous voulez convertir :

``` highlight
$ hg clone <remote repo URL> /tmp/hg-repo
```

L’étape suivante est de créer un fichier d’association d’auteur.
Mercurial est un peu plus indulgent que Git pour ce qu’il mettra dans le
champ auteur pour les modifications, donc c’est le bon moment pour faire
le ménage. La génération de ceci tient en une ligne de commande dans un
shell `bash` :

``` highlight
$ cd /tmp/hg-repo
$ hg log | grep user: | sort | uniq | sed 's/user: *//' > ../authors
```

Cela prendra quelques secondes, en fonction de la longueur de
l’historique de votre projet, et ensuite le fichier `/tmp/authors`
ressemblera à quelque chose comme ceci :

``` highlight
bob
bob@localhost
bob <bob@company.com>
bob jones <bob <AT> company <DOT> com>
Bob Jones <bob@company.com>
Joe Smith <joe@company.com>
```

Dans cet exemple, la même personne (Bob) a créé des modifications sous
différents noms, dont l’un est correct, et dont un autre est
complètement invalide pour un *commit* Git. Hg-fast-import nous laisse
régler cela en transformant chaque ligne en règle :
`` "<source>"="<cible>", qui transforme une `<source> `` en `<cible>`.

Dans les chaînes `<source>` et `<cible>`, toutes les séquences
d’échappement supportées par la fonction python `string_escape` sont
prises en charge. Si le fichier de transformation d’auteurs ne contient
pas de correspondance avec `<source>`, cet auteur sera envoyé à Git sans
modification. Dans cet exemple, nous voulons que notre fichier ressemble
à cela :

``` highlight
bob=Bob Jones <bob@company.com>
bob@localhost=Bob Jones <bob@company.com>
bob jones <bob <AT> company <DOT> com>=Bob Jones <bob@company.com>
bob <bob@company.com>=Bob Jones <bob@company.com>
```

L’étape suivante consiste à créer notre nouveau dépôt Git, et à lancer
le script d’export :

``` highlight
$ git init /tmp/converted
$ cd /tmp/converted
$ /tmp/fast-export/hg-fast-export.sh -r /tmp/hg-repo -A /tmp/authors
```

L’option `-r` indique à hg-fast-export où trouver le dépôt Mercurial que
l’on veut convertir, et l’option `-A` lui indique où trouver le fichier
de correspondance d’auteur. Le script analyse les modifications
Mercurial et les convertit en un script pour la fonctionnalité
"fast-import" de Git (que nous détaillerons un peu plus tard). Cela
prend un peu de temps (bien que ce soit *beaucoup plus* rapide que si
c’était à travers le réseau), et la sortie est assez verbeuse :

``` highlight
$ /tmp/fast-export/hg-fast-export.sh -r /tmp/hg-repo -A /tmp/authors
Loaded 4 authors
master: Exporting full revision 1/22208 with 13/0/0 added/changed/removed files
master: Exporting simple delta revision 2/22208 with 1/1/0 added/changed/removed files
master: Exporting simple delta revision 3/22208 with 0/1/0 added/changed/removed files
[…]
master: Exporting simple delta revision 22206/22208 with 0/4/0 added/changed/removed files
master: Exporting simple delta revision 22207/22208 with 0/2/0 added/changed/removed files
master: Exporting thorough delta revision 22208/22208 with 3/213/0 added/changed/removed files
Exporting tag [0.4c] at [hg r9] [git :10]
Exporting tag [0.4d] at [hg r16] [git :17]
[…]
Exporting tag [3.1-rc] at [hg r21926] [git :21927]
Exporting tag [3.1] at [hg r21973] [git :21974]
Issued 22315 commands
git-fast-import statistics:
---------------------------------------------------------------------
Alloc'd objects:     120000
Total objects:       115032 (    208171 duplicates                  )
      blobs  :        40504 (    205320 duplicates      26117 deltas of      39602 attempts)
      trees  :        52320 (      2851 duplicates      47467 deltas of      47599 attempts)
      commits:        22208 (         0 duplicates          0 deltas of          0 attempts)
      tags   :            0 (         0 duplicates          0 deltas of          0 attempts)
Total branches:         109 (         2 loads     )
      marks:        1048576 (     22208 unique    )
      atoms:           1952
Memory total:          7860 KiB
       pools:          2235 KiB
     objects:          5625 KiB
---------------------------------------------------------------------
pack_report: getpagesize()            =       4096
pack_report: core.packedGitWindowSize = 1073741824
pack_report: core.packedGitLimit      = 8589934592
pack_report: pack_used_ctr            =      90430
pack_report: pack_mmap_calls          =      46771
pack_report: pack_open_windows        =          1 /          1
pack_report: pack_mapped              =  340852700 /  340852700
---------------------------------------------------------------------

$ git shortlog -sn
   369  Bob Jones
   365  Joe Smith
```

C’est à peu près tout ce qu’il y a. Toutes les étiquettes Mercurial ont
été converties en étiquettes Git, et les branches et marques-page
Mercurial ont été convertis en branches Git. Maintenant vous êtes prêt à
pousser le dépôt vers son nouveau serveur d’hébergement :

``` highlight
$ git remote add origin git@my-git-server:myrepository.git
$ git push origin --all
```

### Bazaar

Bazaar est un système de contrôle de version distribué tout comme Git,
en conséquence de quoi il est assez facile de convertir un dépôt Bazaar
en un dépôt Git. Pour cela, vous aurez besoin d’importer le plugin
`bzr-fastimport`.

#### Obtenir le plugin bzr-fastimport

La procédure d’installation du plugin `bzr-fastimport` est différente
sur les systèmes type UNIX et sur Windows.

Dans le premier cas, le plus simple est d’installer le paquet
`bzr-fastimport` avec toutes les dépendances requises.

Par exemple, sur Debian et dérivés, vous feriez comme cela :

``` highlight
$ sudo apt-get install bzr-fastimport
```

Avec RHEL, vous feriez ainsi :

``` highlight
$ sudo yum install bzr-fastimport
```

Avec Fedora, depuis la sortie de la version 22, le nouveau gestionnaire
de paquets est dnf :

``` highlight
$ sudo dnf install bzr-fastimport
```

Si le paquet n’est pas disponible, vous pouvez l’installer en tant que
plugin :

``` highlight
$ mkdir --parents ~/.bazaar/plugins/   # crée les dossiers nécessaires aux plugins
$ cd ~/.bazaar/plugins/
$ bzr branch lp:bzr-fastimport fastimport   # importe le plugin bzr-fastimport
$ cd fastimport
$ sudo python setup.py install --record=files.txt   # installe le plugin
```

Pour que ce plugin fonctionne, vous aurez aussi besoin du module Python
`fastimport`. Vous pouvez vérifier s’il est présent ou non et
l’installer avec les commandes suivantes :

``` highlight
$ python -c "import fastimport"
Traceback (most recent call last):
  File "<string>" , line 1, in <module>
ImportError: No module named fastimport
$ pip install fastimport
```

S’il n’est pas disponible, vous pouvez le télécharger à l’adresse
<a href="https://pypi.python.org/pypi/fastimport/" class="bare">https://pypi.python.org/pypi/fastimport/</a>.

Dans le second cas (sous Windows), `bzr-fastimport` est automatiquement
installé avec la version *standalone* et l’installation par défaut
(laisser toutes les cases à cocher cochées). Alors, vous n’avez rien à
faire.

À ce stade, la façon d’importer un dépôt Bazaar diffère selon que vous
n’avez qu’une seule branche ou que vous travaillez avec un dépôt qui a
plusieurs branches.

#### Projet avec une seule branche

Maintenant positionnez-vous dans le dossier qui contient votre dépôt
Bazaar et initialisez le dépôt Git :

``` highlight
$ cd /chemin/vers/le/depot/bzr
$ git init
```

Vous pouvez exporter simplement votre dépôt Bazaar et le convertir en un
dépôt Git avec la commande suivante :

``` highlight
$ bzr fast-export --plain . | git fast-import
```

Selon la taille du projet, votre dépôt Git est constitué dans un délai
allant de quelques secondes à plusieurs minutes.

#### Cas d’un projet avec une branche principale et une branche de travail

Vous pouvez aussi importer un dépôt Bazaar qui contient plusieurs
branches. Supposons que vous avez deux branches : l’une représente la
branche principale (monProjet.trunk), l’autre est la branche de travail
(monProjet.travail).

``` highlight
$ ls
monProjet.trunk monProjet.travail
```

Créez le dépôt Git et placez-vous-y :

``` highlight
$ git init depot-git
$ cd depot-git
```

Tirez la branche principale dans le dépôt git :

``` highlight
$ bzr fast-export --marks=../marks.bzr --plain ../monProjet.trunk | \
git fast-import --export-marks=../marks.git
```

Tirez la branche de travail dans le dépôt git :

``` highlight
$ bzr fast-export --marks=../marks.bzr --plain --git-branch=travail ../monProjet.travail | \
git fast-import --import-marks=../marks.git --export-marks=../marks.git
```

Maintenant, `git branch` vous montre la branche `master` tout comme la
branche `travail`. Vérifiez les logs pour vous assurer qu’ils sont
complets et supprimez les fichiers `marks.bzr` et `marks.git`.

#### Synchroniser l’index

Quel que soit le nombre de branches que vous aviez et la méthode
d’importation, votre index n’est pas synchronisé avec HEAD, et avec
l’import de plusieurs branches, votre répertoire de travail n’est pas
synchronisé non plus. Cette situation se résout simplement avec la
commande suivante :

``` highlight
$ git reset --hard HEAD
```

#### Ignorer les fichiers qui étaient ignorés avec .bzrignore

Occupons-nous maintenant des fichiers à ignorer. Il faut tout d’abord
renommer le fichier `.bzrignore` en `.gitignore`. Si le fichier
`.bzrignore` contient une ou des lignes commençant par "!!" ou "RE:", il
vous faudra en plus le modifier et peut-être créer de multiples fichiers
`.gitignore` afin d’ignorer exactement les mêmes fichiers que le
permettait `.bzrignore`.

Finalement, vous devrez créer un *commit* qui contient cette
modification pour la migration :

``` highlight
$ git mv .bzrignore .gitignore
$ # modifier le fichier .gitignore au besoin
$ git commit -m 'Migration de Bazaar vers Git'
```

#### Envoyer votre dépôt git sur le serveur

Nous y sommes enfin ! Vous pouvez maintenant pousser votre dépôt sur son
nouveau serveur d’hébergement :

``` highlight
$ git remote add origin git@mon-serveur-git:mon-depot-git.git
$ git push origin --all
$ git push origin --tags
```

La migration de Bazaar vers Git est maintenant terminée, vous pouvez
travailler sur votre dépôt git.

### Perforce

Le système suivant dont vous allez voir l’importation est Perforce.
Ainsi que nous l’avons dit plus haut, il y a deux façons de permettre de
faire parler Git et Perforce l’un avec l’autre : git-p4 et Perforce Git
Fusion.

#### Perforce Git Fusion

Git Fusion rend ce processus assez indolore. Configurez les paramètres
de votre projet, les correspondances utilisateur et les branches en
utilisant un fichier de configuration (comme discuté dans [Git
Fusion](#s_p4_git_fusion)), et clonez le dépôt. Git Fusion vous laisse
avec ce qui ressemble à un dépôt Git natif, qui est alors prêt à être
poussé vers un hôte Git natif si vous le désirez. Vous pouvez même
utiliser Perforce comme hôte Git si vous ça vous plaît.

#### Git-p4

Git-p4 peut aussi agir comme outil d’import. Comme exemple, nous
importerons le projet Jam depuis le Dépôt Public Perforce. Pour définir
votre client, vous devez exporter la variable d’environnement P4PORT
pour pointer vers le dépôt Perforce :

``` highlight
$ export P4PORT=public.perforce.com:1666
```

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Pour suivre tout le long, vous aurez besoin d’un dépôt Perforce auquel vous connecter. Nous utiliserons le dépôt public à public.perforce.com pour nos exemples, mais vous pouvez utiliser n’importe quel dépôt auquel vous avez accès.</p>
</div></td>
</tr>
</tbody>
</table>

Lancez la commande `git p4 clone` pour importer le projet Jam depuis le
serveur Perforce, en fournissant le chemin vers le dépôt et le projet
dans lequel vous voulez importer le projet :

``` highlight
$ git-p4 clone //guest/perforce_software/jam@all p4import
Importing from //guest/perforce_software/jam@all into p4import
Initialized empty Git repository in /private/tmp/p4import/.git/
Import destination: refs/remotes/p4/master
Importing revision 9957 (100%)
```

Ce projet particulier a seulement une branche, mais si vous avez des
branches configurées avec des vues de branche (ou juste un ensemble de
dossiers), vous pouvez utiliser l’option `--detect-branches` avec
`git p4 clone` pour importer aussi toutes les branches du projet. Voyez
[Branche](#s_git_p4_branches) pour plus de détails sur ceci.

A ce point, vous avez presque terminé. Si vous allez dans le dossier
`p4import` et lancez `git log`, vous pouvez voir le travail importé :

``` highlight
$ git log -2
commit e5da1c909e5db3036475419f6379f2c73710c4e6
Author: giles <giles@giles@perforce.com>
Date:   Wed Feb 8 03:13:27 2012 -0800

    Correction to line 355; change </UL> to </OL>.

    [git-p4: depot-paths = "//public/jam/src/": change = 8068]

commit aa21359a0a135dda85c50a7f7cf249e4f7b8fd98
Author: kwirth <kwirth@perforce.com>
Date:   Tue Jul 7 01:35:51 2009 -0800

    Fix spelling error on Jam doc page (cummulative -> cumulative).

    [git-p4: depot-paths = "//public/jam/src/": change = 7304]
```

Vous pouvez voir que `git-p4` a laissé un identifiant dans chaque
message de *commit*. C’est bien de garder cet identifiant-là, au cas où
vous auriez besoin de référencer le numéro de changement Perforce plus
tard. Cependant, si vous souhaitez enlever l’identifiant, c’est
maintenant le moment de le faire – avant que vous ne commenciez à
travailler sur le nouveau dépôt. Vous pouvez utiliser
`git filter-branch` pour enlever en masse les chaînes d’identifiant :

``` highlight
$ git filter-branch --msg-filter 'sed -e "/^\[git-p4:/d"'
Rewrite e5da1c909e5db3036475419f6379f2c73710c4e6 (125/125)
Ref 'refs/heads/master' was rewritten
```

Si vous lancez `git log`, vous pouvez voir que toutes les sommes de
vérification SHA-1 pour les *commits* ont changé, mais les chaînes
`git-p4` ne sont plus dans les messages de *commit* :

``` highlight
$ git log -2
commit b17341801ed838d97f7800a54a6f9b95750839b7
Author: giles <giles@giles@perforce.com>
Date:   Wed Feb 8 03:13:27 2012 -0800

    Correction to line 355; change </UL> to </OL>.

commit 3e68c2e26cd89cb983eb52c024ecdfba1d6b3fff
Author: kwirth <kwirth@perforce.com>
Date:   Tue Jul 7 01:35:51 2009 -0800

    Fix spelling error on Jam doc page (cummulative -> cumulative).
```

Votre import est prêt à être poussé vers votre nouveau serveur Git.

### TFS

Si votre équipe est en train de convertir son code source de TFVC à Git,
vous voudrez la conversion de la plus haute fidélité que vous puissiez
obtenir. Cela signifie que, tandis que nous couvrions à la fois git-tfs
et git-tf pour la section interop, nous couvrirons seulement git-tfs
dans cette partie, parce que git-tfs supporte les branches, et c’est
excessivement difficile en utilisant git-tf.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Ceci est une conversion à sens unique. Le dépôt Git résultant ne pourra pas se connecter au projet TFVC original.</p>
</div></td>
</tr>
</tbody>
</table>

La première chose à faire est d’associer les noms d’utilisateur. TFC est
assez permissif pour ce qui va dans le champ auteur pour les
changements, mais Git veut un nom et une adresse de courriel lisibles
par un humain. Vous pouvez obtenir cette information depuis la ligne de
commande client `tf`, comme ceci :

``` highlight
PS> tf history $/myproject -recursive > AUTHORS_TMP
```

Cela récupère toutes les modifications de l’historique du projet et les
insère dans le fichier AUTHORS\_TMP que nous traiterons pour en extraire
la donnée de la colonne *Utilisateur* (la deuxième). Ouvrez le fichier
et trouvez à quels caractères commence et finit la colonne et remplacez,
dans la ligne de commande suivante, les paramètres `11-20` de la
commande `cut` par ceux que vous avez trouvés :

``` highlight
PS> cat AUTHORS_TMP | cut -b 11-20 | tail -n+3 | sort | uniq > AUTHORS
```

La commande `cut` ignore tout sauf les caractères 11-20 de chaque ligne.
La commande `tail` saute les deux premières lignes, qui sont des champs
d’en-tête et des soulignés dans le style ASCII. Le résultat de tout ceci
est envoyé à `sort` et `uniq` pour éliminer les doublons, et sauvé dans
un fichier nommé `AUTHORS`. L’étape suivante est manuelle ; afin que
git-tfs fasse un usage effectif de ce fichier, chaque ligne doit être
dans ce format :

``` highlight
DOMAIN\username = User Name <email@address.com>
```

La partie gauche est le champ “utilisateur” de TFVC, et la partie droite
du signe égal est le nom d’utilisateur qui sera utilisé pour les
*commits* Git.

Une fois que vous avez ce fichier, la chose suivante à faire est de
faire un clone complet du projet TFVC par lequel vous êtes intéressé :

``` highlight
PS> git tfs clone --with-branches --authors=AUTHORS https://username.visualstudio.com/DefaultCollection $/project/Trunk project_git
```

Ensuite vous voudrez nettoyer les sections `git-tfs-id` du bas des
messages de commit. La commande suivante le fera :

``` highlight
PS> git filter-branch -f --msg-filter 'sed "s/^git-tfs-id:.*$//g"' '--' --all
```

Cela utilise la commande `sed` de l’environnement Git-bash pour
remplacer n’importe quelle ligne commençant par "git-tfs-id:" par du
vide que Git ignorera ensuite.

Une fois cela fait, vous êtes prêt à ajouter un nouveau serveur distant,
y pousser toutes les branches, et vous avez votre équipe prête à
commencer à travailler depuis Git.

### Un importateur personnalisé

Si votre système n’est pas un de ceux ci-dessus, vous devriez chercher
un importateur en ligne – des importateurs de qualité sont disponibles
pour plein d’autres systèmes, incluant CVS, Clear Case, Visual Source
Safe, même un dossier d’archives. Si aucun de ces outils ne fonctionne
pour vous, vous avez un outil plus obscur, ou alors vous avez besoin
d’un procédé d’importation personnalisé, vous devriez utiliser
`git fast-import`. Cette commande lit des instructions simples depuis
l’entrée standard pour écrire des données Git spécifiques. Il est bien
plus facile de créer des objets Git de cette façon que de lancer des
commandes Git brutes ou que d’essayer d’écrire les objets bruts (voir
[Les tripes de Git](#ch10-git-internals) pour plus d’informations). De
cette façon, vous pouvez écrire un script d’importation qui lit
l’information nécessaire hors du système duquel vous importez et qui
affiche les instructions directement dans la sortie standard. Vous
pouvez alors lancer ce programme et envoyer sa sortie à travers un tube
dans `git fast-import`.

Pour démontrer rapidement, vous écrirez un importateur simple. Supposez
que vous travaillez dans `current`, vous sauvegardez votre projet en
copiant occasionnellement le dossier dans un dossier de sauvegarde
estampillé de la date `back_YYYY_MM_DD`, et vous voulez importer cela
dans Git. Votre structure de dossier ressemble à ceci :

``` highlight
$ ls /opt/import_from
back_2014_01_02
back_2014_01_04
back_2014_01_14
back_2014_02_03
current
```

Pour importer un dossier Git, vous devez passer en revue comment Git
stocke ses données. Comme vous vous le rappelez, Git est
fondamentalement une liste liée d’objets *commit* qui pointent sur un
instantané de contenu. Tout ce que vous avez à faire est de dire à
`fast-import` ce que sont les instantanés de contenu, quelles données de
*commit* pointent sur eux, et l’ordre dans lequel ils vont. Votre
stratégie sera d’explorer les instantanés un à un et créer les *commits*
avec les contenus dans chaque dossier, en liant chaque *commit* avec le
précédent.

Comme nous l’avons fait dans [Exemple de politique gérée par
Git](#s_an_example_git_enforced_policy), nous écrirons ceci en Ruby,
parce que c’est ce avec quoi nous travaillons généralement et ça a
tendance à être facile à lire. Vous pouvez écrire cet exemple assez
facilement avec n’importe quel langage de programmation auquel vous êtes
familier – il faut seulement afficher l’information appropriée dans
`stdout`. Et, si vous travaillez sous Windows, cela signifie que vous
devrez prendre un soin particulier à ne pas introduire de retour chariot
(carriage return, CR) à la fin de vos lignes – `git fast-import` est
très exigeant ; il accepte seulement la fin de ligne (Line Feed, LF) et
pas le retour chariot fin de ligne (CRLF) que Windows utilise.

Pour commencer, vous vous placerez dans le dossier cible et identifierez
chaque sous-dossier, chacun étant un instantané que vous voulez importer
en tant que *commit*. Vous vous placerez dans chaque sous-dossier et
afficherez les commandes nécessaires pour l’exporter. Votre boucle
basique principale ressemble à ceci :

``` highlight
last_mark = nil

# boucle sur les dossiers
Dir.chdir(ARGV[0]) do
  Dir.glob("*").each do |dir|
    next if File.file?(dir)

    # rentre dans chaque dossier cible
    Dir.chdir(dir) do
      last_mark = print_export(dir, last_mark)
    end
  end
end
```

Vous lancez `print_export` à l’intérieur de chaque dossier, qui prend le
manifeste et la marque de l’instantané précédent et retourne la marque
et l’empreinte de celui-ci ; de cette façon, vous pouvez les lier
proprement. “Marque” est le terme de `fast-import` pour un identifiant
que vous donnez à un *commit* ; au fur et à mesure que vous créez des
*commits*, vous donnez à chacun une marque que vous pouvez utiliser pour
le lier aux autres *commits*. Donc, la première chose à faire dans votre
méthode `print_export` est de générer une marque à partir du nom du
dossier :

``` highlight
mark = convert_dir_to_mark(dir)
```

Vous ferez ceci en créant un tableau de dossiers et en utilisant la
valeur d’index comme marque, car une marque doit être un nombre entier.
Votre méthode ressemble à ceci :

``` highlight
$marks = []
def convert_dir_to_mark(dir)
  if !$marks.include?(dir)
    $marks << dir
  end
  ($marks.index(dir) + 1).to_s
end
```

Maintenant que vous avez une représentation par un entier de votre
*commit*, vous avez besoin d’une date pour les métadonnées du *commit*.
Puisque la date est exprimée dans le nom du dossier, vous l’analyserez.
La ligne suivante dans votre fichier `print_export` est

``` highlight
date = convert_dir_to_date(dir)
```

où `convert_dir_to_date` est définie comme

``` highlight
def convert_dir_to_date(dir)
  if dir == 'current'
    return Time.now().to_i
  else
    dir = dir.gsub('back_', '')
    (year, month, day) = dir.split('_')
    return Time.local(year, month, day).to_i
  end
end
```

Cela retourne une valeur entière pour la date de chaque dossier. Le
dernier bout de méta-information dont vous avez besoin pour chaque
*commit* est la donnée de l’auteur, que vous codez en dur dans une
variable globale :

``` highlight
$author = 'John Doe <john@example.com>'
```

Maintenant vous êtes prêt à commencer à publier l’information de
*commit* pour votre importateur. L’information initiale déclare que vous
êtes en train de définir un objet *commit* et sur quelle branche il est,
suivi de la marque que vous avez générée, l’information d’auteur et le
message de *commit*, et ensuite le précédent *commit*, s’il y en a un.
Le code ressemble à ceci :

``` highlight
# affiche l'information d'import
puts 'commit refs/heads/master'
puts 'mark :' + mark
puts "committer #{$author} #{date} -0700"
export_data('imported from ' + dir)
puts 'from :' + last_mark if last_mark
```

Vous codez en dur le fuseau horaire (-0700) parce que c’est facile de
faire ainsi. Si vous importez depuis un autre système, vous devez
spécifier le fuseau horaire comme décalage. Le message de *commit* doit
être exprimé dans un format spécial :

``` highlight
data (taille)\n(contenu)
```

Le format est constitué du mot data, de la taille de la donnée à lire,
d’une nouvelle ligne et finalement de la donnée. Comme vous avez besoin
d’utiliser le même format pour spécifier le contenu du fichier plus
tard, vous créez une méthode assistante, `export_data` :

``` highlight
def export_data(string)
  print "data #{string.size}\n#{string}"
end
```

Tout ce qui reste à faire est de spécifier le contenu du fichier pour
chaque instantané. C’est facile, car vous les avez dans un dossier –
vous pouvez imprimer la commande `deleteall` suivie par le contenu de
chaque fichier du dossier. Git enregistrera ensuite chaque instantané de
manière appropriée :

``` highlight
puts 'deleteall'
Dir.glob("**/*").each do |file|
  next if !File.file?(file)
  inline_data(file)
end
```

Note : Comme beaucoup de systèmes conçoivent leurs révisions comme des
changements d’un *commit* à l’autre, fast-import peut aussi prendre des
commandes avec chaque *commit* pour spécifier quels fichiers ont été
ajoutés, supprimés ou modifiés et ce qu’est le nouveau contenu. Vous
pourriez calculer les différences entre instantanés et fournir seulement
cette donnée, mais faire ainsi est plus complexe – vous pouvez aussi
bien donner à Git toutes les données et le laisser faire. Si cela
convient mieux pour vos données, référez-vous à la page de manuel
`fast-import` pour les détails sur la manière de fournir les données de
cette façon.

Le format pour lister le contenu d’un nouveau fichier ou pour spécifier
un fichier modifié avec le nouveau contenu est le suivant :

``` highlight
M 644 inline path/to/file
data (taille)
(contenu du fichier)
```

Ici, 644 est le mode (si vous avez des fichiers exécutables, vous devez
le détecter et spécifier 755 à la place), et `inline` dit que vous
listerez le contenu immédiatement après cette ligne. Votre méthode
`inline_data` ressemble à ceci :

``` highlight
def inline_data(file, code = 'M', mode = '644')
  content = File.read(file)
  puts "#{code} #{mode} inline #{file}"
  export_data(content)
end
```

Vous réutilisez la méthode `export_data` que vous avez définie plus tôt,
parce que c’est de la même façon que vous avez spécifié vos données du
message de *commit*.

La dernière chose que vous avez besoin de faire est de retourner la
marque courante pour qu’elle soit passée à la prochaine itération :

``` highlight
return mark
```

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Si vous êtes sous Windows, vous devrez vous assurer d’ajouter une étape supplémentaire. Comme mentionné précédemment, Windows utilise CRLF comme caractères de fin de ligne alors que <code>git fast-import</code> ne s’attend qu’à LF. Pour contourner ce problème et satisfaire <code>git fast-import</code>, vous devez indiquer à Ruby d’utiliser LF au lieu de CRLF :</p>
</div>
<div class="listingblock">
<div class="content">
<pre class="highlight"><code>$stdout.binmode</code></pre>
</div>
</div></td>
</tr>
</tbody>
</table>

Et voilà. Voici le script dans son intégralité :

``` highlight
#!/usr/bin/env ruby

$stdout.binmode
$author = "John Doe <john@example.com>"

$marks = []
def convert_dir_to_mark(dir)
    if !$marks.include?(dir)
        $marks << dir
    end
    ($marks.index(dir)+1).to_s
end


def convert_dir_to_date(dir)
    if dir == 'current'
        return Time.now().to_i
    else
        dir = dir.gsub('back_', '')
        (year, month, day) = dir.split('_')
        return Time.local(year, month, day).to_i
    end
end

def export_data(string)
    print "data #{string.size}\n#{string}"
end

def inline_data(file, code='M', mode='644')
    content = File.read(file)
    puts "#{code} #{mode} inline #{file}"
    export_data(content)
end

def print_export(dir, last_mark)
    date = convert_dir_to_date(dir)
    mark = convert_dir_to_mark(dir)

    puts 'commit refs/heads/master'
    puts "mark :#{mark}"
    puts "committer #{$author} #{date} -0700"
    export_data("imported from #{dir}")
    puts "from :#{last_mark}" if last_mark

    puts 'deleteall'
    Dir.glob("**/*").each do |file|
        next if !File.file?(file)
        inline_data(file)
    end
    mark
end


# explore les dossiers
last_mark = nil
Dir.chdir(ARGV[0]) do
    Dir.glob("*").each do |dir|
        next if File.file?(dir)

        # move into the target directory
        Dir.chdir(dir) do
            last_mark = print_export(dir, last_mark)
        end
    end
end
```

Si vous lancez ce script, vous obtiendrez un contenu qui ressemble à peu
près à ceci :

``` highlight
$ ruby import.rb /opt/import_from
commit refs/heads/master
mark :1
committer John Doe <john@example.com> 1388649600 -0700
data 29
imported from back_2014_01_02deleteall
M 644 inline README.md
data 28
# Hello

This is my readme.
commit refs/heads/master
mark :2
committer John Doe <john@example.com> 1388822400 -0700
data 29
imported from back_2014_01_04from :1
deleteall
M 644 inline main.rb
data 34
#!/bin/env ruby

puts "Hey there"
M 644 inline README.md
(...)
```

Pour lancer l’importateur, envoyez à travers un tube cette sortie à
`git fast-import` pendant que vous êtes dans le dossier Git dans lequel
vous voulez importer. Vous pouvez créer un nouveau dossier et ensuite
exécuter `git init` à l’intérieur de celui-ci comme point de départ, et
ensuite exécuter votre script :

``` highlight
$ git init
Initialized empty Git repository in /opt/import_to/.git/
$ ruby import.rb /opt/import_from | git fast-import
git-fast-import statistics:
---------------------------------------------------------------------
Alloc'd objects:       5000
Total objects:           13 (         6 duplicates                  )
      blobs  :            5 (         4 duplicates          3 deltas of          5 attempts)
      trees  :            4 (         1 duplicates          0 deltas of          4 attempts)
      commits:            4 (         1 duplicates          0 deltas of          0 attempts)
      tags   :            0 (         0 duplicates          0 deltas of          0 attempts)
Total branches:           1 (         1 loads     )
      marks:           1024 (         5 unique    )
      atoms:              2
Memory total:          2344 KiB
       pools:          2110 KiB
     objects:           234 KiB
---------------------------------------------------------------------
pack_report: getpagesize()            =       4096
pack_report: core.packedGitWindowSize = 1073741824
pack_report: core.packedGitLimit      = 8589934592
pack_report: pack_used_ctr            =         10
pack_report: pack_mmap_calls          =          5
pack_report: pack_open_windows        =          2 /          2
pack_report: pack_mapped              =       1457 /       1457
---------------------------------------------------------------------
```

Comme vous pouvez le voir, lorsque c’est terminé avec succès, il vous
donne un lot de statistiques sur ce qu’il a fait. Dans ce cas-ci, vous
avez importé un total de 13 objets pour 4 *commits* dans une branche.
Maintenant, vous pouvez lancer `git log` pour voir votre nouvel
historique :

``` highlight
$ git log -2
commit 3caa046d4aac682a55867132ccdfbe0d3fdee498
Author: John Doe <john@example.com>
Date:   Tue Jul 29 19:39:04 2014 -0700

    imported from current

commit 4afc2b945d0d3c8cd00556fbe2e8224569dc9def
Author: John Doe <john@example.com>
Date:   Mon Feb 3 01:00:00 2014 -0700

    imported from back_2014_02_03
```

Vous y voilà — un dépôt Git beau et propre. Il est important de noter
que rien n’est extrait – vous n’avez d’abord aucun fichier dans votre
répertoire de travail. Pour les obtenir, vous devez réinitialiser votre
branche là où `master` est maintenant :

``` highlight
$ ls
$ git reset --hard master
HEAD is now at 3caa046 imported from current
$ ls
README.md main.rb
```

Vous pouvez faire beaucoup plus avec l’outil `fast-import` – manipuler
différents modes, les données binaires, les branches multiples et la
fusion, les étiquettes, les indicateurs de progression, et plus encore.
Nombre d’exemples de scénarios plus complexes sont disponibles dans le
dossier `contrib/fast-import` du code source Git.

## Résumé

Vous devriez être à l’aise en utilisant Git comme client pour d’autres
systèmes de contrôle de version, ou en important presque n’importe quel
dépôt existant dans Git sans perdre de donnée. Dans le prochain
chapitre, nous couvrirons les tripes brutes de Git afin que vous
puissiez travailler chaque octet, si besoin est.
