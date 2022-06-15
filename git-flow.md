# Git Flow

Usando o git-flow  [Tutorial Atlassian](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow).

> Mapa do GitFlow

![GitFlow](/img/gitflow.png "GitFow")

```bash
# Install Git
sudo pacman -S git

# Install git Flow
yay -S gitflow-avh

```

## Inicializando o Git-Flow

Para inicializar, executar **git flow init**, e deixe todas as confirmações como padrão.

```bash

git flow init


```

## Usando o Git Flow

Use normalmente, git add --all, git commit -m "Info"..

### Usando Feature

```bash

# Usando Feature
git flow feature start NOME_DA_MINHA_FEATURE
git add --all
git commit -m "info sobre o commit"

# Sew desejar compartilhar a Feature, faz o publish
# com isso, outros desenvolvedores podem baixar
git flow feature publish NOME_DA_MINHA_FEATURE

# para finalizar a feature e fazer o merge na develop
git flow feature finish NOME_DA_MINHA_FEATURE

```

### Usando Release

Tudo deve estar commitado. Verifique com **git status**.

```bash

# Usando release - git flow release start [NUmero da Versão da Release]
git flow release start 1.0
git add --all
git commit -m "info sobre o commit"

# Publush se desejar
git flow release publish 1.0

git flow release finish 1.0.1

```

### Usando HotFix

O hotfix é criado a partir da master/main.

```bash

# git flow hotfix start [NOVA TAG INFORMADA]
git flow hotfix start 1.1
git add --all
git commit -m "info sobre o commit"

# Sew desejar compartilhar a hotfix, faz o publish
# com isso, outros desenvolvedores podem baixar
git flow hotfix publish '1.1'

# para finalizar a hotfix e fazer o merge na develop
git flow hotfix finish '1.1'


```

### Publicar todas as branch

```bash

git push --all

```
