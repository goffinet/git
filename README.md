# Apprendre Git (Pro Git v2)

![Page de garde](cover_small.jpg)

Source : [https://github.com/goffinet/git](https://github.com/goffinet/git)

Date de fabrication : {{ gitbook.time }}

Téléchargements des supports

* [PDF](https://git.goffinet.org/pdf.html)
* [MOBI](https://git.goffinet.org/mobi.html)
* [EPUB](https://git.goffinet.org/epub.html)


## Autres références

* **[Pro Git, le livre original](https://book.git-scm.com/book/fr/v2), [PDF](https://github.com/progit/progit2-fr/releases/download/2.1.32/progit_v2.1.32.pdf)**
* [Création d'un compte Github](https://nexus-coding.blogspot.com/2015/10/tutoriel-creation-dun-compte-github-et.html)
* [git - petit guide](http://rogerdudler.github.io/git-guide/index.fr.html), [PDF](http://rogerdudler.github.io/git-guide/files/git_cheat_sheet.pdf)
* [Ajouter une clé SSH à son compte github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)
* [Changer d'origine https en ssh](https://help.github.com/articles/changing-a-remote-s-url/)
* [Git Cheat Sheet from Gitlab](https://about.gitlab.com/images/press/git-cheat-sheet.pdf)

## Exercices pratiques

[Github Learning Lab](https://lab.github.com/courses)

## Auteurs

Scott Chacon

Ben Straub  

<!--

Table des matières

-   [Licence](#_licence)
-   [Préface par Scott Chacon](#_préface_par_scott_chacon)
-   [Préface par Ben Straub](#_préface_par_ben_straub)
-   [Dédicaces](#_dédicaces)
-   [Introduction](#_introduction)
-   [Démarrage rapide](#ch01-introduction)
    -   [À propos de la gestion de
        version](#_À_propos_de_la_gestion_de_version)
    -   [Une rapide histoire de Git](#_une_rapide_histoire_de_git)
    -   [Rudiments de Git](#_rudiments_de_git)
    -   [La ligne de commande](#_la_ligne_de_commande)
    -   [Installation de Git](#_installation_de_git)
    -   [Paramétrage à la première utilisation de Git](#s_first_time)
    -   [Obtenir de l’aide](#s_git_help)
    -   [Résumé](#_résumé)
-   [Les bases de Git](#ch02-git-basics)
    -   [Démarrer un dépôt Git](#s_getting_a_repo)
    -   [Enregistrer des modifications dans le
        dépôt](#_enregistrer_des_modifications_dans_le_dépôt)
    -   [Visualiser l’historique des validations](#s_viewing_history)
    -   [Annuler des actions](#s_undoing)
    -   [Travailler avec des dépôts distants](#s_remote_repos)
    -   [Étiquetage](#s_git_tagging)
    -   [Les alias Git](#s_git_aliases)
    -   [Résumé](#_résumé_2)
-   [Les branches avec Git](#ch03-git-branching)
    -   [Les branches en bref](#s_git_branches_overview)
    -   [Branches et fusions : les
        bases](#_branches_et_fusions_les_bases)
    -   [Gestion des branches](#s_branch_management)
    -   [Travailler avec les branches](#_travailler_avec_les_branches)
    -   [Branches de suivi à distance](#s_remote_branches)
    -   [Rebaser (*Rebasing*)](#s_rebasing)
    -   [Résumé](#_résumé_3)
-   [Git sur le serveur](#ch04-git-server)
    -   [Protocoles](#_protocoles)
    -   [Installation de Git sur un serveur](#s_git_on_the_server)
    -   [Génération des clés publiques SSH](#s_generate_ssh_key)
    -   [Mise en place du serveur](#s_setting_up_server)
    -   [Démon (*Daemon*) Git](#_démon_em_daemon_em_git)
    -   [HTTP intelligent](#_http_intelligent_2)
    -   [GitWeb](#_gitweb)
    -   [GitLab](#_gitlab)
    -   [Git hébergé](#_git_hébergé)
    -   [Résumé](#_résumé_4)
-   [Git distribué](#ch05-distributed-git)
    -   [Développements distribués](#_développements_distribués)
    -   [Contribution à un projet](#s_contributing_project)
    -   [Maintenance d’un projet](#_maintenance_d_un_projet)
    -   [Résumé](#_résumé_7)
-   [GitHub](#ch06-github)
    -   [Configuration et paramétrage d’un
        compte](#_configuration_et_paramétrage_d_un_compte)
    -   [Contribution à un projet](#_contribution_à_un_projet)
    -   [Maintenance d’un projet](#s_maintaining_gh_project)
    -   [Gestion d’un regroupement](#s_github_orgs)
    -   [Écriture de scripts pour
        GitHub](#_Écriture_de_scripts_pour_github)
    -   [Résumé](#_résumé_8)
-   [Utilitaires Git](#ch07-git-tools)
    -   [Sélection des versions](#s_revision_selection)
    -   [Indexation interactive](#s_interactive_staging)
    -   [Remisage et nettoyage](#s_git_stashing)
    -   [Signer votre travail](#s_signing)
    -   [Recherche](#s_searching)
    -   [Réécrire l’historique](#s_rewriting_history)
    -   [Reset démystifié](#s_git_reset)
    -   [Fusion avancée](#s_advanced_merging)
    -   [Rerere](#s_sect_rerere)
    -   [Déboguer avec Git](#_déboguer_avec_git)
    -   [Sous-modules](#s_git_submodules)
    -   [Empaquetage (*bundling*)](#s_bundling)
    -   [Replace](#s_replace)
    -   [Stockage des identifiants](#s_credential_caching)
    -   [Résumé](#_résumé_10)
-   [Personnalisation de Git](#ch08-customizing-git)
    -   [Configuration de Git](#s_git_config)
    -   [Attributs Git](#_attributs_git)
    -   [Crochets Git](#s_git_hooks)
    -   [Exemple de politique gérée par
        Git](#s_an_example_git_enforced_policy)
    -   [Résumé](#_résumé_11)
-   [Git et les autres systèmes](#ch09-git-and-other-scms)
    -   [Git comme client](#_git_comme_client)
    -   [Migration vers Git](#s_migrating)
    -   [Résumé](#_résumé_13)
-   [Les tripes de Git](#ch10-git-internals)
    -   [Plomberie et porcelaine](#s_plumbing_porcelain)
    -   [Les objets de Git](#s_objects)
    -   [Références Git](#s_git_refs)
    -   [Fichiers groupés](#_fichiers_groupés)
    -   [La *refspec*](#s_refspec)
    -   [Les protocoles de transfert](#_les_protocoles_de_transfert)
    -   [Maintenance et récupération de
        données](#_maintenance_et_récupération_de_données)
    -   [Les variables d’environnement](#_les_variables_d_environnement)
    -   [Résumé](#_résumé_14)
-   [Git dans d’autres environnements](#A-git-in-other-environments)
    -   [Interfaces graphiques](#_interfaces_graphiques)
    -   [Git dans Visual Studio](#_git_dans_visual_studio)
    -   [Git dans Eclipse](#_git_dans_eclipse)
    -   [Git dans Bash](#_git_dans_bash)
    -   [Git dans Zsh](#_git_dans_zsh)
    -   [Git dans Powershell](#s_git_powershell)
    -   [Résumé](#_résumé_16)
-   [Embarquer Git dans vos applications](#B-embedding-git)
    -   [Git en ligne de commande](#_git_en_ligne_de_commande)
    -   [Libgit2](#_libgit2)
    -   [JGit](#_jgit)
-   [Commandes Git](#C-git-commands)
    -   [Installation et configuration](#_installation_et_configuration)
    -   [Obtention et création des
        projets](#_obtention_et_création_des_projets)
    -   [Capture d’instantané basique](#_capture_d_instantané_basique)
    -   [Création de branches et
        fusion](#_création_de_branches_et_fusion)
    -   [Partage et mise à jour de
        projets](#_partage_et_mise_à_jour_de_projets)
    -   [Inspection et comparaison](#_inspection_et_comparaison)
    -   [Débogage](#_débogage_2)
    -   [Patchs](#_patchs)
    -   [Courriel](#_courriel)
    -   [Systèmes externes](#_systèmes_externes)
    -   [Administration](#_administration_2)
    -   [Commandes de plomberie](#_commandes_de_plomberie)
-   [Index](#_index)
-->

## Licence


Ce travail est sous licence Creative Commons
Attribution-NonCommercial-ShareAlike 3.0 Unported License. Pour voir une
copie de cette licence, visitez
<a href="http://creativecommons.org/licenses/by-nc-sa/3.0/" class="bare">http://creativecommons.org/licenses/by-nc-sa/3.0/</a>
ou envoyez une lettre à Creative Commons, 171 Second Street, Suite 300,
San Francisco, California, 94105, USA.

## Préface par Scott Chacon

Bienvenue à la seconde édition de Pro Git. La première édition a été
publiée depuis plus de quatre ans maintenant. Depuis lors, beaucoup de
choses ont changé et beaucoup de choses importantes non. Bien que la
plupart des commandes et des concepts clés sont encore valables
aujourd’hui vu que l’équipe du cœur de Git est assez fantastique pour
garder la compatibilité ascendante, il y a eu quelques ajouts
significatifs et des changements dans la communauté qui entoure Git. La
seconde édition de ce livre est faite pour répondre à ces changements et
mettre à jour le livre afin qu’il soit plus utile au nouvel utilisateur.

Quand j’ai écrit la première édition, Git était encore un outil
relativement difficile à utiliser et n’avait pas percé chez les
développeurs purs et durs. Il a commencé à gagner de la popularité dans
certaines communautés, mais n’avait atteint nulle part l’ubiquité qu’il
a aujourd’hui. Depuis, presque toutes les communautés open source l’ont
adopté. Git a fait des progrès incroyables sur Windows, dans la
multiplication des interfaces utilisateur graphiques sur toutes les
plateformes, dans le support IDE et dans l’utilisation commerciale. Le
Pro Git d’il y a quatre ans ne connaît rien de tout cela. Un des
objectifs principaux de cette nouvelle édition est d’aborder toutes ces
nouvelles frontières au sein de la communauté Git.

La communauté Open Source utilisant Git a elle aussi massivement
augmenté. Quand je me suis assis pour écrire pour la première fois le
livre il y a presque cinq ans de cela (ça m’a pris du temps pour sortir
la première version), je venais juste de commencer à travailler dans une
entreprise peu connue développant un site web hébergeant Git appelée
GitHub. Au moment de la publication, il y avait peut-être quelques
milliers de gens utilisant le site et que quatre d’entre nous
travaillant dessus. Pendant que j’écris cette introduction, GitHub est
en train d’annoncer son dix-millionième projet hébergé, avec presque
cinq millions de comptes développeur enregistrés et plus de deux-cent
trente employés. Que vous l’aimiez ou que vous le détestiez, GitHub a
grandement affecté une grande partie de la communauté Open Source d’une
façon difficilement envisageable lorsque j’ai écrit la première édition.

J’ai écrit une petite section dans la version originale de Pro Git sur
GitHub comme exemple de Git hébergé dont je n’ai jamais été très fier.
Je n’ai pas beaucoup aimé écrire sur ce que je considérais comme étant
essentiellement une ressource communautaire et aussi de parler de mon
entreprise. Bien que je n’aime toujours pas ce conflit d’intérêts,
l’importance de GitHub dans la communauté Git est inévitable. Au lieu
d’un exemple d’hébergement Git, j’ai décidé de transformer cette partie
du livre en décrivant plus en détail ce que GitHub est et comment
l’utiliser efficacement. Si vous êtes sur le point d’apprendre à
utiliser Git, alors savoir utiliser GitHub vous aidera à prendre part à
une immense communauté, ce qui est un atout, peu importe quel
hébergement Git vous déciderez d’utiliser pour votre propre code.

L’autre grand changement depuis la dernière publication a été le
développement et l’expansion du protocole HTTP pour les transactions Git
de réseau. La plupart des exemples dans le livre ont été changés en HTTP
depuis SSH parce que c’est beaucoup plus simple.

Il a été stupéfiant de voir Git grandir au cours des dernières années en
partant d’un système de contrôle de version relativement obscur jusqu’à
dominer complètement le contrôle de version commercial et open source.
Je suis très content que Pro Git ait aussi bien marché et qu’il ait été
un des rares livres techniques du marché qui soit à la fois assez réussi
et complètement open source.

J’espère que vous apprécierez cette édition mise à jour de Pro Git.

## Préface par Ben Straub

La première édition de ce livre constitue ce qui m’a fait accrocher à
Git. Ce fut mon introduction à un style de fabrication du logiciel qui
m’a semblé beaucoup plus naturelle que ce que j’avais connu auparavant.
J’avais travaillé comme développeur depuis quelques années déjà, mais
cette bifurcation m’a mené sur un chemin bien plus intéressant que celui
que j’avais déjà emprunté.

À présent, plusieurs années plus tard, je suis un contributeur d’une
implantation majeure de Git, j’ai voyagé à travers le monde pour
enseigner Git. Quand Scott m’a demandé si je serais intéressé pour
travailler sur la seconde édition, je n’y ai pas réfléchi à deux fois.

Ça a été un grand plaisir et un privilège de travailler sur ce livre.
J’espère qu’il vous aidera autant qu’il m’a aidé.

## Dédicaces


*À ma femme, Becky, sans qui cette aventure n’aurait jamais commencé. —
Ben*

*Cette édition est dédiée à mes filles. À ma femme Jessica qui m’a
encouragé durant toutes ces années et à ma fille Joséphine, qui me
supportera quand je serai trop vieux pour comprendre ce qui se passe. —
Scott*
