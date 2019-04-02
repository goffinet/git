# Les branches avec Git

<!-- toc -->

Presque tous les VCS proposent une certaine forme de gestion de
branches. Créer une branche signifie diverger de la ligne principale de
développement et continuer à travailler sans impacter cette ligne. Pour
de nombreux VCS, il s’agit d’un processus coûteux qui nécessite souvent
la création d’une nouvelle copie du répertoire de travail, ce qui peut
prendre longtemps dans le cas de gros projets.

Certaines personnes considèrent le modèle de gestion de branches de Git
comme ce qu’il a de plus remarquable et il offre sûrement à Git une
place à part au sein de la communauté des VCS. En quoi est-il si spécial
? La manière dont Git gère les branches est incroyablement légère et
permet de réaliser les opérations sur les branches de manière quasi
instantanée et, généralement, de basculer entre les branches aussi
rapidement. À la différence de nombreux autres VCS, Git encourage des
méthodes qui privilégient la création et la fusion fréquentes de
branches, jusqu’à plusieurs fois par jour. Bien comprendre et maîtriser
cette fonctionnalité vous permettra de faire de Git un outil puissant et
unique et peut totalement changer votre manière de développer.

## Les branches en bref

Pour réellement comprendre la manière dont Git gère les branches, nous
devons revenir en arrière et examiner de plus près comment Git stocke
ses données. Si vous vous souvenez bien du chapitre [Démarrage
rapide](#ch01-introduction), Git ne stocke pas ses données comme une
série de modifications ou de différences successives mais plutôt comme
une série d’instantanés (appelés *snapshots*).

Lorsque vous faites un commit, Git stocke un objet *commit* qui contient
un pointeur vers l’instantané (*snapshot*) du contenu que vous avez
indexé. Cet objet contient également les noms et prénoms de l’auteur, le
message que vous avez renseigné ainsi que des pointeurs vers le ou les
*commits* qui précèdent directement ce *commit* : aucun parent pour le
*commit* initial, un parent pour un *commit* normal et de multiples
parents pour un *commit* qui résulte de la fusion d’une ou plusieurs
branches.

Pour visualiser ce concept, supposons que vous avez un répertoire
contenant trois fichiers que vous indexez puis validez. L’indexation des
fichiers calcule une empreinte (*checksum*) pour chacun (via la fonction
de hachage SHA-1 mentionnée au chapitre [Démarrage
rapide](#ch01-introduction)), stocke cette version du fichier dans le
dépôt Git (Git les nomme *blobs*) et ajoute cette empreinte à la zone
d’index (*staging area*) :

``` highlight
$ git add README test.rb LICENSE
$ git commit -m 'initial commit of my project'
```

Lorsque vous créez le *commit* en lançant la commande `git commit`, Git
calcule l’empreinte de chaque sous-répertoire (ici, seulement pour le
répertoire racine) et stocke ces objets de type arbre dans le dépôt Git.
Git crée alors un objet *commit* qui contient les méta-données et un
pointeur vers l’arbre de la racine du projet de manière à pouvoir
recréer l’instantané à tout moment.

Votre dépôt Git contient à présent cinq objets : un *blob* pour le
contenu de chacun de vos trois fichiers, un arbre (*tree*) qui liste le
contenu du répertoire et spécifie quels noms de fichiers sont attachés à
quels *blobs* et enfin un objet *commit* portant le pointeur vers
l’arbre de la racine ainsi que toutes les méta-données attachées au
*commit*.

![Un commit et son arbre.](images/commit-and-tree.png)

Figure 9. Un commit et son arbre

Si vous faites des modifications et validez à nouveau, le prochain
*commit* stocke un pointeur vers le *commit* le précédant immédiatement.

![Commits et leurs parents.](images/commits-and-parents.png)

Figure 10. Commits et leurs parents

Une branche dans Git est simplement un pointeur léger et déplaçable vers
un de ces *commits*. La branche par défaut dans Git s’appelle `master`.
Au fur et à mesure des validations, la branche `master` pointe vers le
dernier des *commits* réalisés. À chaque validation, le pointeur de la
branche `master` avance automatiquement.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>La branche ``master`` n’est pas une branche spéciale. Elle est identique à toutes les autres branches. La seule raison pour laquelle chaque dépôt en a une est que la commande <code>git init</code> la crée par défaut et que la plupart des gens ne s’embêtent pas à la changer.</p>
</div></td>
</tr>
</tbody>
</table>

![Une branche et l’historique de ses
\_commits\_.](images/branch-and-history.png)

Figure 11. Une branche et l’historique de ses *commits*

### Créer une nouvelle branche

Que se passe-t-il si vous créez une nouvelle branche ? Eh bien, cela
crée un nouveau pointeur pour vous. Supposons que vous créez une
nouvelle branche nommée `test`. Vous utilisez pour cela la commande
`git branch` :

``` highlight
$ git branch testing
```

Cela crée un nouveau pointeur vers le *commit* courant.

![Deux branches pointant vers la même série de
\_commits\_.](images/two-branches.png)

Figure 12. Deux branches pointant vers la même série de *commits*

Comment Git connaît-il alors la branche sur laquelle vous vous trouvez ?
Il conserve à cet effet un pointeur spécial appelé `HEAD`. Vous
remarquez que sous cette appellation se cache un concept très différent
de celui utilisé dans les autres VCS tels que Subversion ou CVS. Dans
Git, il s’agit simplement d’un pointeur sur la branche locale où vous
vous trouvez. Dans ce cas, vous vous trouvez toujours sur `master`. En
effet, la commande `git branch` n’a fait que créer une nouvelle branche
— elle n’a pas fait basculer la copie de travail vers cette branche.

![HEAD pointant vers une branche.](images/head-to-master.png)

Figure 13. HEAD pointant vers une branche

Vous pouvez vérifier cela facilement grâce à la commande `git log` qui
vous montre vers quoi les branches pointent. Il s’agit de l’option
`--decorate`.

``` highlight
$ git log --oneline --decorate
f30ab (HEAD, master, test) add feature #32 - ability to add new
34ac2 fixed bug #ch1328 - stack overflow under certain conditions
98ca9 initial commit of my project
```

Vous pouvez voir les branches \`\`master\`\` et \`\`test\`\` qui se
situent au niveau du *commit* `f30ab`.

### Basculer entre les branches

Pour basculer sur une branche existante, il suffit de lancer la commande
`git checkout`. Basculons sur la nouvelle branche `testing` :

``` highlight
$ git checkout testing
```

Cela déplace `HEAD` pour le faire pointer vers la branche `testing`.

![HEAD pointe vers la branche courante.](images/head-to-testing.png)

Figure 14. HEAD pointe vers la branche courante

Qu’est-ce que cela signifie ? Et bien, faisons une autre validation :

``` highlight
$ vim test.rb
$ git commit -a -m 'made a change'
```

![La branche HEAD avance à chaque
\_commit\_.](images/advance-testing.png)

Figure 15. La branche HEAD avance à chaque *commit*

C’est intéressant parce qu’à présent, votre branche `test` a avancé
tandis que la branche `master` pointe toujours sur le *commit* sur
lequel vous étiez lorsque vous avez lancé la commande `git checkout`
pour changer de branche. Retournons sur la branche `master` :

``` highlight
$ git checkout master
```

![HEAD est déplacé lors d’un \_checkout\_.](images/checkout-master.png)

Figure 16. HEAD est déplacé lors d’un *checkout*

Cette commande a réalisé deux actions. Elle a remis le pointeur `HEAD`
sur la branche `master` et elle a replacé les fichiers de votre
répertoire de travail dans l’état du *snapshot* pointé par `master`.
Cela signifie aussi que les modifications que vous réalisez à partir de
ce point divergeront de l’ancienne version du projet. Cette commande
annule les modifications réalisées dans la branche `test` pour vous
permettre de repartir dans une autre direction.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="title">
Changer de branche modifie les fichiers dans votre répertoire de travail
</div>
<div class="paragraph">
<p>Il est important de noter que lorsque vous changez de branche avec Git, les fichiers de votre répertoire de travail sont modifiés. Si vous basculez vers une branche plus ancienne, votre répertoire de travail sera remis dans l’état dans lequel il était lors du dernier <em>commit</em> sur cette branche. Si git n’est pas en mesure d’effectuer cette action proprement, il ne vous laissera pas changer de branche.</p>
</div></td>
</tr>
</tbody>
</table>

Réalisons quelques autres modifications et validons à nouveau :

``` highlight
$ vim test.rb
$ git commit -a -m 'made other changes'
```

Maintenant, l’historique du projet a divergé (voir [Divergence
d’historique](#divergent_history)). Vous avez créé une branche et
basculé dessus, y avez réalisé des modifications, puis vous avez
rebasculé sur la branche principale et réalisé d’autres modifications.
Ces deux modifications sont isolées dans des branches séparées : vous
pouvez basculer d’une branche à l’autre et les fusionner quand vous êtes
prêt. Et vous avez fait tout ceci avec de simples commandes : `branch`,
`checkout` et `commit`.

![Divergence d’historique.](images/advance-master.png)

Figure 17. Divergence d’historique

Vous pouvez également voir ceci grâce à la commande `git log`. La
commande `git log --oneline --decorate --graph --all` va afficher
l’historique de vos *commits*, affichant les endroits où sont
positionnés vos pointeurs de branche ainsi que la manière dont votre
historique a divergé.

``` highlight
$ git log --oneline --decorate --graph --all
* c2b9e (HEAD, master) made other changes
| * 87ab2 (test) made a change
|/
* f30ab add feature #32 - ability to add new formats to the
* 34ac2 fixed bug #ch1328 - stack overflow under certain conditions
* 98ca9 initial commit of my project
```

Parce qu’une branche Git n’est en fait qu’un simple fichier contenant
les 40 caractères de l’empreinte SHA-1 du *commit* sur lequel elle
pointe, les branches ne coûtent quasiment rien à créer et à détruire.
Créer une branche est aussi simple et rapide qu’écrire 41 caractères
dans un fichier (40 caractères plus un retour chariot).

C’est une différence de taille avec la manière dont la plupart des VCS
gèrent les branches, qui implique de copier tous les fichiers du projet
dans un second répertoire. Cela peut durer plusieurs secondes ou même
quelques minutes selon la taille du projet, alors que pour Git, le
processus est toujours instantané. De plus, comme nous enregistrons les
parents quand nous validons les modifications, la détermination de
l’ancêtre commun approprié pour la fusion est réalisée automatiquement
pour nous et est généralement une opération très facile. Ces
fonctionnalités encouragent naturellement les développeurs à créer et
utiliser souvent des branches.

Voyons pourquoi vous devriez en faire autant.

## Branches et fusions : les bases

Prenons un exemple simple faisant intervenir des branches et des fusions
(*merges*) que vous pourriez trouver dans le monde réel. Vous effectuez
les tâches suivantes :

1.  vous travaillez sur un site web ;

2.  vous créez une branche pour un nouvel article en cours ;

3.  vous commencez à travailler sur cette branche.

À cette étape, vous recevez un appel pour vous dire qu’un problème
critique a été découvert et qu’il faut le régler au plus tôt. Vous
faites donc ce qui suit :

1.  vous basculez sur la branche de production ;

2.  vous créez une branche pour y ajouter le correctif ;

3.  après l’avoir testé, vous fusionnez la branche du correctif et
    poussez le résultat en production ;

4.  vous rebasculez sur la branche initiale et continuez votre travail.

### Branches

Commençons par supposer que vous travaillez sur votre projet et avez
déjà quelques *commits*.

![Historique de \_commits\_ simple.](images/basic-branching-1.png)

Figure 18. Historique de *commits* simple

Vous avez décidé de travailler sur le problème numéroté \#53 dans
l’outil de gestion des tâches que votre entreprise utilise, quel qu’il
soit. Pour créer une branche et y basculer tout de suite, vous pouvez
lancer la commande `git checkout` avec l’option `-b` :

``` highlight
$ git checkout -b iss53
Switched to a new branch "iss53"
```

Cette commande est un raccourci pour :

``` highlight
$ git branch iss53
$ git checkout iss53
```

![Création d’un nouveau pointeur de
branche.](images/basic-branching-2.png)

Figure 19. Création d’un nouveau pointeur de branche

Vous travaillez sur votre site web et validez vos modifications. Ce
faisant, la branche `iss53` avance parce que vous l’avez extraite
(c’est-à-dire que votre pointeur `HEAD` pointe dessus) :

``` highlight
$ vim index.html
$ git commit -a -m "ajout d'un pied de page [problème 53]"
```

![La branche iss53 a avancé avec votre
travail.](images/basic-branching-3.png)

Figure 20. La branche iss53 a avancé avec votre travail

À ce moment-là, vous recevez un appel qui vous apprend qu’il y a un
problème sur le site web qu’il faut résoudre immédiatement. Avec Git,
vous n’avez pas à déployer en même temps votre correctif et les
modifications déjà validées pour `iss53` et vous n’avez pas non plus à
vous fatiguer à annuler ces modifications avant de pouvoir appliquer
votre correctif sur ce qu’il y a en production. Tout ce que vous avez à
faire, c’est simplement de rebasculer sur la branche `master`.

Cependant, avant de le faire, notez que si votre copie de travail ou
votre zone d’index contiennent des modifications non validées qui sont
en conflit avec la branche que vous extrayez, Git ne vous laissera pas
changer de branche. Le mieux est d’avoir votre copie de travail propre
au moment de changer de branche. Il y a des moyens de contourner ceci
(précisément par le remisage et l’amendement de *commit*) dont nous
parlerons plus loin, au chapitre [Remisage et
nettoyage](#s_git_stashing). Pour l’instant, nous supposons que vous
avez validé tous vos changements et que vous pouvez donc rebasculer vers
votre branche `master` :

``` highlight
$ git checkout master
Switched to branch 'master'
```

À cet instant, votre répertoire de copie de travail est exactement dans
l’état dans lequel vous l’aviez laissé avant de commencer à travailler
sur le problème \#53 et vous pouvez vous consacrer à votre correctif.
C’est un point important à garder en mémoire : quand vous changez de
branche, Git réinitialise votre répertoire de travail pour qu’il soit le
même que la dernière fois que vous avez effectué un *commit* sur cette
branche. Il ajoute, retire et modifie automatiquement les fichiers de
manière à s’assurer que votre copie de travail soit identique à ce
qu’elle était lors de votre dernier *commit* sur cette branche.

Vous avez ensuite un correctif à faire. Pour ce faire, créons une
branche `correctif` sur laquelle travailler jusqu’à résolution du
problème :

``` highlight
$ git checkout -b correctif
Switched to a new branch 'correctif'
$ vim index.html
$ git commit -a -m "correction de l'adresse email incorrecte"
[correctif 1fb7853] "correction de l'adresse email incorrecte"
 1 file changed, 2 insertions(+)
```

![Branche de correctif basée sur
\`master\`.](images/basic-branching-4.png)

Figure 21. Branche de correctif basée sur `master`

Vous pouvez lancer vos tests, vous assurer que la correction est
efficace et la fusionner dans la branche `master` pour la déployer en
production. Vous réalisez ceci au moyen de la commande `git merge` :

``` highlight
$ git checkout master
$ git merge correctif
Updating f42c576..3a0874c
Fast-forward
 index.html | 2 ++
 1 file changed, 2 insertions(+)
```

Vous noterez la mention `fast-forward` lors de cette fusion (*merge*).
Comme le *commit* `C4` pointé par la branche `hotfix` que vous avez
fusionnée était directement devant le *commit* `C2` sur lequel vous vous
trouvez, Git a simplement déplacé le pointeur (vers l’avant). Autrement
dit, lorsque l’on cherche à fusionner un *commit* qui peut être atteint
en parcourant l’historique depuis le *commit* d’origine, Git se contente
d’avancer le pointeur car il n’y a pas de travaux divergents à fusionner
— ceci s’appelle un `fast-forward` (avance rapide).

Votre modification est maintenant dans l’instantané (*snapshot*) du
*commit* pointé par la branche `master` et vous pouvez déployer votre
correctif.

![Avancement du pointeur de \`master\` sur
\`correctif\`.](images/basic-branching-5.png)

Figure 22. Avancement du pointeur de `master` sur `correctif`

Après le déploiement de votre correctif super-important, vous voilà prêt
à retourner travailler sur le sujet qui vous occupait avant
l’interruption. Cependant, vous allez avant cela effacer la branche
`correctif` dont vous n’avez plus besoin puisque la branche `master`
pointe au même endroit. Vous pouvez l’effacer avec l’option `-d` de la
commande `git branch` :

``` highlight
$ git branch -d correctif
Deleted branch correctif (3a0874c).
```

Maintenant, vous pouvez retourner travailler sur la branche qui contient
vos travaux en cours pour le problème \#53 :

``` highlight
$ git checkout iss53
Switched to branch "iss53"
$ vim index.html
$ git commit -a -m 'Nouveau pied de page terminé [issue 53]'
[iss53 ad82d7a] Nouveau pied de page terminé [issue 53]
1 file changed, 1 insertion(+)
```

![Le travail continue sur \`iss53\`.](images/basic-branching-6.png)

Figure 23. Le travail continue sur `iss53`

Il est utile de noter que le travail réalisé dans la branche `correctif`
n’est pas contenu dans les fichiers de la branche `iss53`. Si vous avez
besoin de les y rapatrier, vous pouvez fusionner la branche `master`
dans la branche `iss53` en lançant la commande `git merge master`, ou
vous pouvez retarder l’intégration de ces modifications jusqu’à ce que
vous décidiez plus tard de rapatrier la branche `iss53` dans `master`.

### Fusions (*Merges*)

Supposons que vous ayez décidé que le travail sur le problème \#53 était
terminé et prêt à être fusionné dans la branche `master`. Pour ce faire,
vous allez fusionner votre branche `iss53` de la même manière que vous
l’avez fait plus tôt pour la branche `correctif`. Tout ce que vous avez
à faire est d’extraire la branche dans laquelle vous souhaitez fusionner
et lancer la commande `git merge`:

``` highlight
$ git checkout master
Switched to branch 'master'
$ git merge iss53
Merge made by the 'recursive' strategy.
README |    1 +
1 file changed, 1 insertion(+)
```

Le comportement semble légèrement différent de celui observé pour la
fusion précédente de la branche `correctif`. Dans ce cas, à un certain
moment, l’historique de développement a divergé. Comme le *commit* sur
la branche sur laquelle vous vous trouvez n’est plus un ancêtre direct
de la branche que vous cherchez à fusionner, Git doit effectuer quelques
actions. Dans ce cas, Git réalise une simple fusion à trois sources
(*three-way merge*), en utilisant les deux instantanés pointés par les
sommets des branches ainsi que leur plus proche ancêtre commun.

![Trois instantanés utilisés dans une fusion
classique.](images/basic-merging-1.png)

Figure 24. Trois instantanés utilisés dans une fusion classique

Au lieu d’avancer simplement le pointeur de branche, Git crée un nouvel
instantané qui résulte de la fusion à trois sources et crée
automatiquement un nouveau *commit* qui pointe dessus. On appelle ceci
un *commit* de fusion (*merge commit*) qui est spécial en cela qu’il a
plus d’un parent.

![Un \_commit\_ de fusion.](images/basic-merging-2.png)

Figure 25. Un *commit* de fusion

À présent que votre travail a été fusionné, vous n’avez plus besoin de
la branche `iss53`. Vous pouvez fermer le ticket dans votre outil de
suivi des tâches et supprimer la branche :

``` highlight
$ git branch -d iss53
```

### Conflits de fusions (*Merge conflicts*)

Quelques fois, le processus ci-dessus ne se déroule pas aussi bien. Si
vous avez modifié différemment la même partie du même fichier dans les
deux branches que vous souhaitez fusionner, Git ne sera pas capable de
réaliser proprement la fusion. Si votre résolution du problème \#53 a
modifié la même section de fichier que le `correctif`, vous obtiendrez
un conflit qui ressemblera à ceci :

``` highlight
$ git merge iss53
Auto-merging index.html
CONFLICT (content): Merge conflict in index.html
Automatic merge failed; fix conflicts and then commit the result.
```

Git n’a pas automatiquement créé le *commit* de fusion. Il a arrêté le
processus le temps que vous résolviez le conflit. Si vous voulez
vérifier, à tout moment après l’apparition du conflit, quels fichiers
n’ont pas été fusionnés, vous pouvez lancer la commande `git status` :

``` highlight
$ git status
On branch master
You have unmerged paths.
  (fix conflicts and run "git commit")

Unmerged paths:
  (use "git add <file>..." to mark resolution)

    both modified:      index.html

no changes added to commit (use "git add" and/or "git commit -a")
```

Tout ce qui comporte des conflits et n’a pas été résolu est listé comme
`unmerged`. Git ajoute des marques de résolution de conflit standards
dans les fichiers qui comportent des conflits, pour que vous puissiez
les ouvrir et résoudre les conflits manuellement. Votre fichier contient
des sections qui ressemblent à ceci :

``` highlight
<<<<<<< HEAD:index.html
<div id="footer">contact : email.support@github.com</div>
======
<div id="footer">
 please contact us at support@github.com
</div>
>>>>>>> iss53:index.html
```

Cela signifie que la version dans `HEAD` (votre branche `master`, parce
que c’est celle que vous aviez extraite quand vous avez lancé votre
commande de fusion) est la partie supérieure de ce bloc (tout ce qui se
trouve au-dessus de la ligne `=======`), tandis que la version de votre
branche `iss53` se trouve en dessous. Pour résoudre le conflit, vous
devez choisir une partie ou l’autre ou bien fusionner leurs contenus
vous-même. Par exemple, vous pourriez choisir de résoudre ce conflit en
remplaçant tout le bloc par ceci :

``` highlight
<div id="footer">
please contact us at email.support@github.com
</div>
```

Cette résolution comporte des éléments de chaque section et les lignes
`<<<<<<<`, `=======` et `>>>>>>>` ont été complètement effacées. Après
avoir résolu chacune de ces sections dans chaque fichier comportant un
conflit, lancez `git add` sur chaque fichier pour le marquer comme
résolu. Placer le fichier dans l’index marque le conflit comme résolu
pour Git.

Si vous souhaitez utiliser un outil graphique pour résoudre ces
conflits, vous pouvez lancer `git mergetool` qui démarre l’outil
graphique de fusion approprié et vous permet de naviguer dans les
conflits :

``` highlight
$ git mergetool

This message is displayed because 'merge.tool' is not configured.
See 'git mergetool --tool-help' or 'git help config' for more details.
'git mergetool' will now attempt to use one of the following tools:
opendiff kdiff3 tkdiff xxdiff meld tortoisemerge gvimdiff diffuse diffmerge ecmerge p4merge araxis bc3 codecompare vimdiff emerge
Merging:
index.html

Normal merge conflict for 'index.html':
  {local}: modified file
  {remote}: modified file
Hit return to start merge resolution tool (opendiff):
```

Si vous souhaitez utiliser un outil de fusion autre que celui par défaut
(Git a choisi `opendiff` dans ce cas car la commande a été lancée depuis
un Mac), vous pouvez voir tous les outils supportés après l’indication «
*of the following tools:* ». Entrez simplement le nom de l’outil que
vous préféreriez utiliser.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="paragraph">
<p>Si vous avez besoin d’outils plus avancés pour résoudre des conflits complexes, vous trouverez davantage d’informations au chapitre <a href="#s_advanced_merging">Fusion avancée</a>.</p>
</div></td>
</tr>
</tbody>
</table>

Après avoir quitté l’outil de fusion, Git vous demande si la fusion a
été réussie. Si vous répondez par la positive à l’outil, il ajoute le
fichier dans l’index pour le marquer comme résolu.

Vous pouvez lancer à nouveau la commande `git status` pour vérifier que
tous les conflits ont été résolus :

``` highlight
$ git status
On branch master
All conflicts fixed but you are still merging.
  (use "git commit" to conclude merge)

Changes to be committed:

    modified:   index.html
```

Si cela vous convient et que vous avez vérifié que tout ce qui
comportait des conflits a été ajouté à l’index, vous pouvez entrer la
commande `git commit` pour finaliser le *commit* de fusion. Le message
de validation par défaut ressemble à ceci :

``` highlight
Merge branch 'iss53'

Conflicts:
    index.html
#
# It looks like you may be committing a merge.
# If this is not correct, please remove the file
#   .git/MERGE_HEAD
# and try again.


# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
# On branch master
# All conflicts fixed but you are still merging.
#
# Changes to be committed:
#   modified:   index.html
#
```

Vous pouvez modifier ce message pour inclure les détails sur la manière
dont le conflit a été résolu si vous pensez que cela peut être utile
lors d’une revue ultérieure. Indiquez pourquoi vous avez fait ces choix,
si ce n’est pas clair.

## Gestion des branches

Maintenant que vous avez créé, fusionné et supprimé des branches,
regardons de plus près les outils de gestion des branches qui
s’avèreront utiles lors d’une utilisation intensive des branches.

La commande `git branch` permet en fait bien plus que la simple création
et suppression de branches. Si vous la lancez sans argument, vous
obtenez la liste des branches courantes :

``` highlight
$ git branch
  iss53
* master
  test
```

Notez le caractère `*` qui préfixe la branche `master` : il indique la
branche courante (c’est-à-dire la branche sur laquelle le pointeur
`HEAD` se situe). Ceci signifie que si, dans cette situation, vous
validez des modifications (grâce à `git commit`), le pointeur de la
branche `master` sera mis à jour pour inclure vos modifications. Pour
visualiser la liste des derniers *commits* sur chaque branche, vous
pouvez utiliser le commande `git branch -v` :

``` highlight
$ git branch -v
  iss53   93b412c fix javascript issue
* master  7a98805 Merge branch 'iss53'
  test 782fd34 add scott to the author list in the readmes
```

`--merged` et `--no-merged` sont des options très utiles qui permettent
de filtrer les branches de cette liste selon que vous les avez ou ne les
avez pas encore fusionnées avec la branche courante. Pour voir quelles
branches ont déjà été fusionnées dans votre branche courante, lancez
`git branch --merged` :

``` highlight
$ git branch --merged
  iss53
* master
```

Comme vous avez déjà fusionné `iss53` un peu plus tôt, vous la voyez
dans votre liste. Les branches de cette liste qui ne comportent pas le
préfixe `*` peuvent généralement être effacées sans risque au moyen de
`git branch -d` puisque vous avez déjà intégré leurs modifications dans
une autre branche et ne risquez donc pas de perdre quoi que ce soit.

Pour visualiser les branches qui contiennent des travaux qui n’ont pas
encore été fusionnés, vous pouvez utiliser la commande
`git branch --no-merged`  :

``` highlight
$ git branch --no-merged
  test
```

Ceci affiche votre autre branche. Comme elle contient des modifications
qui n’ont pas encore été intégrées, essayer de les supprimer par la
commande `git branch -d` se solde par un échec :

``` highlight
$ git branch -d test
error: The branch 'test' is not fully merged.
If you are sure you want to delete it, run 'git branch -D test'.
```

Si vous souhaitez réellement supprimer cette branche et perdre ainsi le
travail réalisé, vous pouvez tout de même forcer la suppression avec
l’option `-D`, comme l’indique le message.

## Travailler avec les branches

Maintenant que vous avez acquis les bases concernant les branches et les
fusions (*merges*), que pouvez-vous ou devez-vous en faire ? Ce chapitre
traite des différents processus que cette gestion de branche légère
permet de mettre en place, de manière à vous aider à décider si vous
souhaitez en incorporer un dans votre cycle de développement.

### Branches au long cours

Comme Git utilise une *fusion à 3 sources*, fusionner une même branche
dans une autre plusieurs fois sur une longue période est généralement
facile. Cela signifie que vous pouvez avoir plusieurs branches ouvertes
en permanence pour différentes phases de votre cycle de développement.
Vous pourrez fusionner régulièrement ces branches entre elles.

De nombreux développeurs travaillent avec Git selon une méthode qui
utilise cette approche. Il s’agit, par exemple, de n’avoir que du code
entièrement stable et testé dans leur branche `master` ou bien même
uniquement du code qui a été ou sera publié au sein d’une *release*. Ils
ont alors en parallèle une autre branche appelée `develop` ou `next`.
Cette branche accueille les développements en cours qui font encore
l’objet de tests de stabilité — cette branche n’est pas nécessairement
toujours stable mais quand elle le devient, elle peut être intégrée (via
une fusion) dans `master`. Cette branche permet d’intégrer des branches
thématiques (*topic branches* : branches de faible durée de vie telles
que votre branche `iss53`), une fois prêtes, de manière à s’assurer
qu’elles passent l’intégralité des tests et n’introduisent pas de bugs.

En réalité, nous parlons de pointeurs qui se déplacent le long des
lignes des *commits* réalisés. Les branches stables sont plus basses
dans l’historique des *commits* tandis que les branches des derniers
développements sont plus hautes dans l’historique.

![Vue linéaire de branches dans un processus de \_stabilité
progressive\_.](images/lr-branches-1.png)

Figure 26. Vue linéaire de branches dans un processus de *stabilité
progressive*

Il est généralement plus simple d’y penser en termes de silos de tâches
où un ensemble de *commits* évolue progressivement vers un silo plus
stable une fois qu’il a été complètement testé.

![Vue \_en silo\_ de branches dans un processus de \_stabilité
progressive\_.](images/lr-branches-2.png)

Figure 27. Vue *en silo* de branches dans un processus de *stabilité
progressive*

Vous pouvez reproduire ce schéma sur plusieurs niveaux de stabilité. Des
projets plus gros ont aussi une branche `proposed` ou `pu` (*proposed
updates*) qui intègre elle-même des branches qui ne sont pas encore
prêtes à être intégrées aux branches `next` ou `master`. L’idée est que
les branches évoluent à différents niveaux de stabilité : quand elles
atteignent un niveau plus stable, elles peuvent être fusionnées dans la
branche de stabilité supérieure. Une fois encore, disposer de multiples
branches au long cours n’est pas nécessaire mais s’avère souvent utile,
spécialement dans le cadre de projets importants et complexes.

### Les branches thématiques

Les branches thématiques, elles, sont utiles quelle que soit la taille
du projet. Une branche thématique est une branche ayant une courte durée
de vie créée et utilisée pour une fonctionnalité ou une tâche
particulière. C’est une méthode que vous n’avez probablement jamais
utilisée avec un autre VCS parce qu’il y est généralement trop lourd de
créer et fusionner des branches. Mais dans Git, créer, développer,
fusionner et supprimer des branches plusieurs fois par jour est monnaie
courante.

Vous avez déjà vu ces branches dans la section précédente avec les
branches `iss53` et `correctif` que vous avez créées. Vous y avez
réalisé quelques *commits* et vous les avez supprimées immédiatement
après les avoir fusionnées dans votre branche principale. Cette
technique vous permet de changer de contexte rapidement et complètement.
Parce que votre travail est isolé dans des silos où toutes les
modifications sont liées à une thématique donnée, il est beaucoup plus
simple de réaliser des revues de code. Vous pouvez conserver vos
modifications dans ces branches pendant des minutes, des jours ou des
mois puis les fusionner quand elles sont prêtes, indépendamment de
l’ordre dans lequel elles ont été créées ou traitées.

Prenons l’exemple suivant : alors que vous développez (sur `master`),
vous créez une nouvelle branche pour un problème (`prob91`), travaillez
un peu sur ce problème puis créez une seconde branche pour essayer de
trouver une autre manière de le résoudre (`prob91v2`). Vous retournez
ensuite sur la branche `master` pour y travailler pendant un moment puis
finalement créez une dernière branche (`ideeidiote`) contenant une idée
dont vous doutez de la pertinence. Votre historique de *commits*
pourrait ressembler à ceci :

![Branches thématiques multiples.](images/topic-branches-1.png)

Figure 28. Branches thématiques multiples

Maintenant, supposons que vous décidiez que vous préférez la seconde
solution pour le problème (`prob91v2`) et que vous ayez montré la
branche `ideeidiote` à vos collègues qui vous ont dit qu’elle était
géniale. Vous pouvez jeter la branche `prob91` originale (perdant ainsi
les *commits* `C5` et `C6`) et fusionner les deux autres branches. Votre
historique ressemble à présent à ceci :

![Historique après la fusion de \`ideeidiote\` et
\`prob91v2\`.](images/topic-branches-2.png)

Figure 29. Historique après la fusion de `ideeidiote` et `prob91v2`

Nous verrons au chapitre [Git distribué](#ch05-distributed-git),
d’autres méthodes et processus possibles pour vos projets Git. Nous vous
invitons à prendre connaissance de ce chapitre avant de vous décider
pour une méthode particulière de gestion de vos branches pour votre
prochain projet.

Il est important de se souvenir que lors de la réalisation de toutes ces
actions, ces branches sont complètement locales. Lorsque vous créez et
fusionnez des branches, ceci est réalisé uniquement dans votre dépôt Git
local et aucune communication avec un serveur n’a lieu.

## Branches de suivi à distance

Les références distantes sont des références (pointeurs) vers les
éléments de votre dépôt distant tels que les branches, les tags, etc…​
Vous pouvez obtenir la liste complète de ces références distantes avec
la commade `git ls-remote (remote)`, ou `git remote show (remote)`.
Néanmoins, une manière plus courante consiste à tirer parti des branches
de suivi à distance.

Les branches de suivi à distance sont des références (des pointeurs)
vers l’état des branches sur votre dépôt distant. Ce sont des branches
locales qu’on ne peut pas modifier ; elles sont modifiées
automatiquement pour vous lors de communications réseau. Les branches de
suivi à distance agissent comme des marques-pages pour vous indiquer
l’état des branches sur votre dépôt distant lors de votre dernière
connexion.

Elles prennent la forme de `(distant)/(branche)`. Par exemple, si vous
souhaitiez visualiser l’état de votre branche `master` sur le dépôt
distant `origin` lors de votre dernière communication, il vous suffirait
de vérifier la branche `origin/master`. Si vous étiez en train de
travailler avec un collègue et qu’il avait publié la branche `iss53`,
vous pourriez avoir votre propre branche `iss53` ; mais la branche sur
le serveur pointerait sur le *commit* de `origin/iss53`.

Cela peut être un peu déconcertant, essayons d’éclaircir les choses par
un exemple. Supposons que vous avez un serveur Git sur le réseau à
l’adresse `git.notresociete.com`. Si vous clonez à partir de ce serveur,
la commande `clone` de Git le nomme automatiquement `origin`, tire tout
son historique, crée un pointeur sur l’état actuel de la branche
`master` et l’appelle localement `origin/master`. Git crée également
votre propre branche `master` qui démarre au même endroit que la branche
`master` d’origine, pour que vous puissiez commencer à travailler.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="title">
<code>origin</code> n’est pas spécial
</div>
<div class="paragraph">
<p>De la même manière que le nom de branche <code>master</code> n’a aucun sens particulier pour Git, le nom <code>origin</code> n’est pas spécial. Tandis que <code>master</code> est le nom attribué par défaut à votre branche initiale lorsque vous lancez la commande <code>git init</code> et c’est la seule raison pour laquelle ce nom est utilisé aussi largement, <code>origin</code> est le nom utilisé par défaut pour un dépôt distant lorsque vous lancez <code>git clone</code>. Si vous lancez à la place <code>git clone -o booyah</code>, votre branche de suivi à distance par défaut s’appellera <code>booyah/master</code>.</p>
</div></td>
</tr>
</tbody>
</table>

![Dépôts distant et local après un
\_clone\_.](images/remote-branches-1.png)

Figure 30. Dépôts distant et local après un *clone*

Si vous travaillez sur votre branche locale `master` et que dans le même
temps, quelqu’un publie sur `git.notresociete.com` et met à jour cette
même branche `master`, alors vos deux historiques divergent. Tant que
vous restez sans contact avec votre serveur distant, votre pointeur vers
`origin/master` n’avance pas.

![Les travaux locaux et distants peuvent
diverger.](images/remote-branches-2.png)

Figure 31. Les travaux locaux et distants peuvent diverger

Lancez la commande `git fetch origin` pour synchroniser vos travaux.
Cette commande recherche le serveur hébergeant `origin` (dans notre cas,
`git.notresociete.com`), y récupère toutes les nouvelles données et met
à jour votre base de donnée locale en déplaçant votre pointeur
`origin/master` vers une nouvelle position, plus à jour.

![\`git fetch\` met à jour vos branches de suivi à
distance.](images/remote-branches-3.png)

Figure 32. `git fetch` met à jour vos branches de suivi à distance

Pour démontrer l’usage de multiples serveurs distants et le
fonctionnement des branches de suivi à distance pour ces projets
distants, supposons que vous avez un autre serveur Git interne qui n’est
utilisé que par une équipe de développeurs. Ce serveur se trouve sur
`git.equipe1.notresociete.com`. Vous pouvez l’ajouter aux références
distantes de votre projet en lançant la commande `git remote add` comme
nous l’avons décrit au chapitre [Les bases de Git](#ch02-git-basics).
Nommez ce serveur distant `equipeun` qui sera le raccourci pour l’URL
complète.

![Ajout d’un nouveau serveur en tant que référence
distante.](images/remote-branches-4.png)

Figure 33. Ajout d’un nouveau serveur en tant que référence distante

Maintenant, vous pouvez lancer `git fetch equipeun` pour récupérer
l’ensemble des informations du serveur distant `equipeun` que vous ne
possédez pas. Comme ce serveur contient déjà un sous-ensemble des
données du serveur `origin`, Git ne récupère aucune donnée mais
initialise une branche de suivi à distance appelée `equipeun/master` qui
pointe sur le même *commit* que celui vers lequel pointe la branche
`master` de `equipeun`.

![Branche de suivi à distance
\`equipeun/master\`.](images/remote-branches-5.png)

Figure 34. Branche de suivi à distance `equipeun/master`

### Pousser les branches

Lorsque vous souhaitez partager une branche avec le reste du monde, vous
devez la pousser sur un serveur distant sur lequel vous avez accès en
écriture. Vos branches locales ne sont pas automatiquement synchronisées
sur les serveurs distants — vous devez pousser explicitement les
branches que vous souhaitez partager. De cette manière, vous pouvez
utiliser des branches privées pour le travail que vous ne souhaitez pas
partager et ne pousser que les branches sur lesquelles vous souhaitez
collaborer.

Si vous possédez une branche nommée `correctionserveur` sur laquelle
vous souhaitez travailler avec d’autres, vous pouvez la pousser de la
même manière que vous avez poussé votre première branche. Lancez
`git push (serveur distant) (branche)` :

``` highlight
$ git push origin correctionserveur
Counting objects: 24, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (15/15), done.
Writing objects: 100% (24/24), 1.91 KiB | 0 bytes/s, done.
Total 24 (delta 2), reused 0 (delta 0)
To https://github.com/schacon/simplegit
 * [new branch]      correctionserveur -> correctionserveur
```

Il s’agit en quelque sorte d’un raccourci. Git développe automatiquement
le nom de branche `correctionserveur` en
`refs/heads/correctionserveur:refs/heads/correctionserveur`, ce qui
signifie "Prendre ma branche locale `correctionserveur` et la pousser
pour mettre à jour la branche distante `correctionserveur`". Nous
traiterons plus en détail la partie `refs/heads/` au chapitre [Les
tripes de Git](#ch10-git-internals) mais généralement, vous pouvez
l’oublier. Vous pouvez aussi lancer
`git push origin correctionserveur:correctionserveur`, qui réalise la
même chose — ce qui signifie « Prendre ma branche `correctionserveur` et
en faire la branche `correctionserveur` distante ». Vous pouvez utiliser
ce format pour pousser une branche locale vers une branche distante
nommée différemment. Si vous ne souhaitez pas l’appeler
`correctionserveur` sur le serveur distant, vous pouvez lancer à la
place `git push origin correctionserveur:branchegeniale` pour pousser
votre branche locale `correctionserveur` sur la branche `branchegeniale`
sur le dépôt distant.

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="title">
Ne renseignez pas votre mot de passe à chaque fois
</div>
<div class="paragraph">
<p>Si vous utilisez une URL en HTTPS, le serveur Git vous demandera votre nom d’utilisateur et votre mot de passe pour vous authentifier. Par défaut, vous devez entrer ces informations sur votre terminal et le serveur pourra alors déterminer si vous être autorisé à pousser.</p>
</div>
<div class="paragraph">
<p>Si vous ne voulez pas entrer ces informations à chaque fois que vous poussez, vous pouvez mettre en place un "cache d’identification" (<em>credential cache</em>). Son fonctionnement le plus simple consiste à garder ces informations en mémoire pour quelques minutes mais vous pouvez configurer ce délai en lançant la commande <code>git config --global credential.helper cache</code>.</p>
</div>
<div class="paragraph">
<p>Pour davantage d’informations sur les différentes options de cache d’identification disponibles, vous pouvez vous référer au chapitre <a href="#s_credential_caching">Stockage des identifiants</a>.</p>
</div></td>
</tr>
</tbody>
</table>

La prochaine fois qu’un de vos collègues récupère les données depuis le
serveur, il récupérera, au sein de la branche de suivi à distance
`origin/correctionserveur`, une référence vers l’état de la branche
`correctionserveur` sur le serveur :

``` highlight
$ git fetch origin
remote: Counting objects: 7, done.
remote: Compressing objects: 100% (2/2), done.
remote: Total 3 (delta 0), reused 3 (delta 0)
Unpacking objects: 100% (3/3), done.
From https://github.com/schacon/simplegit
 * [new branch]      correctionserveur    -> origin/correctionserveur
```

Il est important de noter que lorsque vous récupérez une nouvelle
branche depuis un serveur distant, vous ne créez pas automatiquement une
copie locale éditable. En d’autres termes, il n’y a pas de branche
`correctionserveur`, seulement un pointeur sur la branche
`origin/correctionserveur` qui n’est pas modifiable.

Pour fusionner ce travail dans votre branche de travail actuelle, vous
pouvez lancer la commande `git merge origin/correctionserveur`. Si vous
souhaitez créer votre propre branche `correctionserveur` pour pouvoir y
travailler, vous pouvez faire qu’elle repose sur le pointeur distant :

``` highlight
$ git checkout -b correctionserveur origin/correctionserveur
Branch correctionserveur set up to track remote branch correctionserveur from origin.
Switched to a new branch 'correctionserveur'
```

Cette commande vous fournit une branche locale modifiable basée sur
l’état actuel de `origin/correctionserveur`.

### Suivre les branches

L’extraction d’une branche locale à partir d’une branche distante crée
automatiquement ce qu’on appelle une "branche de suivi" (*tracking
branch*) et la branche qu’elle suit est appelée "branche amont"
(*upstream branch*). Les branches de suivi sont des branches locales qui
sont en relation directe avec une branche distante. Si vous vous trouvez
sur une branche de suivi et que vous tapez `git push`, Git sélectionne
automatiquement le serveur vers lequel pousser vos modifications. De
même, un `git pull` sur une de ces branches récupère toutes les
références distantes et fusionne automatiquement la branche distante
correspondante dans la branche actuelle.

Lorsque vous clonez un dépôt, il crée généralement automatiquement une
branche `master` qui suit `origin/master`. C’est pourquoi les commandes
`git push` et `git pull` fonctionnent directement sans autre
configuration. Vous pouvez néanmoins créer d’autres branches de suivi si
vous le souhaitez, qui suivront des branches sur d’autres dépôts
distants ou ne suivront pas la branche `master`. Un cas d’utilisation
simple est l’exemple précédent, en lançant
`git checkout -b [branche] [nomdistant]/[branche]`. C’est une opération
suffisamment courante pour que Git propose l’option abrégée `--track` :

``` highlight
$ git checkout --track origin/correctionserveur
Branch correctionserveur set up to track remote branch correctionserveur from origin.
Switched to a new branch 'correctionserveur'
```

Pour créer une branche locale avec un nom différent de celui de la
branche distante, vous pouvez simplement utiliser la première version
avec un nom différent de branche locale :

``` highlight
$ git checkout -b cs origin/correctionserveur
Branch cs set up to track remote branch correctionserveur from origin.
Switched to a new branch 'cs'
```

À présent, votre branche locale `cs` poussera vers et tirera
automatiquement depuis `origin/correctionserveur`.

Si vous avez déjà une branche locale et que vous voulez l’associer à une
branche distante que vous venez de récupérer ou que vous voulez changer
la branche distante que vous suivez, vous pouvez ajouter l’option `-u`
ou `--set-upstream-to` à la commande `git branch` à tout moment.

``` highlight
$ git branch -u origin/correctionserveur
Branch correctionserveur set up to track remote branch correctionserveur from origin.
```

<table>
<colgroup>
<col style="width: 50%" />
<col style="width: 50%" />
</colgroup>
<tbody>
<tr class="odd">
<td><em></em></td>
<td><div class="title">
Raccourci vers <em>upstream</em>
</div>
<div class="paragraph">
<p>Quand vous avez une branche de suivi configurée, vous pouvez faire référence à sa branche amont grâce au raccourci <code>@{upstream}</code> ou <code>@{u}</code>. Ainsi, si vous êtes sur la branche <code>master</code> qui suit <code>origin/master</code>, vous pouvez utiliser quelque chose comme <code>git merge @{u}</code> au lieu de <code>git merge origin/master</code> si vous le souhaitez.</p>
</div></td>
</tr>
</tbody>
</table>

Si vous voulez voir quelles branches de suivi vous avez configurées,
vous pouvez passer l’option `-vv` à `git branch`. Celle-ci va lister
l’ensemble de vos branches locales avec quelques informations
supplémentaires, y compris quelle est la branche suivie et si votre
branche locale est devant, derrière ou les deux à la fois.

``` highlight
$ git branch -vv
  iss53     7e424c3 [origin/iss53: ahead 2] forgot the brackets
  master    1ae2a45 [origin/master] deploying index fix
* correctionserveur f8674d9 [equipe1/correction-serveur-ok: ahead 3, behind 1] this should do it
  test   5ea463a trying something new
```

Vous pouvez constater ici que votre branche `iss53` suit `origin/iss53`
et est *"devant de deux"*, ce qui signifie qu’il existe deux *commits*
locaux qui n’ont pas été poussés au serveur. On peut aussi voir que la
branche `master` suit `origin/master` et est à jour. On peut voir
ensuite que notre branche `correctionserveur` suit la branche
`correction-serveur-ok` sur notre serveur `equipe1` et est *"devant de
trois"* et *"derrière de un"*, ce qui signifie qu’il existe un *commit*
qui n’a pas été encore intégré localement et trois *commits* locaux qui
n’ont pas été poussés. Finalement, on peut voir que notre branche `test`
ne suit aucune branche distante.

Il est important de noter que ces nombres se basent uniquement sur
l’état de votre branche distante la dernière fois qu’elle a été
synchronisée depuis le serveur. Cette commande n’effectue aucune
recherche sur les serveurs et ne travaille que sur les données locales
qui ont été mises en cache depuis ces serveurs. Si vous voulez mettre
complètement à jour ces nombres, vous devez préalablement synchroniser
(*fetch*) toutes vos branches distantes depuis les serveurs. Vous pouvez
le faire de cette façon : `$ git fetch --all; git branch -vv`.

### Tirer une branche (*Pulling*)

Bien que la commande `git fetch` récupère l’ensemble des changements
présents sur serveur et qui n’ont pas déjà été rapatriés localement,
elle ne modifie en rien votre répertoire de travail. Cette commande
récupère simplement les données pour vous et vous laisse les fusionner
par vous-même. Cependant, il existe une commande appelée `git pull` qui
consiste essentiellement en un `git fetch` immédiatement suivi par un
`git merge` dans la plupart des cas. Si vous disposez d’une branche de
suivi configurée comme illustré dans le chapitre précédent, soit par une
configuration explicite soit en ayant laissé les commandes `clone` ou
`checkout` les créer pour vous, `git pull` va examiner quel serveur et
quelle branche votre branche courante suit actuellement, synchroniser
depuis ce serveur et ensuite essayer de fusionner cette branche distante
avec la vôtre.

Il est généralement préférable de simplement utiliser les commandes
`fetch` et `merge` explicitement plutôt que de laisser faire la magie de
`git pull` qui peut s’avérer source de confusion.

### Suppression de branches distantes

Supposons que vous en avez terminé avec une branche distante ‒ disons
que vous et vos collaborateurs avez terminé une fonctionnalité et l’avez
fusionnée dans la branche `master` du serveur distant (ou la branche
correspondant à votre code stable). Vous pouvez effacer une branche
distante en ajoutant l’option `--delete` à `git push`. Si vous souhaitez
effacer votre branche `correctionserveur` du serveur, vous pouvez lancer
ceci :

``` highlight
$ git push origin --delete correctionserveur
To https://github.com/schacon/simplegit
 - [deleted]         correctionserveur
```

En résumé, cela ne fait que supprimer le pointeur sur le serveur. Le
serveur Git garde généralement les données pour un temps jusqu’à ce
qu’un processus de nettoyage (*garbage collection*) passe. De cette
manière, si une suppression accidentelle a eu lieu, les données sont
souvent très facilement récupérables.

## Rebaser (*Rebasing*)

Dans Git, il y a deux façons d’intégrer les modifications d’une branche
dans une autre : en fusionnant (`merge`) et en rebasant (`rebase`). Dans
ce chapitre, vous apprendrez la signification de rebaser, comment le
faire, pourquoi c’est un outil incroyable et dans quels cas il est
déconseillé de l’utiliser.

### Les bases

Si vous revenez à un exemple précédent du chapitre [Fusions
(*Merges*)](#s_basic_merging), vous remarquerez que votre travail a
divergé et que vous avez ajouté des *commits* sur deux branches
différentes.

![Historique divergeant simple.](images/basic-rebase-1.png)

Figure 35. Historique divergeant simple

Comme nous l’avons déjà expliqué, le moyen le plus simple pour intégrer
ces branches est la fusion via la commande `merge`. Cette commande
réalise une *fusion à trois branches* entre les deux derniers
instantanés (*snapshots*) de chaque branche (C3 et C4) et l’ancêtre
commun le plus récent (C2), créant un nouvel instantané (et un
*commit*).

![Fusion pour intégrer des travaux aux historiques
divergeants.](images/basic-rebase-2.png)

Figure 36. Fusion pour intégrer des travaux aux historiques divergeants

Cependant, il existe un autre moyen : vous pouvez prendre le *patch* de
la modification introduite en `C4` et le réappliquer sur `C3`. Dans Git,
cette action est appelée "rebaser" (*rebasing*). Avec la commande
`rebase`, vous pouvez prendre toutes les modifications qui ont été
validées sur une branche et les rejouer sur une autre.

Dans cet exemple, vous lanceriez les commandes suivantes :

``` highlight
$ git checkout experience
$ git rebase master
First, rewinding head to replay your work on top of it...
Applying: added staged command
```

Cela fonctionne en cherchant l’ancêtre commun le plus récent des deux
branches (celle sur laquelle vous vous trouvez et celle sur laquelle
vous rebasez), en récupérant toutes les différences introduites par
chaque *commit* de la branche courante, en les sauvant dans des fichiers
temporaires, en réinitialisant la branche courante sur le même *commit*
que la branche de destination et en appliquant finalement chaque
modification dans le même ordre.

![Rebasage des modifications introduites par \`C4\` sur
\`C3\`.](images/basic-rebase-3.png)

Figure 37. Rebasage des modifications introduites par `C4` sur `C3`

À ce moment, vous pouvez retourner sur la branche `master` et réaliser
une fusion en avance rapide (*fast-forward merge*).

![Avance rapide de la branche \`master\`.](images/basic-rebase-4.png)

Figure 38. Avance rapide de la branche `master`

À présent, l’instantané pointé par `C4'` est exactement le même que
celui pointé par `C5` dans l’exemple de fusion. Il n’y a pas de
différence entre les résultats des deux types d’intégration, mais
rebaser rend l’historique plus clair. Si vous examinez le journal de la
branche rebasée, elle est devenue linéaire : toutes les modifications
apparaissent en série même si elles ont eu lieu en parallèle.

Vous aurez souvent à faire cela pour vous assurer que vos *commits*
s’appliquent proprement sur une branche distante — par exemple, sur un
projet où vous souhaitez contribuer mais que vous ne maintenez pas. Dans
ce cas, vous réaliseriez votre travail dans une branche puis vous
rebaseriez votre travail sur `origin/master` quand vous êtes prêt à
soumettre vos patchs au projet principal. De cette manière, le
mainteneur n’a pas à réaliser de travail d’intégration — juste une
avance rapide ou simplement une application propre.

Il faut noter que l’instantané pointé par le *commit* final, qu’il soit
le dernier des *commits* d’une opération de rebasage ou le *commit*
final issu d’une fusion, sont en fait le même instantané — c’est juste
que l’historique est différent. Rebaser rejoue les modifications d’une
ligne de *commits* sur une autre dans l’ordre d’apparition, alors que la
fusion joint et fusionne les deux têtes.

### Rebases plus intéressants

Vous pouvez aussi faire rejouer votre rebasage sur autre chose qu’une
branche. Prenez un historique tel que [Un historique avec deux branches
thématiques qui sortent l’une de l’autre](#rbdiag_e) par exemple. Vous
avez créé une branche thématique (`serveur`) pour ajouter des
fonctionnalités côté serveur à votre projet et avez réalisé un *commit*.
Ensuite, vous avez créé une branche pour ajouter des modifications côté
client (`client`) et avez validé plusieurs fois. Finalement, vous avez
rebasculé sur la branche `serveur` et avez réalisé quelques *commits*
supplémentaires.

![Un historique avec deux branches thématiques qui sortent l’une de
l’autre.](images/interesting-rebase-1.png)

Figure 39. Un historique avec deux branches thématiques qui sortent
l’une de l’autre

Supposons que vous décidez que vous souhaitez fusionner vos
modifications du côté client dans votre ligne principale pour une
publication (*release*) mais vous souhaitez retenir les modifications de
la partie serveur jusqu’à ce qu’elles soient un peu mieux testées. Vous
pouvez récupérer les modifications du côté client qui ne sont pas sur le
serveur (`C8` et `C9`) et les rejouer sur la branche `master` en
utilisant l’option `--onto` de `git rebase` :

``` highlight
$ git rebase --onto master serveur client
```

Cela signifie en substance "Extraire la branche client, déterminer les
patchs depuis l’ancêtre commun des branches `client` et `serveur` puis
les rejouer sur `master` ". C’est assez complexe, mais le résultat est
assez impressionnant.

![Rebaser deux branches thématiques l’une sur
l’autre.](images/interesting-rebase-2.png)

Figure 40. Rebaser deux branches thématiques l’une sur l’autre

Maintenant, vous pouvez faire une avance rapide sur votre branche
`master` (cf. [Avance rapide sur votre branche `master` pour inclure les
modifications de la branche client](#rbdiag_g)):

``` highlight
$ git checkout master
$ git merge client
```

![Avance rapide sur votre branche \`master\` pour inclure les
modifications de la branche client.](images/interesting-rebase-3.png)

Figure 41. Avance rapide sur votre branche `master` pour inclure les
modifications de la branche client

Supposons que vous décidiez de tirer (*pull*) votre branche `serveur`
aussi. Vous pouvez rebaser la branche `serveur` sur la branche `master`
sans avoir à l’extraire avant en utilisant
`git rebase [branchedebase] [branchethematique]` — qui extrait la
branche thématique (dans notre cas, `serveur`) pour vous et la rejoue
sur la branche de base (`master`) :

``` highlight
$ git rebase master serveur
```

Cette commande rejoue les modifications de `serveur` sur le sommet de la
branche `master`, comme indiqué dans [Rebasage de la branche serveur sur
le sommet de la branche `master`.](#rbdiag_h).

![Rebasage de la branche serveur sur le sommet de la branche
\`master\`.](images/interesting-rebase-4.png)

Figure 42. Rebasage de la branche serveur sur le sommet de la branche
`master`.

Vous pouvez ensuite faire une avance rapide sur la branche de base
(`master`) :

``` highlight
$ git checkout master
$ git merge serveur
```

Vous pouvez effacer les branches `client` et `serveur` une fois que tout
le travail est intégré et que vous n’en avez plus besoin, éliminant tout
l’historique de ce processus, comme visible sur [Historique final des
*commits*](#rbdiag_i) :

``` highlight
$ git branch -d client
$ git branch -d serveur
```

![Historique final des \_commits\_.](images/interesting-rebase-5.png)

Figure 43. Historique final des *commits*

### Les dangers du rebasage

Ah… mais les joies de rebaser ne viennent pas sans leurs contreparties,
qui peuvent être résumées en une ligne :

**Ne rebasez jamais des *commits* qui ont déjà été poussés sur un dépôt
public.**

Si vous suivez ce conseil, tout ira bien. Sinon, de nombreuses personnes
vont vous haïr et vous serez méprisé par vos amis et votre famille.

Quand vous rebasez des données, vous abandonnez les *commits* existants
et vous en créez de nouveaux qui sont similaires mais différents. Si
vous poussez des *commits* quelque part, que d’autres les tirent et se
basent dessus pour travailler, et qu’après coup, vous réécrivez ces
*commits* à l’aide de `git rebase` et les poussez à nouveau, vos
collaborateurs devront re-fusionner leur travail et les choses peuvent
rapidement devenir très désordonnées quand vous essaierez de tirer leur
travail dans votre dépôt.

Examinons un exemple expliquant comment rebaser un travail déjà publié
sur un dépôt public peut générer des gros problèmes. Supposons que vous
clonez un dépôt depuis un serveur central et réalisez quelques travaux
dessus. Votre historique de *commits* ressemble à ceci :

![Cloner un dépôt et baser du travail
dessus.](images/perils-of-rebasing-1.png)

Figure 44. Cloner un dépôt et baser du travail dessus

À présent, une autre personne travaille et inclut une fusion, puis elle
pousse ce travail sur le serveur central. Vous le récupérez et vous
fusionnez la nouvelle branche distante dans votre copie, ce qui donne
l’historique suivant :

![Récupération de \_commits\_ et fusion dans votre
copie.](images/perils-of-rebasing-2.png)

Figure 45. Récupération de *commits* et fusion dans votre copie

Ensuite, la personne qui a poussé le travail que vous venez de fusionner
décide de faire marche arrière et de rebaser son travail. Elle lance un
`git push --force` pour forcer l’écrasement de l’historique sur le
serveur. Vous récupérez alors les données du serveur, qui vous amènent
les nouveaux *commits*.

![Quelqu’un pousse des \_commits\_ rebasés, en abandonnant les
\_commits\_ sur lesquels vous avez fondé votre
travail.](images/perils-of-rebasing-3.png)

Figure 46. Quelqu’un pousse des *commits* rebasés, en abandonnant les
*commits* sur lesquels vous avez fondé votre travail

Vous êtes désormais tous les deux dans le pétrin. Si vous faites un
`git pull`, vous allez créer un *commit* de fusion incluant les deux
historiques et votre dépôt ressemblera à ça :

![Vous fusionnez le même travail une nouvelle fois dans un nouveau
\_commit\_ de fusion.](images/perils-of-rebasing-4.png)

Figure 47. Vous fusionnez le même travail une nouvelle fois dans un
nouveau *commit* de fusion

Si vous lancez `git log` lorsque votre historique ressemble à ceci, vous
verrez deux *commits* qui ont la même date d’auteur et les mêmes
messages, ce qui est déroutant. De plus, si vous poussez cet historique
sur le serveur, vous réintroduirez tous ces *commits* rebasés sur le
serveur central, ce qui va encore plus dérouter les autres développeurs.
C’est plutôt logique de présumer que l’autre développeur ne souhaite pas
voir apparaître `C4` et `C6` dans l’historique. C’est la raison pour
laquelle il avait effectué un rebasage initialement.

### Rebaser quand vous rebasez

Si vous vous retrouvez effectivement dans une situation telle que
celle-ci, Git dispose d’autres fonctions magiques qui peuvent vous
aider. Si quelqu’un de votre équipe pousse de force des changements qui
écrasent des travaux sur lesquels vous vous êtes basés, votre défi est
de déterminer ce qui est à vous et ce qui a été réécrit.

Il se trouve qu’en plus de l’empreinte SHA du *commit*, Git calcule
aussi une empreinte qui est uniquement basée sur le patch introduit avec
le commit. Ceci est appelé un "identifiant de patch" (*patch-id*).

Si vous tirez des travaux qui ont été réécrits et les rebasez au-dessus
des nouveaux *commits* de votre collègue, Git peut souvent déterminer
ceux qui sont uniquement les vôtres et les réappliquer au sommet de
votre nouvelle branche.

Par exemple, dans le scénario précédent, si au lieu de fusionner quand
nous étions à l’étape [Quelqu’un pousse des *commits* rebasés, en
abandonnant les *commits* sur lesquels vous avez fondé votre
travail](#s_pre_merge_rebase_work) nous exécutons la commande
`git rebase equipe1/master`, Git va :

-   Déterminer quels travaux sont uniques à notre branche (C2, C3, C4,
    C6, C7)

-   Déterminer ceux qui ne sont pas des *commits* de fusion (C2, C3, C4)

-   Déterminer ceux qui n’ont pas été réécrits dans la branche de
    destination (uniquement C2 et C3 puisque C4 est le même *patch* que
    C4')

-   Appliquer ces *commits* au sommet de `equipe1/master`

Ainsi, au lieu du résultat que nous avons observé au chapitre [Vous
fusionnez le même travail une nouvelle fois dans un nouveau *commit* de
fusion](#s_merge_rebase_work), nous aurions pu finir avec quelque chose
qui ressemblerait davantage à [Rebaser au-dessus de travaux rebasés puis
que l’on a poussé en forçant.](#s_rebase_rebase_work).

![Rebaser au-dessus de travaux rebasés puis que l’on a poussé en
forçant.](images/perils-of-rebasing-5.png)

Figure 48. Rebaser au-dessus de travaux rebasés puis que l’on a poussé
en forçant.

Cela fonctionne seulement si les *commits* C4 et C4' de votre collègue
correspondent presque exactement aux mêmes modifications. Autrement, le
rebasage ne sera pas capable de déterminer qu’il s’agit d’un doublon et
va ajouter un autre *patch* similaire à C4 (ce qui échouera probablement
puisque les changements sont au moins partiellement déjà présents).

Vous pouvez également simplifier tout cela en lançant un
`git pull --rebase` au lieu d’un `git pull` normal. Vous pouvez encore
le faire manuellement à l’aide d’un `git fetch` suivi d’un
`git rebase team1/master` dans le cas présent.

Si vous utilisez `git pull` et voulez faire de `--rebase` le traitement
par défaut, vous pouvez changer la valeur du paramètre de configuration
`pull.rebase` par `git config --global pull.rebase true`.

Si vous considérez le fait de rebaser comme un moyen de nettoyer et
réarranger des *commits* avant de les pousser et si vous vous en tenez à
ne rebaser que des *commits* qui n’ont jamais été publiés, tout ira
bien. Si vous tentez de rebaser des *commits* déjà publiés sur lesquels
les gens ont déjà basé leur travail, vous allez au devant de gros
problèmes et votre équipe vous en tiendra rigueur.

Si vous ou l’un de vos collègues y trouve cependant une quelconque
nécessité, assurez-vous que tout le monde sache lancer un
`git pull --rebase` pour essayer de rendre les choses un peu plus
faciles.

### Rebaser ou Fusionner

Maintenant que vous avez vu concrètement ce que signifient rebaser et
fusionner, vous devez vous demander ce qu’il est préférable d’utiliser.
Avant de pouvoir répondre à cela, revenons quelque peu en arrière et
parlons un peu de ce que signifie un historique.

On peut voir l’historique des *commits* de votre dépôt comme un
**enregistrement de ce qu’il s’est réellement passé**. Il s’agit d’un
document historique qui a une valeur en tant que tel et ne doit pas être
altéré. Sous cet angle, modifier l’historique des *commits* est presque
blasphématoire puisque vous *mentez* sur ce qu’il s’est réellement
passé. Dans ce cas, que faire dans le cas d’une série de *commits* de
fusions désordonnés ? Cela reflète ce qu’il s’est passé et le dépôt
devrait le conserver pour la postérité.

Le point de vue inverse consiste à considérer que l’historique des
*commits* est **le reflet de la façon dont votre projet a été
construit**. Vous ne publieriez jamais le premier brouillon d’un livre
et le manuel de maintenance de votre projet mérite une révision
attentive. Ceci constitue le camp de ceux qui utilisent des outils tels
que le rebasage et les branches filtrées pour raconter une histoire de
la meilleure des manières pour les futurs lecteurs.

Désormais, nous espérons que vous comprenez qu’il n’est pas si simple de
répondre à la question portant sur le meilleur outil entre fusion et
rebasage. Git est un outil puissant et vous permet beaucoup de
manipulations sur et avec votre historique mais chaque équipe et chaque
projet sont différents. Maintenant que vous savez comment fonctionnent
ces deux outils, c’est à vous de décider lequel correspond le mieux à
votre situation en particulier.

De manière générale, la manière de profiter au mieux des deux mondes
consiste à rebaser des modifications locales que vous avez effectuées
mais qui n’ont pas encore été partagées avant de les pousser de manière
à obtenir un historique propre mais sans jamais rebaser quoi que ce soit
que vous ayez déjà poussé quelque part.

## Résumé

Nous avons traité les bases des branches et des fusions dans Git. Vous
devriez désormais être à l’aise pour créer et basculer sur de nouvelles
branches, basculer entre branches et fusionner des branches locales.
Vous devriez aussi être capable de partager vos branches en les poussant
sur un serveur partagé, de travailler avec d’autres personnes sur des
branches partagées et de re-baser vos branches avant de les partager.
Nous aborderons ensuite tout ce que vous devez savoir pour faire tourner
votre propre serveur d’hébergement de dépôts.
