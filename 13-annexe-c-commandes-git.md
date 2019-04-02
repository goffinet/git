# Commandes Git

<!-- toc -->

Tout au long du livre, nous avons introduit des dizaines de commandes
Git et avons essayé le plus possible de les introduire de manière
narrative, en ajoutant progressivement des commandes dans l’histoire.
Cependant, cela nous laisse avec des exemples d’utilisation des
commandes quelque peu dispersés tout au long du livre.

Dans cette annexe, nous allons revoir toutes les commandes Git qui se
trouvent dans le livre, regroupées à peu près par leur usage. Nous
allons parler de ce que chaque commande fait très généralement et nous
indiquerons où vous pouvez les retrouver dans le livre.

## Installation et configuration

Il y a deux commandes qui sont les plus utilisées, depuis les premières
invocations de Git jusqu’à la mise au point et à la gestion quotidienne
des branches, ce sont les commandes `config` et `help`.

### git config

Git a une façon par défaut de faire des centaines de choses. Pour
beaucoup de ces choses, vous pouvez demander à Git de les faire par
défaut d’une autre manière ou de définir vos préférences. Cela implique
tout depuis dire à Git quel est votre nom jusqu’aux préférences
spécifiques des couleurs du terminal ou de l’éditeur que vous utilisez.
Il y a plusieurs fichiers que cette commande lira et dans lesquels elle
écrira de façon à définir des valeurs globales ou spécifiques à des
dépôts.

La commande `git config` a été utilisée dans presque tous les chapitres
du livre.

Dans [Paramétrage à la première utilisation de Git](#s_first_time), nous
l’avons utilisée pour indiquer notre nom, adresse de courrier
électronique et la préférence d’éditeur avant même que nous commencions
à utiliser Git.

Dans [Les alias Git](#s_git_aliases), nous avons montré comment vous
pourriez l’utiliser pour créer des commandes raccourcies qui se
développent en longues séquences d’options pour que vous n’ayez pas à
les taper à chaque fois.

Dans [Rebaser (*Rebasing*)](#s_rebasing), nous l’avons utilisée pour
faire de `--rebase` le comportement par défaut quand vous lancez
`git pull`.

Dans [Stockage des identifiants](#s_credential_caching), nous l’avons
utilisée pour définir un stockage par défaut pour vos mots de passe
HTTP.

Dans [Expansion des mots-clés](#s_keyword_expansion), nous avons montré
comment définir des filtres « smudge » et « clean » sur le contenu
entrant et sortant de Git.

Enfin, la totalité de [Configuration de Git](#s_git_config) est dédiée à
cette commande.

### git help

La commande `git help` est utilisée pour vous montrer toute la
documentation livrée avec Git à propos de n’importe quelle commande.
Bien que nous donnions un panorama général des plus populaires d’entre
elles dans cette annexe, pour une liste complète de toutes les options
possibles pour chaque commande, vous pouvez toujours lancer
`git help <commande>`.

Nous avons introduit la commande `git help` dans [Obtenir de
l’aide](#s_git_help) et vous avons montré comment l’utiliser pour
trouver plus d’informations sur le `git shell` dans [Mise en place du
serveur](#s_setting_up_server).

## Obtention et création des projets

Il y a deux façons de récupérer un dépôt Git. L’une consiste à le copier
d’un dépôt existant sur le réseau ou ailleurs et l’autre est d’en créer
un nouveau dans un dossier existant.

### git init

Pour transformer un dossier en un nouveau dépôt Git afin que vous
puissiez commencer sa gestion de version, vous pouvez simplement lancer
`git init`.

Nous l’avons d’abord présentée dans [Démarrer un dépôt
Git](#s_getting_a_repo), où nous avons montré la création d’un tout
nouveau dépôt pour commencer à l’utiliser.

Nous parlons brièvement de la façon dont vous pourriez changer la
branche par défaut depuis « master » dans [Branches de suivi à
distance](#s_remote_branches).

Nous utilisons cette commande pour créer un dépôt vierge pour un serveur
dans [Copie du dépôt nu sur un serveur](#s_bare_repo).

Enfin, nous rentrons dans quelques détails de ce qu’il fait
effectivement en coulisses dans [Plomberie et
porcelaine](#s_plumbing_porcelain).

### git clone

La commande `git clone` sert en fait à englober plusieurs autres
commandes. Elle crée un nouveau dossier, va à l’intérieur de celui-ci et
lance `git init` pour en faire un dépôt Git vide, ajoute un serveur
distant (`git remote add`) à l’URL que vous lui avez passée (appelé par
défaut `origin`), lance `git fetch` à partir de ce dépôt distant et
ensuite extrait le dernier *commit* dans votre répertoire de travail
avec `git checkout`.

La commande `git clone` est utilisée dans des dizaines d’endroits du
livre, mais nous allons seulement lister quelques endroits intéressants.

C’est présenté et expliqué en gros dans [Cloner un dépôt
existant](#s_git_cloning), où vous trouverez quelques exemples.

Dans [Installation de Git sur un serveur](#s_git_on_the_server), nous
montrons l’utilisation de l’option `--bare` pour créer une copie d’un
dépôt Git sans répertoire de travail.

Dans [Empaquetage (*bundling*)](#s_bundling), nous l’utilisons pour
dépaqueter un dépôt Git empaqueté.

Enfin, dans [Cloner un projet avec des
sous-modules](#s_cloning_submodules), nous apprenons l’option
`--recursive-submodule` pour rendre le clonage d’un dépôt avec
sous-modules un peu plus simple.

Bien qu’elle soit utilisée dans beaucoup d’autres endroits du livre,
ceux-là sont ceux qui sont en quelque sorte uniques ou qui sont utilisés
de manière un peu différente.

## Capture d’instantané basique

Pour le flux de travail basique d’indexation du contenu et de sa
validation dans votre historique, il n’y a que quelques commandes
basiques.

### git add

La commande `git add` ajoute le contenu du répertoire de travail dans la
zone d’index pour le prochain *commit*. Quand la commande `git commit`
est lancée, par défaut elle ne regarde que cette zone d’index, donc
`git add` est utilisée pour réaliser le prochain *commit* exactement
comme vous le voulez.

Cette commande est une commande incroyablement importante dans Git et
est mentionnée ou utilisée des dizaines de fois dans ce livre. Nous
allons revoir rapidement quelques utilisations uniques qui peuvent être
trouvées.

Nous avons d’abord présenté et expliqué `git add` en détails dans
[Placer de nouveaux fichiers sous suivi de version](#s_tracking_files).

Nous mentionnons comment s’en servir pour résoudre les conflits de
fusion dans [Conflits de fusions (*Merge
conflicts*)](#s_basic_merge_conflicts).

Nous la passons en revue pour indexer interactivement seulement des
parties spécifiques d’un fichier modifié dans [Indexation
interactive](#s_interactive_staging).

Enfin, nous l’émulons à bas niveau dans [Les objets
arbres](#s_tree_objects) pour que vous ayez une idée de ce qu’elle fait
en coulisses.

### git status

La commande `git status` vous montrera les différents états des fichiers
de votre répertoire de travail et de l’index. Quels sont les fichiers
modifiés et non indexés et lesquels sont indexés mais pas encore
validés. Dans sa forme normale, elle vous donnera aussi des conseils
basiques sur comment passer les fichiers d’un état à l’autre.

Nous couvrons pour la première fois `status` dans [Vérifier l’état des
fichiers](#s_checking_status), à la fois dans sa forme basique et dans
sa forme simplifiée. Bien que nos l’utilisions tout au long du livre,
pratiquement tout ce que vous pouvez faire avec la commande `git status`
y est couvert.

### git diff

La commande `git diff` s’utilise lorsque vous voulez voir la différence
entre deux arbres. Cela peut être la différence entre votre répertoire
de travail et votre index (`git diff` en elle-même), entre votre index
et votre dernier *commit* (`git diff --staged`) ou entre deux *commits*
(`git diff master brancheB`).

Nous regardons d’abord les utilisations basiques de `git diff` dans
[Inspecter les modifications indexées et non
indexées](#s_git_diff_staged) où nous montrons comment voir quels
changements sont indexés et lesquels ne le sont pas.

Nous l’utilisons pour chercher de possibles problèmes d’espaces blancs
avant de valider avec l’option `--check` dans [Guides pour une
validation](#s_commit_guidelines).

Nous voyons comment vérifier les différences entre branches plus
efficacement avec la syntaxe `git diff A...B` dans [Déterminer les
modifications introduites](#s_what_is_introduced).

Nous l’utilisons pour filtrer les différences d’espaces blancs avec `-w`
et comment comparer différentes étapes de fichiers conflictuels avec
`--theirs`, `--ours` et `--base` dans [Fusion
avancée](#s_advanced_merging).

Enfin, nous l’utilisons pour comparer efficacement les modifications de
sous-modules avec `--submodule` dans [Démarrer un
sous-module](#s_starting_submodules).

### git difftool

La commande `git difftool` lance simplement un outil externe pour vous
montrer la différence entre deux arbres dans le cas où vous voudriez
utiliser quelque chose de différent de la commande `git diff` intégrée.

Nous ne mentionnons ceci que brièvement dans [Git Diff dans un outil
externe](#s_git_difftool).

### git commit

La commande `git commit` prend tout le contenu des fichiers qui ont été
indexés avec `git add` et enregistre un nouvel instantané permanent dans
la base de données puis fait pointer la branche courante dessus.

Nous couvrons d’abord les bases de la validation dans [Valider vos
modifications](#s_committing_changes). Là nous montrons aussi comment
utiliser l’option `-a` pour sauter l’étape `git add` dans le travail
quotidien et comment utiliser l’option `-m` pour passer un message de
validation en ligne de commande plutôt que d’ouvrir un éditeur.

Dans [Annuler des actions](#s_undoing), nous couvrons l’utilisation de
l’option `--amend` pour refaire le *commit* le plus récent.

Dans [Les branches en bref](#s_git_branches_overview), nous allons plus
dans le détail sur ce que `git commit` fait et pourquoi elle le fait
ainsi.

Nous avons vu comment signer cryptographiquement les *commits* avec
l’option `-S` dans [Signer des *commits*](#s_signing_commits).

Enfin, nous regardons ce que la commande `git commit` fait en coulisses
et comment elle est réellement implémentée dans [Les objets
*commit*](#s_git_commit_objects).

### git reset

La commande `git reset` est d’abord utilisée pour défaire des choses,
comme son nom l’indique. Elle modifie le pointeur `HEAD` et change
optionnellement l’index et peut aussi modifier le répertoire de travail
si vous l’utilisez avec l’option `--hard`. Cette dernière option rend
possible la perte de votre travail par cette commande si elle est mal
employée, alors soyez certain de bien la comprendre avant de l’utiliser.

Nous couvrons d’abord effectivement le cas le plus simple de `git reset`
dans [Désindexer un fichier déjà indexé](#s_unstaging) où nous
l’utilisons pour désindexer un fichier sur lequel nous avons lancé
`git add`.

Nous la couvrons ensuite de façon assez détaillée dans [Reset
démystifié](#s_git_reset), qui est entièrement dédié à l’explication de
cette commande.

Nous utilisons `git reset --hard` pour annuler une fusion dans
[Abandonner une fusion](#s_abort_merge), où nous utilisons aussi
`git merge --abort`, qui est un peu un enrobage pour la commande
`git reset`.

### git rm

La commande `git rm` est utilisée pour supprimer des fichiers de l’index
et du répertoire de travail pour Git. Elle est similaire à `git add`
dans le sens où elle indexe la suppression d’un fichier pour le prochain
*commit*.

Nous couvrons la commande `git rm` dans le détail dans [Effacer des
fichiers](#s_removing_files), y compris en supprimant récursivement les
fichiers et en ne supprimant les fichiers que de l’index mais en les
laissant dans le répertoire de travail avec `--cached`.

Le seul autre usage différent de `git rm` dans le livre est dans
[Suppression d’objets](#s_removing_objects) où nous utilisons et
expliquons brièvement l’option `--ignore-unmatch` quand nous lançons
`git filter-branch`, qui ne sort tout simplement pas d’erreur lorsque le
fichier que nous essayons de supprimer n’existe pas. Cela peut être
utile dans le but d’utiliser des scripts.

### git mv

La commande `git mv` est une commande de faible utilité pour renommer un
fichier et ensuite lancer `git add` sur le nouveau fichier et `git rm`
sur l’ancien.

Nous ne mentionnons cette commande que brièvement dans [Déplacer des
fichiers](#s_git_mv).

### git clean

La commande `git clean` est utilisée pour supprimer les fichiers
indésirables de votre répertoire de travail. Cela peut aller de la
suppression des fichiers temporaires de compilation jusqu’aux fichiers
de conflit de fusion.

Nous couvrons une grande part des options et des scénarios dans lesquels
vous pourriez utiliser la commande `clean` dans [Nettoyer son répertoire
de travail](#s_git_clean).

## Création de branches et fusion

Il y a une poignée seulement de commandes qui implémentent la plupart
des fonctionnalités de branche et de fusion dans Git.

### git branch

La commande `git branch` est en fait une sorte d’outil de gestion de
branche. Elle peut lister les branches que vous avez, créer une nouvelle
branche, supprimer des branches et renommer des branches.

La plus grande partie de [Les branches avec Git](#ch03-git-branching)
est dédiée à la commande `branch` et elle est utilisée tout au long du
chapitre. Nous la présentons d’abord dans [Créer une nouvelle
branche](#s_create_new_branch) et nous explorons la plupart de ses
autres fonctionnalités (listage et suppression) dans [Gestion des
branches](#s_branch_management).

Dans [Suivre les branches](#s_tracking_branches), nous utilisons
l’option `git branch -u` pour définir une branche de suivi.

Enfin, nous explorons une partie de ce qu’elle fait en arrière-plan dans
[Références Git](#s_git_refs).

### git checkout

La commande `git checkout` est utilisée pour passer d’une branche à
l’autre et en extraire le contenu dans votre répertoire de travail.

Nous rencontrons cette commande pour la première fois dans [Basculer
entre les branches](#s_switching_branches) avec la commande
`git branch`.

Nous voyons comment l’utiliser pour commencer à suivre des branches avec
l’option `--track` dans [Suivre les branches](#s_tracking_branches).

Nous nous en servons pour réintroduire des conflits de fichiers avec
`--conflict=diff3` dans [Examiner les
conflits](#s_checking_out_conflicts).

Nous allons plus en détail sur sa relation avec `git reset` dans [Reset
démystifié](#s_git_reset).

Enfin, nous voyons quelques détails d’implémentation dans [La branche
HEAD](#s_the_head).

### git merge

L’outil `git merge` est utilisé pour fusionner une ou plusieurs branches
dans la branche que vous avez extraite. Il avancera donc la branche
courante au résultat de la fusion.

La commande `git merge` est d’abord présentée dans
[Branches](#s_basic_branching). Bien qu’elle soit utilisée à plusieurs
endroits du livre, il n’y a que peu de variations de la commande
`merge` — généralement juste `git merge <branche>` avec le nom de la
seule branche que vous voulez fusionner.

Nous avons couvert comment faire une fusion écrasée (dans laquelle Git
fusionne le travail mais fait comme si c’était juste un nouveau *commit*
sans enregistrer l’historique de la branche dans laquelle vous
fusionnez) à la toute fin de [Projet public
dupliqué](#s_public_project).

Nous avons exploré une grande partie du processus de fusion et de la
commande, y compris la commande `-Xignore-all-whitespace` et l’option
`--abort` pour abandonner un problème du fusion dans [Fusion
avancée](#s_advanced_merging).

Nous avons appris à vérifier les signatures avant de fusionner si votre
projet utilise la signature GPG dans [Signer des
*commits*](#s_signing_commits).

Enfin, nous avons appris la fusion de sous-arbre dans [Subtree
Merging](#s_subtree_merge).

### git mergetool

La commande `git mergetool` se contente de lancer un assistant de fusion
externe dans le cas où vous rencontrez des problèmes de fusion dans Git.

Nous la mentionnons rapidement dans [Conflits de fusions (*Merge
conflicts*)](#s_basic_merge_conflicts) et détaillons comment implémenter
votre propre outil externe dans [Outils externes de fusion et de
différence](#s_external_merge_tools).

### git log

La commande `git log` est utilisée pour montrer l’historique enregistré
atteignable d’un projet en partant du *commit* le plus récent. Par
défaut, elle vous montrera seulement l’historique de la branche sur
laquelle vous vous trouvez, mais elle accepte des branches ou sommets
différents ou même multiples comme points de départ de parcours. Elle
est aussi assez souvent utilisée pour montrer les différences entre deux
ou plusieurs branches au niveau *commit*.

Cette commande est utilisée dans presque tous les chapitres du livre
pour exposer l’historique d’un projet.

Nous présentons la commande et la parcourons plus en détail dans
[Visualiser l’historique des validations](#s_viewing_history). Là nous
regardons les options `-p` et `--stat` pour avoir une idée de ce qui a
été introduit dans chaque *commit* et les options `--pretty` et
`--oneline` pour voir l’historique de manière plus concise, avec
quelques options simples de filtre de date et d’auteur.

Dans [Créer une nouvelle branche](#s_create_new_branch), nous
l’utilisons avec l’option `--decorate` pour visualiser facilement où se
trouvent nos pointeurs de branche et nous utilisons aussi l’option
`--graph` pour voir à quoi ressemblent les historiques divergents.

Dans [Cas d’une petite équipe privée](#s_private_team) et [Plages de
*commits*](#s_commit_ranges), nous couvrons la syntaxe
`brancheA..brancheB` que nous utilisons avec la commande `git log` pour
voir quels *commits* sont propres à une branche relativement à une autre
branche. Dans [Plages de *commits*](#s_commit_ranges), nous explorons
cela de manière assez détaillée.

Dans [Journal de fusion](#s_merge_log) et [Triple point](#s_triple_dot),
nous couvrons l’utilisation du format `brancheA...brancheB` et de la
syntaxe `--left-right` pour voir ce qui est dans une branche ou l’autre
mais pas dans les deux à la fois. Dans [Journal de
fusion](#s_merge_log), nous voyons aussi comment utiliser l’option
`--merge` comme aide au débogage de conflit de fusion tout comme
l’utilisation de l’option `--cc` pour regarder les conflits de *commits*
de fusion dans votre historique.

Dans [Raccourcis RefLog](#s_git_reflog), nous utilisons l’option `-g`
pour voir le reflog Git à travers cet outil au lieu de faire le parcours
de la branche.

Dans [Recherche](#s_searching), nous voyons l’utilisation des options
`-S` et `-L` pour faire des recherches assez sophistiquées sur quelque
chose qui s’est passé historiquement dans le code comme voir
l’historique d’une fonction.

Dans [Signer des *commits*](#s_signing_commits), nous voyons comment
utiliser `--show-signature` pour ajouter un message de validation pour
chaque *commit* dans la sortie de `git log` basé sur le fait qu’il ait
ou qu’il n’ait pas une signature valide.

### git stash

La commande `git stash` est utilisée pour remiser temporairement du
travail non validé afin d’obtenir un répertoire de travail propre sans
avoir à valider du travail non terminé dans une branche.

Elle est entièrement décrite simplement dans [Remisage et
nettoyage](#s_git_stashing).

### git tag

La commande `git tag` est utilisée pour placer un signet permanent à un
point spécifique de l’historique du code. C’est généralement utilisé
pour marquer des choses comme des publications.

Cette commande est présentée et couverte en détail dans
[Étiquetage](#s_git_tagging) et nous la mettons en pratique dans
[Étiquetage de vos publications](#s_tagging_releases).

Nous couvrons aussi comment créer une étiquette signée avec l’option
`-s` et en vérifier une avec l’option `-v` dans [Signer votre
travail](#s_signing).

## Partage et mise à jour de projets

Il n’y a pas vraiment beaucoup de commandes dans Git qui accèdent au
réseau ; presque toutes les commandes agissent sur la base de données
locale. Quand vous êtes prêt à partager votre travail ou à tirer les
changements depuis ailleurs, il y a une poignée de commandes qui
échangent avec les dépôts distants.

### git fetch

La commande `git fetch` communique avec un dépôt distant et rapporte
toutes les informations qui sont dans ce dépôt qui ne sont pas dans le
vôtre et les stocke dans votre base de données locale.

Nous voyons cette commande pour la première fois dans [Récupérer et
tirer depuis des dépôts distants](#s_fetching_and_pulling) et nous
continuons à voir des exemples d’utilisation dans [Branches de suivi à
distance](#s_remote_branches).

Nous l’utilisons aussi dans plusieurs exemples dans [Contribution à un
projet](#s_contributing_project).

Nous l’utilisons pour aller chercher une seule référence spécifique qui
est hors de l’espace par défaut dans [Références aux requêtes de
tirage](#s_pr_refs) et nous voyons comment aller chercher depuis un
paquet dans [Empaquetage (*bundling*)](#s_bundling).

Nous définissons des refspecs hautement personnalisées dans le but de
faire faire à `git fetch` quelque chose d’un peu différent que le
comportement par défaut dans [La *refspec*](#s_refspec).

### git pull

La commande `git pull` est essentiellement une combinaison des commandes
`git fetch` et `git merge`, où Git ira chercher les modifications depuis
le dépôt distant que vous spécifiez et essaie immédiatement de les
fusionner dans la branche dans laquelle vous vous trouvez.

Nous la présentons rapidement dans [Récupérer et tirer depuis des dépôts
distants](#s_fetching_and_pulling) et montrons comment voir ce qui sera
fusionné si vous la lancez dans [Inspecter un dépôt
distant](#s_inspecting_remote).

Nous voyons aussi comment s’en servir pour nous aider dans les
difficultés du rebasage dans [Rebaser quand vous
rebasez](#s_rebase_rebase).

Nous montrons comment s’en servir avec une URL pour tirer ponctuellement
les modifications dans [Vérification des branches
distantes](#s_checking_out_remotes).

Enfin, nous mentionnons très rapidement que vous pouvez utiliser
l’option `--verify-signatures` dans le but de vérifier que les *commits*
que vous tirez ont une signature GPG dans [Signer des
*commits*](#s_signing_commits).

### git push

La commande `git push` est utilisée pour communiquer avec un autre
dépôt, calculer ce que votre base de données locale a et que le dépôt
distant n’a pas, et ensuite pousser la différence dans l’autre dépôt.
Cela nécessite un droit d’écriture sur l’autre dépôt et donc normalement
de s’authentifier d’une manière ou d’une autre.

Nous voyons la commande `git push` pour la première fois dans [Pousser
son travail sur un dépôt distant](#s_pushing_remotes). Ici nous couvrons
les bases de la poussée de branche vers un dépôt distant. Dans [Pousser
les branches](#s_pushing_branches), nous allons un peu plus loin dans la
poussée de branches spécifiques et dans [Suivre les
branches](#s_tracking_branches) nous voyons comment définir des branches
de suivi pour y pousser automatiquement. Dans [Suppression de branches
distantes](#s_delete_branches), nous utilisons l’option `--delete` pour
supprimer une branche sur le serveur avec `git push`.

Tout au long de [Contribution à un projet](#s_contributing_project),
nous voyons plusieurs exemples d’utilisation de `git push` pour partager
du travail sur des branches à travers de multiples dépôts distants.

Nous voyons dans [Partager les étiquettes](#s_sharing_tags) comment s’en
servir avec l’option `--tags` pour partager des étiquettes que vous avez
faites.

Dans [Publier les modifications dans un
sous-module](#s_publishing_submodules), nous utilisons l’option
`--recurse-submodules` pour vérifier que tout le travail de nos
sous-modules a été publié avant de pousser le super-projet, ce qui peut
être vraiment utile quand on utilise des sous-modules.

Dans [Autres crochets côté client](#s_other_client_hooks), nous
discutons brièvement du crochet `pre-push`, qui est un script que nous
pouvons installer pour se lancer avant qu’une poussée ne s’achève pour
vérifier qu’elle devrait être autorisée à pousser.

Enfin, dans [Pousser des *refspecs*](#s_pushing_refspecs), nous
considérons une poussée avec une refspec complète au lieu des raccourcis
généraux qui sont normalement utilisés. Ceci peut vous aider à être très
spécifique sur le travail que vous désirez partager.

### git remote

La commande `git remote` est un outil de gestion pour votre base de
dépôts distants. Elle vous permet de sauvegarder de longues URLs en tant
que raccourcis, comme « origin », pour que vous n’ayez pas à les taper
dans leur intégralité tout le temps. Vous pouvez en avoir plusieurs et
la commande `git remote` est utilisée pour les ajouter, les modifier et
les supprimer.

Cette commande est couverte en détail dans [Travailler avec des dépôts
distants](#s_remote_repos), y compris leur listage, ajout, suppression
et renommage.

Elle est aussi utilisée dans presque tous les chapitres suivants du
livre, mais toujours dans le format standard
`git remote add <nom> <URL>`.

### git archive

La commande `git archive` est utilisée pour créer un fichier d’archive
d’un instantané spécifique du projet.

Nous utilisons `git archive` pour créer une archive d’un projet pour
partage dans [Préparation d’une publication](#s_preparing_release).

### git submodule

La commande `git submodule` est utilisée pour gérer des dépôts externes
à l’intérieur de dépôts normaux. Cela peut être pour des bibliothèques
ou d’autres types de ressources partagées. La commande `submodule` a
plusieurs sous-commandes (`add`, `update`, `sync`, etc) pour la gestion
de ces ressources.

Cette commande est mentionnée et entièrement traitée uniquement dans
[Sous-modules](#s_git_submodules).

## Inspection et comparaison

### git show

La commande `git show` peut montrer un objet Git d’une façon simple et
lisible pour un être humain. Vous l’utiliseriez normalement pour montrer
les informations d’une étiquette ou d’un *commit*.

Nous l’utilisons d’abord pour afficher l’information d’une étiquette
annotée dans [Les étiquettes annotées](#s_annotated_tags).

Plus tard nous l’utilisons un petit peu dans [Sélection des
versions](#s_revision_selection) pour montrer les *commits* que nos
diverses sélections de versions résolvent.

Une des choses les plus intéressantes que nous faisons avec `git show`
est dans [Re-fusion manuelle d’un fichier](#s_manual_remerge) pour
extraire le contenu de fichiers spécifiques d’étapes différentes durant
un conflit de fusion.

### git shortlog

La commande `git shortlog` est utilisée pour résumer la sortie de
`git log`. Elle prendra beaucoup des mêmes options que la commande
`git log` mais au lieu de lister tous les *commits*, elle présentera un
résumé des *commits* groupés par auteur.

Nous avons montré comment s’en servir pour créer un joli journal des
modifications dans [Shortlog](#s_the_shortlog).

### git describe

La commande `git describe` est utilisée pour prendre n’importe quelle
chose qui se résoud en un *commit* et produit une chaîne de caractères
qui est somme toute lisible pour un être humain et qui ne changera pas.
C’est une façon d’obtenir une description d’un *commit* qui est aussi
claire qu’un SHA de *commit* mais en plus compréhensible.

Nous utilisons `git describe` dans [Génération d’un nom de
révision](#s_build_number) et [Préparation d’une
publication](#s_preparing_release) pour obtenir une chaîne de caractères
pour nommer notre fichier de publication après.

## Débogage

Git possède quelques commandes qui sont utilisées pour aider à déboguer
un problème dans votre code. Cela va de comprendre où quelque chose a
été introduit à comprendre qui l’a introduite.

### git bisect

L’outil `git bisect` est un outil de débogage incroyablement utile
utilisé pour trouver quel *commit* spécifique a le premier introduit un
bug ou problème en faisant une recherche automatique par dichotomie.

Il est complètement couvert dans [Recherche
dichotomique](#s_binary_search) et n’est mentionné que dans cette
section.

### git blame

La commande `git blame` annote les lignes de n’importe quel fichier avec
quel *commit* a été le dernier à introduire un changement pour chaque
ligne du fichier et quelle personne est l’auteur de ce *commit*. C’est
utile pour trouver la personne pour lui demander plus d’informations sur
une section spécifique de votre code.

Elle est couverte dans [Fichier annoté](#s_file_annotation) et n’est
mentionnée que dans cette section.

### git grep

La commande `git grep` peut aider à trouver n’importe quelle chaîne de
caractères ou expression régulière dans n’importe quel fichier de votre
code source, même dans des anciennes versions de votre projet.

Elle est couverte dans [Git grep](#s_git_grep) et n’est mentionnée que
dans cette section.

## Patchs

Quelques commandes dans Git sont centrées sur la considération des
*commits* en termes de changements qu’ils introduisent, comme si les
séries de *commits* étaient des séries de patchs. Ces commandes vous
aident à gérer vos branches de cette manière.

### git cherry-pick

La commande `git cherry-pick` est utilisée pour prendre les
modifications introduites dans un seul *commit* Git et essaye de les
réintroduire en tant que nouveau *commit* sur la branche sur laquelle
vous vous trouvez. Cela peut être utile pour prendre un ou deux
*commits* sur une branche individuellement plutôt que fusionner dans la
branche, ce qui prend toutes les modifications.

La sélection de *commits* est décrite et démontrée dans [Gestion par
rebasage et sélection de *commit*](#s_rebase_cherry_pick).

### git rebase

La commande `git rebase` est simplement un `cherry-pick` automatisé.
Elle détermine une série de *commits* puis les sélectionne et les
ré-applique un par un dans le même ordre ailleurs.

Le rebasage est couvert en détail dans [Rebaser
(*Rebasing*)](#s_rebasing), y compris l’étude des problèmes de
collaboration induits par le rebasage de branches qui sont déjà
publiques.

Nous la mettons en pratique tout au long d’un exemple de scission de
votre historique en deux dépôts séparés dans [Replace](#s_replace), en
utilisant aussi l’option `--onto`.

Nous explorons un conflit de fusion de rebasage dans
[Rerere](#s_sect_rerere).

Nous l’utilisons aussi dans un mode de script interactif avec l’option
`-i` dans [Modifier plusieurs messages de
validation](#s_changing_multiple).

### git revert

La commande `git revert` est fondamentalement le contraire de
`git cherry-pick`. Elle crée un *commit* qui applique l’exact opposé des
modifications introduites par le *commit* que vous ciblez,
essentiellement en le défaisant ou en revenant dessus.

Nous l’utilisons dans [Inverser le *commit*](#s_reverse_commit) pour
défaire un *commit* de fusion.

## Courriel

Beaucoup de projets Git,y compris Git lui-même,sont entièrement
maintenus à travers des listes de diffusion de courrier électronique.
Git possède un certain nombre d’outils intégrés qui aident à rendre ce
processus plus facile, depuis la génération de patchs que vous pouvez
facilement envoyer par courriel jusqu’à l’application de ces patchs
depuis une boîte de courrier électronique.

### git apply

La commande `git apply` applique un patch créé avec la commande
`git diff` ou même la commande GNU diff. C’est similaire à ce que la
commande `patch` ferait avec quelques petites différences.

Nous démontrons son utilisation et les circonstances dans lesquelles
vous pourriez ainsi faire dans [Application des patchs à partir de
courriel](#s_patches_from_email).

### git am

La commande `git am` est utilisée pour appliquer des patchs depuis une
boîte de réception de courrier électronique, en particulier ceux qui
sont dans le format mbox. C’est utile pour recevoir des patchs par
courriel et les appliquer à votre projet facilement.

Nous avons couvert l’utilisation et le flux de travail autour de
`git am` dans [Application d’un patch avec `am`](#s_git_am), y compris
en utilisant les options `--resolved`, `-i` et `-3`.

Il y a aussi un certain nombre de crochets dont vous pouvez vous servir
pour vous aider dans le flux de travail autour de `git am` et ils sont
tous couverts dans [Crochets de gestion courriel](#s_email_hooks).

Nous l’utilisons aussi pour appliquer les modifications d’un patch au
format « GitHub Pull Request » dans [Notifications par
courriel](#s_email_notifications).

### git format-patch

La commande `git format-patch` est utilisée pour générer une série de
patchs au format mbox que vous pouvez envoyer à une liste de diffusion
proprement formattée.

Nous explorons un exemple de contribution à un projet en utilisant
l’outil `git format-patch` dans [Projet public via
courriel](#s_project_over_email).

### git imap-send

La commande `git imap-send` téléverse une boîte mail générée avec
`git format-patch` dans un dossier « brouillons » IMAP.

Nous explorons un exemple de contribution à un projet par envoi de
patchs avec l’outil `git imap-send` dans [Projet public via
courriel](#s_project_over_email).

### git send-email

La commande `git send-email` est utilisée pour envoyer des patchs
générés avec `git format-patch` par courriel.

Nous explorons un exemple de contribution à un projet en envoyant des
patchs avec l’outil `git send-email` dans [Projet public via
courriel](#s_project_over_email).

### git request-pull

La commande `git request-pull` est simplement utilisée pour générer un
exemple de corps de message à envoyer par courriel à quelqu’un. Si vous
avez une branche sur un serveur public et que vous voulez faire savoir à
quelqu’un comment intégrer ces modifications sans envoyer les patchs par
courrier électronique, vous pouvez lancer cette commande et envoyer la
sortie à la personne dont vous voulez qu’elle tire les modifications.

Nous démontrons comment utiliser `git request-pull` pour générer un
message de tirage dans [Projet public dupliqué](#s_public_project).

## Systèmes externes

Git est fourni avec quelques commandes pour s’intégrer avec d’autres
systèmes de contrôle de version.

### git svn

La commande `git svn` est utilisée pour communiquer avec le système de
contrôle de version Subversion en tant que client. Cela signifie que
vous pouvez vous servir de Git pour extraire depuis et envoyer des
*commits* à un serveur Subversion.

Cette commande est couverte en profondeur dans [Git et
Subversion](#s_git_svn).

### git fast-import

Pour les autres systèmes de contrôle de version ou pour importer depuis
presque n’importe quel format, vous pouvez utiliser `git fast-import`
pour associer rapidement l’autre format à quelque chose que Git peut
facilement enregistrer.

Cette commande est couverte en profondeur dans [Un importateur
personnalisé](#s_custom_importer).

## Administration

Si vous administrez un dépôt Git ou si vous avez besoin de corriger
quelque chose de façon globale, Git fournit un certain nombre de
commandes administratives pour vous y aider.

### git gc

La commande `git gc` lance le « ramasse-miette » sur votre dépôt, en
supprimant les fichiers superflus de votre base de données et en
empaquetant les fichiers restants dans un format plus efficace.

Cette commande tourne normalement en arrière-plan pour vous, même si
vous pouvez la lancer manuellement si vous le souhaitez. Nous parcourons
quelques exemples dans [Maintenance](#s_git_gc).

### git fsck

La commande `git fsck` est utilisée pour vérifier les problèmes ou les
incohérences de la base de données interne.

Nous l’utilisons rapidement une seule fois dans [Récupération de
données](#s_data_recovery) pour chercher des objets ballants.

### git reflog

La commande `git reflog` explore un journal de là où toutes vos branches
sont passées pendant que vous travailliez pour trouver des *commits* que
vous pourriez avoir perdus en ré-écrivant des historiques.

Nous couvrons cette commande principalement dans [Raccourcis
RefLog](#s_git_reflog), où nous montrons un usage normal et comment
utiliser `git log -g` pour visualiser la même information avec la sortie
de `git log`.

Nous explorons aussi un exemple pratique de récupération d’une telle
branche perdue dans [Récupération de données](#s_data_recovery).

### git filter-branch

La commande `git filter-branch` est utilisée pour réécrire un tas de
*commits* selon des motifs particuliers, comme supprimer un fichier
partout ou filtrer le dépôt entier sur un seul sous-dossier pour
l’extraction d’un projet.

Dans [Supprimer un fichier de chaque
*commit*](#s_removing_file_every_commit), nous expliquons la commande et
explorons différentes options telles que `--commit-filter`,
`--subdirectory-filter` et `--tree-filter`.

Dans [Git-p4](#s_sect_git_p4) et [TFS](#s_git_tfs), nous l’utilisons
pour arranger des dépôts externes importés.

## Commandes de plomberie

Il y a un certain nombre de commandes de plomberie de bas niveau que
nous avons rencontrées dans le livre.

La première que nous avons rencontrée est `ls-remote` dans [Références
aux requêtes de tirage](#s_pr_refs) que nous utilisons pour regarder les
références brutes sur le serveur.

Nous utilisons `ls-files` dans [Re-fusion manuelle d’un
fichier](#s_manual_remerge), [Rerere](#s_sect_rerere) et
[L’index](#s_the_index) pour jeter un coup d’œil plus cru sur ce à quoi
ressemble votre index.

Nous mentionnons aussi `rev-parse` dans [Références de
branches](#s_branch_references) pour prendre n’importe quelle chaîne de
caractères et la transformer en un objet SHA.

Cependant, la plupart des commandes de plomberie de bas niveau que nous
couvrons se trouvent dans [Les tripes de Git](#ch10-git-internals), qui
est plus ou moins ce sur quoi le chapitre se focalise. Nous avons évité
de les utiliser tout au long de la majeure partie du reste du livre.
