# Notes sur Gitlab-CI

<!-- toc -->

## Introduction à DevOps et à Gitlab-Ci



## Projet de départ

[Creating and Tweaking GitLab CI/CD for GitLab Pages | GitLab](https://docs.gitlab.com/ee/user/project/pages/getting_started_part_four.html)

[Job spécial Pages et dossier public/](https://docs.gitlab.com/ee/ci/yaml/#pages)

### Essai local

```bash
yum -y install git
```

```bash
git clone https://gitlab.com/pages/gitbook.git
cd gitbook
```

```bash
docker run -it -p 4000:4000 -v $PWD:/gitbook node:latest bash
```

```bash
cd /gitbook
npm install gitbook-cli -g
gitbook install
gitbook serve
```

### Fichier .gitlab-ci.yml

```yaml
# requiring the environment of NodeJS 10
image: node:10

# add 'node_modules' to cache for speeding up builds
cache:
  paths:
    - node_modules/ # Node modules and dependencies

before_script:
  - npm install gitbook-cli -g # install gitbook
  - gitbook fetch 3.2.3 # fetch final stable version
  - gitbook install # add any requested plugins in book.json

test:
  stage: test
  script:
    - gitbook build . public # build to public path
  only:
    - branches # this job will affect every branch except 'master'
  except:
    - master

# the 'pages' job will deploy and build your site to the 'public' path
pages:
  stage: deploy
  script:
    - gitbook build . public # build to public path
  artifacts:
    paths:
      - public
    expire_in: 1 week
  only:
    - master # this job will affect only the 'master' branch
```

```bash
git push
```

## Projets Gitlab Page

[GitLab CI/CD Pipeline Configuration Reference](https://docs.gitlab.com/ee/ci/yaml/README.html)

[Jekyll good-clean-read](https://github.com/goffinet/good-clean-read)

[mkdocs-material-boilerplate](https://github.com/goffinet/mkdocs-material-boilerplate)

[Gitbook Publication](https://github.com/goffinet/gitbook-publication)

## Maven et Apache Tomcat

https://docs.gitlab.com/ee/ci/examples/artifactory_and_gitlab/

Créer un dépôt sur Gilab et le cloner localement.

Importer une clé SSH.

Image Docker maven.

Exemple CI/CD avec Maven, lecture de l'exemple et application https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html.

- test
- build
- deploy

Variables cachées.

Gitlab-runner local.
