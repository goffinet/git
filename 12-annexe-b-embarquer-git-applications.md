# Embarquer Git dans vos applications

<!-- toc -->

Si votre application est destinée aux développeurs, il y a de grandes
chances qu’elle bénéficierait de l’intégration avec une gestion de
source. Même des applications pour non-développeurs, tels que les
éditeurs de document, pourraient potentiellement bénéficier d’une
fonctionnalité de gestion de version et le modèle de Git fonctionne très
bien dans de nombreux scénarios.

Si vous devez intégrer Git avec votre application, vous avez
essentiellement trois choix : démarrer une invite et utiliser la ligne
de commande Git, Libgit2 et JGit.

## Git en ligne de commande

Une possibilité consiste à démarrer un processus d’invite de commande et
à utiliser la ligne de commande Git pour agir. Cette méthode a le
bénéfice d’être canonique et toutes les fonctionnalités de Git sont
supportées. Cela s’avère aussi assez facile, du fait que la plupart des
environnements d’exécution disposent d’une interface relativement simple
permettant d’invoquer un processus avec des arguments en ligne de
commande. Cependant, cette approche a quelques inconvénients.

L’un est que toutes les sorties sont en pur texte. Cela signifie que
vous aurez à analyser le format de sortie de Git qui peut
occasionnellement changer pour lire l’information d’avancée et de
résultat, ce qui peut être inefficace et introduire des erreurs.

Un autre est l’absence de récupération sur erreur. Si le dépôt est
corrompu d’une manière quelconque ou si l’utilisateur a une valeur de
configuration malformée, Git va simplement refuser d’opérer beaucoup
d’opérations.

Un autre encore est la gestion de processus. Git vous oblige à maintenir
un environnement de ligne de commande dans un processus séparé, ce qui
peut ajouter une complexité indésirable. Essayer de coordonner un
certain nombre de tels processus est un problème épineux (spécialement
quand on accède au même dépôt depuis plusieurs processus).

## Libgit2

Une autre option à votre disposition consiste à utiliser Libgit2.
Libgit2 est une mise en œuvre de Git sans dépendance externe, qui se
focalise sur une interface de programmation agréable à utiliser depuis
d’autres programmes. Vous pouvez la trouver sur
<a href="http://libgit2.github.com" class="bare">http://libgit2.github.com</a>.

Voyons d’abord à quoi ressemble l’API C. En voici un tour rapide :

``` highlight
// Ouvrir un depot
git_repository *repo;
int error = git_repository_open(&repo, "/path/to/repository");

// Dereferencer HEAD vers un commit
git_object *head_commit;
error = git_revparse_single(&head_commit, repo, "HEAD^{commit}");
git_commit *commit = (git_commit*)head_commit;

// afficher quelques proprietes du commit
printf("%s", git_commit_message(commit));
const git_signature *author = git_commit_author(commit);
printf("%s <%s>\n", author->name, author->email);
const git_oid *tree_id = git_commit_tree_id(commit);

// Nettoyer
git_commit_free(commit);
git_repository_free(repo);
```

Les deux premières lignes ouvrent un dépôt Git. Le type `git_repository`
représente un identificateur de dépôt avec un cache en mémoire. C’est la
méthode la plus simple, quand vous connaissez le chemin exact vers le
répertoire de travail ou le répertoire `.git` d’un dépôt. Il y a aussi
`git_repository_open_ext` qui inclut des options pour chercher,
`git_clone` et ses déclinaisons pour créer un clone local d’un dépôt
distant et `git_repository_init` pour créer un dépôt entièrement
nouveau.

Le second bloc de code utilise la syntaxe « rev-parse » (voir
[Références de branches](#s_branch_references) pour plus de détails)
pour obtenir le *commit* sur lequel HEAD peut pointer. Le type retourné
est un pointeur sur `git_object` qui représente quelque chose qui existe
dans la base de données des objets de Git pour un dépôt. `git_object`
est en fait une type « parent » pour différentes sortes d’objets ;
l’agencement en mémoire de chacun de ces types « enfants » est identique
à celui de `git_object`, donc on peut forcer la conversion vers le type
désiré en toute sécurité. Dans notre cas, `git_object_type(commit)`
retournerait `GIT_OBJ_COMMIT`, il est donc permis de le convertir en un
pointeur de `git_commit`.

Le bloc suivant montre comment accéder aux propriétés d’un *commit*. La
dernière ligne utilise un type `git_oid` ; c’est la représentation d’une
empreinte SHA-1 dans Libgit2.

De cet exemple, une structure générale commence à émerger :

-   Si vous déclarez un pointeur et que vous en passez une référence
    dans un appel à Libgit2, cet appel renverra vraisemblablement un
    code de retour entier. Une valeur `0` indique un succès ; toute
    valeur négative est une erreur.

-   Si Libgit2 peuple un pointeur pour vous, vous êtes responsable de sa
    libération.

-   Si Libgit2 retourne un pointeur `const` après un appel, vous n’avez
    pas besoin de le libérer mais il deviendra invalide quand l’objet
    qui le possède sera lui-même libéré.

-   Écrire en C est un exercice plutôt douloureux.

Cette dernière remarque signifie qu’il est fort peu probable que vous
écrirez du C pour utiliser Libgit2. Heureusement, il existe un certain
nombre de liaisons vers d’autres langages qui rendent plus facile
l’interaction avec des dépôts Git depuis votre environnement et votre
langage spécifiques. Voyons l’exemple ci-dessus réécrit en utilisant le
portage Ruby de Libgit2, appelé Rugged et qui peut être trouvé sur
<a href="https://github.com/libgit2/rugged" class="bare">https://github.com/libgit2/rugged</a>.

``` highlight
repo = Rugged::Repository.new('path/to/repository')
commit = repo.head.target
puts commit.message
puts "#{commit.author[:name]} <#{commit.author[:email]}>"
tree = commit.tree
```

Tout de suite, le code est moins verbeux. Déjà, Rugged utilise des
exceptions ; il peut lever `ConfigError` ou `ObjectE` pour signaler des
conditions d’erreur. Ensuite, il n’y a pas de libération explicite des
ressources, puisque Ruby utilise un ramasse-miettes. Voyons un exemple
légèrement plus compliqué : créer un *commit* à partir de rien.

``` highlight
blob_id = repo.write("Blob contents", :blob) (1)

index = repo.index
index.read_tree(repo.head.target.tree)
index.add(:path => 'newfile.txt', :oid => blob_id) (2)

sig = {
    :email => "bob@example.com",
    :name => "Bob User",
    :time => Time.now,
}

commit_id = Rugged::Commit.create(repo,
    :tree => index.write_tree(repo), (3)
    :author => sig,
    :committer => sig, (4)
    :message => "Add newfile.txt", (5)
    :parents => repo.empty? ? [] : [ repo.head.target ].compact, (6)
    :update_ref => 'HEAD', (7)
)
commit = repo.lookup(commit_id) (8)
```

|       |                                                                                                                                     |
|-------|-------------------------------------------------------------------------------------------------------------------------------------|
| **1** | Créer un nouveau blob qui contient le contenu d’un nouveau fichier.                                                                 |
| **2** | Peupler l’index avec l’arbre du *commit* HEAD et ajouter le nouveau fichier sous le chemin `newfile.txt`.                           |
| **3** | Ceci crée un nouvel arbre dans la base de données des objets et l’utilise pour le nouveau *commit*.                                 |
| **4** | Nous utilisons la même signature pour l’auteur et le validateur.                                                                    |
| **5** | Le message de validation.                                                                                                           |
| **6** | À la création d’un *commit*, il faut spécifier les parents du nouveau *commit*. on utilise le sommet de HEAD comme parent unique.   |
| **7** | Rugged (et Libgit2) peuvent en option mettre à jour la référence lors de la création du *commit*.                                   |
| **8** | La valeur retournée est une empreinte SHA-1 du nouvel objet *commit* que vous pouvez alors utiliser pour obtenir un objet `Commit`. |

Le code Ruby est joli et propre, mais comme Libgit2 réalise le gros du
travail, il tourne aussi plutôt rapidement. Si vous n’êtes pas rubyiste,
nous aborderons d’autres portages dans [Autres
liaisons](#s_libgit2_bindings).

### Fonctionnalité avancée

Libgit2 a certaines capacités qui ne sont pas disponibles dans Git
natif. Un exemple est la possibilité de greffons : Libgit2 vous permet
de fournir des services « d’arrière-plan » pour différents types
d’opérations, pour vous permettre de stocker les choses d’une manière
différente de Git. Libgit2 autorise des services d’arrière-plan pour la
configuration, le stockage des références et la base de données
d’objets, entre autres.

Voyons comment cela fonctionne. Le code ci-dessous est emprunté à un
ensemble d’exemples de services fourni par l’équipe Libgit2 (qui peut
être trouvé sur
<a href="https://github.com/libgit2/libgit2-backends" class="bare">https://github.com/libgit2/libgit2-backends</a>).
Voici comment un service d’arrière-plan pour une base de données
d’objets peut être créée :

``` highlight
git_odb *odb;
int error = git_odb_new(&odb); (1)

git_odb_backend *my_backend;
error = git_odb_backend_mine(&my_backend, /*…*/); (2)

error = git_odb_add_backend(odb, my_backend, 1); (3)

git_repository *repo;
error = git_repository_open(&repo, "some-path");
error = git_repository_set_odb(odb); (4)
```

*(Notez que les erreurs sont capturées, mais ne sont pas gérées. Nous
espérons que votre code est meilleur que le nôtre).*

|       |                                                                                                                                                                |
|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **1** | Initialise une enveloppe d’interface d’une base de données d’objets vide (ODB) qui agit comme un conteneur pour les tâches de fond qui feront le vrai travail. |
| **2** | Initialise une tâche de fond ODB.                                                                                                                              |
| **3** | Ajoute la tâche de fond dans l’enveloppe.                                                                                                                      |
| **4** | Ouvre le dépôt et le paramètre pour utiliser notre ODB pour rechercher les objets.                                                                             |

Mais qu’est-ce que ce `git_odb_backend_mine` ? Hé bien, c’est le
constructeur de notre propre réalisation de l’ODB et nous pouvons la
faire comme nous voulons tant que la structure `git_odb_backend` est
correctement renseignée. Voici à quoi elle *pourrait* ressembler :

``` highlight
typedef struct {
    git_odb_backend parent;

    // Some other stuff
    void *custom_context;
} my_backend_struct;

int git_odb_backend_mine(git_odb_backend **backend_out, /*…*/)
{
    my_backend_struct *backend;

    backend = calloc(1, sizeof (my_backend_struct));

    backend->custom_context = …;

    backend->parent.read = &my_backend__read;
    backend->parent.read_prefix = &my_backend__read_prefix;
    backend->parent.read_header = &my_backend__read_header;
    // …

    *backend_out = (git_odb_backend *) backend;

    return GIT_SUCCESS;
}
```

La contrainte la plus subtile ici est que le premier membre de
`my_backend_structure` doit être une structure `git_odb_backend` ; cela
assure que la disposition en mémoire correspond à ce qu’attend le code
de Libgit2. Le reste est totalement arbitraire ; cette structure peut
être aussi grande ou petite que nécessaire.

La fonction d’initialisation alloue de la mémoire pour la structure,
initialise le contexte spécifique, puis remplit les membres de la
structure `parent` qu’elle supporte. Référez-vous au fichier
`include/git2/sys/odb_backend.h` dans les sources de Libgit2 pour
l’intégralité des signatures d’appels ; votre cas d’utilisation
particulier vous permettra de déterminer lesquelles vous souhaitez
supporter.

### Autres liaisons

Libgit2 dispose de liaisons vers de nombreux langages. Nous allons
montrer ici un petit exemple en utilisant quelques-unes des liaisons les
plus abouties au moment de la rédaction de ce livre ; des bibliothèques
existent pour de nombreux autres langages qui incluent C++, Go, Node.js,
Erlang et la JVM à différents stades de maturité. La collection
officielle de liaisons peut être trouvée en parcourant les dépôts sur
<a href="https://github.com/libgit2" class="bare">https://github.com/libgit2</a>.

Le code que nous allons écrire retournera le message de validation du
*commit* finalement pointé par HEAD (`git log -1` en quelque sorte).

#### LibGit2Sharp

Si vous écrivez une application .NET ou Mono, LigGit2Sharp
(<a href="https://github.com/libgit2/libgit2sharp" class="bare">https://github.com/libgit2/libgit2sharp</a>)
est tout ce que vous cherchez. Les liaisons sont écrites en C\# et une
grande attention a été portée à envelopper les appels directs à Libgit2
avec une interface de programmation naturelle en C\#. Voici à quoi notre
programme d’exemple ressemble :

``` highlight
new Repository(@"C:\path\to\repo").Head.Tip.Message;
```

Pour les applications graphiques Windows, il existe même un paquet NuGet
qui vous permettra de démarrer vos développements rapidement.

#### objective-git

Si votre application tourne sur une plateforme Apple, vous avez de
grandes chances d’utiliser Objective-C comme langage de programmation.
Objective-Git
(<a href="https://github.com/libgit2/objective-git" class="bare">https://github.com/libgit2/objective-git</a>)
est le nom de la liaison de Libgit2 pour cet environnement.

Le programme d’exemple ressemble à ceci :

``` highlight
GTRepository *repo =
    [[GTRepository alloc] initWithURL:[NSURL fileURLWithPath: @"/path/to/repo"] error:NULL];
NSString *msg = [[[repo headReferenceWithError:NULL] resolvedTarget] message];
```

Objective-git est totalement interopérable avec Swift, donc n’ayez
crainte si vous avez abandonné Objective-C.

#### pygit2

La liaison avec Libgit2 en Python s’appelle Pygit2 et elle peut être
trouvée sur
<a href="http://www.pygit2.org/" class="bare">http://www.pygit2.org/</a>.
Notre programme d’exemple :

``` highlight
pygit2.Repository("/chemin/du/depot") # ouvre le depot
    .head                             # recupere la branche en cours
    .peel(pygit2.Commit)              # descend au commit
    .message                          # lit le message
```

### Pour aller plus loin

Bien sûr, un traitement complet des capacités de Libgit2 est hors du
cadre de ce livre. Si vous souhaitez plus d’information sur Libgit2
elle-même, la documentation de programmation se trouve sur
<a href="https://libgit2.github.com/libgit2" class="bare">https://libgit2.github.com/libgit2</a>
et un ensemble de guides sur
<a href="https://libgit2.github.com/docs" class="bare">https://libgit2.github.com/docs</a>.
Pour les autres liaisons, cherchez dans le README et dans les tests ; il
y a souvent des petits didacticiels et des pointeurs sur d’autres
documents.

## JGit

Si vous voulez utiliser Git depuis un programme Java, il existe une
bibliothèque complète appelée JGit. JGit est une réalisation
relativement complète de Git écrite nativement en Java etelle est
largement utilisée dans la communauté Java. Le projet JGit est développé
sous l’égide d’Eclipse et son site se trouve sur
<a href="http://www.eclipse.org/jgit" class="bare">http://www.eclipse.org/jgit</a>.

### Mise en place

Il y a différents moyens de connecter votre projet à JGit et de
commencer à l’utiliser dans votre code. La manière probablement la plus
facile consiste à utiliser Maven – on réalise l’intégration en ajoutant
la section suivante sous la balise `<dependencies>` de votre fichier
pom.xml :

``` highlight
<dependency>
    <groupId>org.eclipse.jgit</groupId>
    <artifactId>org.eclipse.jgit</artifactId>
    <version>3.5.0.201409260305-r</version>
</dependency>
```

La `version` aura très certainement évolué lorsque vous lirez ces
lignes ; vérifiez
<a href="http://mvnrepository.com/artifact/org.eclipse.jgit/org.eclipse.jgit" class="bare">http://mvnrepository.com/artifact/org.eclipse.jgit/org.eclipse.jgit</a>
pour une information de version mise à jour. Une fois cette étape
accomplie, Maven va automatiquement récupérer et utiliser les
bibliothèques JGit dont vous aurez besoin.

Si vous préférez gérer les dépendances binaires par vous-même, des
binaires JGit pré-construits sont disponibles sur
<a href="http://www.eclipse.org/jgit/download" class="bare">http://www.eclipse.org/jgit/download</a>.
Vous pouvez les inclure dans votre projet en lançant une commande telle
que :

``` highlight
javac -cp .:org.eclipse.jgit-3.5.0.201409260305-r.jar App.java
java -cp .:org.eclipse.jgit-3.5.0.201409260305-r.jar App
```

### Plomberie

JGit propose deux niveaux généraux d’interfaçage logiciel : plomberie et
porcelaine. La terminologie de ces niveaux est directement calquée sur
celle de Git lui-même et JGit est partitionné globalement de la même
manière : les APIs de porcelaine sont une interface de haut niveau pour
des interactions de niveau utilisateur (le genre de choses qu’un
utilisateur normal ferait en utilisant la ligne de commande), tandis que
les APIs de plomberie permettent d’interagir directement avec les objets
de bas niveau du dépôt.

Le point de départ pour la plupart des sessions JGit est la classe
`Repository` et la première action consiste à créer une instance de
celle-ci. Pour un dépôt basé sur un système de fichier (hé oui, JGit
permet d’autre modèles de stockage), cela passe par l’utilisation d’un
`FileRepositoryBuilder` :

``` highlight
// Creer un nouveau depot
Repository newlyCreatedRepo = FileRepositoryBuilder.create(
    new File("/tmp/new_repo/.git"));
newlyCreatedRepo.create();

// Ouvrir un depot existant
Repository existingRepo = new FileRepositoryBuilder()
    .setGitDir(new File("my_repo/.git"))
    .build();
```

Le constructeur contient une API souple qui fournit tout ce dont il a
besoin pour trouver un dépôt Git, que votre programme sache ou ne sache
pas exactement où il est situé. Il peut utiliser des variables
d’environnement (`.readEnvironment()`), démarrer depuis le répertoire de
travail et chercher (`setWorkTree(…).findGitDir()`) ou juste ouvrir un
répertoire `.git` connu, comme ci-dessus.

Une fois muni d’une instance de `Repository`, vous pouvez faire toutes
sortes de choses avec. En voici un échantillon rapide :

``` highlight
// acceder a une reference
Ref master = repo.getRef("master");

// acceder a l'objet pointe par une reference
ObjectId masterTip = master.getObjectId();

// Rev-parse
ObjectId obj = repo.resolve("HEAD^{tree}");

// Charger le contenu brut d'un objet
ObjectLoader loader = repo.open(masterTip);
loader.copyTo(System.out);

// Creer une branche
RefUpdate createBranch1 = repo.updateRef("refs/heads/branch1");
createBranch1.setNewObjectId(masterTip);
createBranch1.update();

// Delete a branch
RefUpdate deleteBranch1 = repo.updateRef("refs/heads/branch1");
deleteBranch1.setForceUpdate(true);
deleteBranch1.delete();

// Config
Config cfg = repo.getConfig();
String name = cfg.getString("user", null, "name");
```

Il y a pas mal de choses mises en œuvre ici, donc nous allons détailler
chaque section.

La première ligne récupère un pointeur sur la référence `master`. JGit
récupère automatiquement la référence master *réelle* qui se situe dans
`refs/heads/master` et retourne un objet qui vous permet de récupérer
des informations sur cette référence. Vous pouvez récupérer le nom
(`.getName()`) ou bien l’objet cible de la référence directe
(`.getObjectId()`), ou encore la référence pointée par une référence
symbolique (`.getTarget()`). Les objets de référence sont aussi utilisés
pour représenter les références d’étiquette ou des objets, donc vous
pouvez demander si l’étiquette est « pelée », ce qui signifie qu’elle
pointe sur une cible finale d’une série (potentiellement longue)
d’objets étiquettes.

La seconde ligne donne la cible de la référence `master` qui est
retournée comme une instance d’ObjectId. ObjectId représente l’empreinte
SHA-1 d’un objet qui peut exister ou non dans la base de données des
objets de Git. La troisième ligne est similaire, mais elle montre
comment JGit gère la syntaxe « rev-parse » (pour plus d’information,
voir [Références de branches](#s_branch_references)). Vous pouvez passer
n’importe quel spécificateur d’objet que Git comprend et JGit retournera
un ObjectId valide ou bien `null`.

Les deux lignes suivantes montrent comment charger le contenu brut d’un
objet. Dans cet exemple, nous appelons `ObjectLoader.copyTo()` pour
rediriger le contenu de l’objet directement sur la sortie standard, mais
`ObjectLoader` dispose aussi de méthodes pour lire le type et la taille
d’un objet et le retourner dans un tableau d’octets. Pour les gros
objets (pour lesquels `.isLarge()` renvoie `true`), vous pouvez appeler
`.openStream()` pour récupérer un objet similaire à InputStream qui peut
lire l’objet brut sans le tirer intégralement en mémoire vive.

Les quelques lignes suivantes montrent ce qui est nécessaire pour créer
une nouvelle branche. Nous créons une instance de RefUpdate, configurons
quelques paramètres et appelons `.update()` pour déclencher la
modification. Le code pour effacer cette branche suit juste après. Notez
que `.setForceUpdate(true)` est nécessaire pour que cela fonctionne ;
sinon l’appel à `.delete()` retourne `REJECTED` et il ne se passera
rien.

Le dernier exemple montre comment récupérer la valeur `user.name` depuis
les fichiers de configuration de Git. Cette instance de Config utilise
le dépôt que nous avons ouvert plus tôt pour la configuration locale,
mais détectera automatiquement les fichiers de configuration globale et
système et y lira aussi les valeurs.

Ceci n’est qu’un petit échantillon de toute l’API de plomberie ; il
existe beaucoup d’autre méthodes et classes. Ici, nous ne montrons pas
non plus comment JGit gère les erreurs, au moyen d’exceptions. Les APIs
JGit lancent quelques fois des exceptions Java standard (telles que
`IOException`), mais il existe aussi une liste de types d’exception
spécifiques à JGit (tels que `NoRemoteRepositoryException`,
`CorruptObjectException` et `NoMergeBaseException`).

### Porcelaine

Les APIs de plomberie sont plutôt complètes, mais il peut s’avérer lourd
de les enchaîner pour des activités fréquentes, telles que l’ajout de
fichier à l’index ou la validation. JGit fournit un ensemble de plus
haut niveau d’APIs pour simplifier celles-ci et le point d’entrée pour
ces APIs est la classe `Git` :

``` highlight
Repository repo;
// construit le depot...
Git git = new Git(repo);
```

La classe Git propose un joli ensemble de méthodes de haut niveau de
style `builder` qui peuvent être utilisées pour construire des
comportements assez complexes. Voyons un exemple, tel que recréer
quelque chose comme `git ls-remote` :

``` highlight
CredentialsProvider cp = new UsernamePasswordCredentialsProvider("username", "p4ssw0rd");
Collection<Ref> remoteRefs = git.lsRemote()
    .setCredentialsProvider(cp)
    .setRemote("origin")
    .setTags(true)
    .setHeads(false)
    .call();
for (Ref ref : remoteRefs) {
    System.out.println(ref.getName() + " -> " + ref.getObjectId().name());
}
```

C’est la structure habituelle avec la classe Git ; les méthodes
renvoient un objet commande qui permet d’enchaîner les appels de
paramétrage qui sont finalement exécutés par l’appel à `.call()`. Dans
notre cas, nous interrogeons le dépôt distant `origin` sur ses
étiquettes, et non sur ses sommets de branches. Notez aussi
l’utilisation d’un objet `CredentialsProvider` pour l’authentification.

De nombreuses autres commandes sont disponibles au travers de la classe
Git, dont entre autres `add`, `blame`, `commit`, `clean`, `push`,
`rebase`, `revert` et `reset`.

### Pour aller plus loin

Tout ceci n’est qu’un mince échantillon de toutes les capacités de JGit.
Si vous êtes intéressé et souhaitez en savoir plus, voici des liens vers
plus d’information et d’inspiration :

-   La documentation officielle de l’API JGit est disponible sur
    <a href="http://download.eclipse.org/jgit/docs/latest/apidocs" class="bare">http://download.eclipse.org/jgit/docs/latest/apidocs</a>.
    Il existe des Javadoc standard, donc votre EDI JVM favori sera aussi
    capable de les installer localement.

-   Le livre de recettes JGit
    <a href="https://github.com/centic9/jgit-cookbook" class="bare">https://github.com/centic9/jgit-cookbook</a>
    contient de nombreux exemples de réalisation de différentes tâches
    avec JGit.
