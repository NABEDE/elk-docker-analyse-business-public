## 🚀 Le stack ELK au service du data engineering 💻 dans le secteur commercial des ordinateurs portables

### Plan
- [Introduction](#introduction)
- [Prérequis](#prérequis)
- [Fonctionnalité](#fonctionnalité)
- [Installation](#Installation)
- [Utilisation](#utilisation)
- [Conclusion](#conclusion)

### ✨ Introduction
Dans le cadre de notre projet de data engineering appliqué au secteur commercial des ordinateurs portables 💻🛍️, nous avons mis en place *un stack ELK* (Elasticsearch, Logstash, Kibana) 🔍📊. Cette architecture permet de structurer l’ensemble du pipeline de traitement des données, depuis *leur génération ou collecte* jusqu’à leur visualisation interactive sur Kibana.

Les données sont générées à partir du *langage Python 🐍* puis stockées dans *un fichier CSV 📄*. Ce fichier est ensuite *ingéré et transformé via Logstash*, avant d’être envoyé vers *Elasticsearch* pour l’indexation et l’analyse. Enfin, les résultats sont visualisés sur *Kibana*, offrant une interface claire et puissante pour explorer *les insights commerciaux*.

### 🛠️ Prérequis techniques
Avant de procéder à la mise en œuvre du stack ELK dans un contexte de data engineering, il est essentiel de disposer des compétences et outils suivants :

- *🖥️ Maîtrise du terminal* : Une familiarité avec l’utilisation du terminal Linux (bash) ou du CMD sous Windows est requise pour exécuter les commandes et scripts nécessaires à l’orchestration des services.
- 🐍 Environnement Python : Il est recommandé d’avoir des connaissances de base en Python, ou à minima de disposer d’une installation fonctionnelle de Python sur votre machine ou dans votre environnement de travail.
- *🐳 Infrastructure Docker* : La présence de `Docker`, ainsi que de `Docker Compose` (`docker-compose` ou `docker compose` selon la version), est indispensable pour le déploiement et la gestion des services `Elasticsearch`, `Logstash` et `Kibana` dans des conteneurs isolés.
- *💻 Shell Bash* : Assurez-vous que `bash` est installé sur votre système, notamment pour l’exécution de scripts d’automatisation et de maintenance.
- *📦 Services ELK via Docker* : Les composants du *stack ELK — Elasticsearch*, *Kibana* et *Logstash* — doivent être disponibles sur votre machine, idéalement déployés via `Docker` pour garantir `portabilité`, `reproductibilité` et `isolation des environnements`.


### ⚙️ Fonctionnalités principales du projet
- 📄 *Génération des données* : Création *d’un fichier CSV* contenant les données simulées ou réelles, placé dans le répertoire /data du projet pour être utilisé *dans le pipeline*.
- 🐳 *Configuration de l’environnement ELK* : Mise en place des éléments de configuration via `Docker` et `Docker Compose`, incluant la création des volumes, des réseaux, et des services nécessaires au bon fonctionnement du *stack ELK*.
- 🔄 *Ingestion des données* :
    Importation du fichier *CSV dans Elasticsearch* à l’aide de *Logstash*, selon les configurations définies dans le pipeline.
    Possibilité d’envoyer des données au *format JSON* directement vers *Elasticsearch*, soit via le script *setup-bi.sh*, soit via *Logstash* selon le scénario choisi.
- 📊 *Visualisation sur Kibana* : Exploration et analyse des *données ingérées* à travers des tableaux de bord interactifs sur *Kibana*, permettant une lecture claire des tendances et indicateurs commerciaux.

### 🚀 Installation du projet

## 📥 Cloner le dépôt Git
 `git clone https://github.com/NABEDE/elk-docker-analyse-business.git`

## 📂 Se placer dans le dossier du projet
`cd elk-docker-analyse-business`

## 🐳 Lancer l’environnement Docker :
- Lancer le `docker-compose.yml` avec `docker-compose up -d` afin de créer l'environnement de travail et les volumes rattachés.

## 🔍 Vérifier le bon démarrage d’Elasticsearch
- Vérifier que Elasticsearch est bien lancé en tapant cette commande : `curl -X GET http://localhost:9200/`, s'il n'y a aucune erreur qui apparaît, alors votre Elasticsearch est bien lancé.

## 📄 Vérifier le bon fonctionnement de Logstash
- Vérifier aussi que votre Logstash est bien lancer en saisissant cette commande : `docker logs logstash`, s'il n'y a aucune erreur qui apparaît, alors votre Logstash est bien lancé.

## 📦 Importer les données dans Elasticsearch
- Lancer le script `setup-bi.sh` avec `bash setup-bi.sh` pour importer les données dans Elasticsearch.

## 📊 Vérifier le bon fonctionnement de Kibana
- Accéder à Kibana en tapant cette commande : `http://localhost:5601/`, s'il n'y a aucune erreur qui apparaît, alors votre Kibana est bien lancé.

## 🎯 Lancer la boule d'exécution pour le démaraage du stack
- Cas exceptionnel, s'il y'a des coupures de session de votre environnement ELK utiliser cette commande avec ce setup, c'est comme une boule que vous lancez : `bash boule.sh`. Vous verez en temps réel le fonctionnement de vos containers et leur lancement, leur coupure ainsi de suite.

### 📝 Conclusion

L'environnement **ELK** 🧠 est conçu pour l'ingénierie des données 📊. Dans le cadre de ce projet spécifique, il permet d'automatiser l'envoi 🚀, la création 🛠️ ou la collecte des données 📥, puis leur filtrage 🧹 avant de les intégrer dans **Elasticsearch** 🔍.

L'utilisation de `setup` ⚙️ ne remplace ni ne supprime celle de `docker-compose` ou `docker compose` 🐳. Elle vise simplement à optimiser l'automatisation du transit 🚚 et du traitement des données 🔄.

