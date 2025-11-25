# EXERCICE D'IMPLÉMENTATION N°2 - MÉTAHEURISTIQUES

Cet exercice d’implémentation s’inscrit dans la continuité de vos productions du EI1. Il conduit à
l’élaboration d’un solveur reposant sur la métaheuristique GRASP pour le Set Packing Problem
(SPP).

---

# Métaheuristiques GRASP et ReactiveGRASP pour le SPP

Ce projet constitue le Livrable de l'Exercice d'Implémentation 2 (EI2) et étend le travail du projet précédent 
sur le Set Packing Problem (SPP). L'objectif est d'implémenter et d'évaluer deux métaheuristiques puissantes, 
**GRASP** et **ReactiveGRASP**, pour améliorer la qualité des solutions obtenues pour le SPP.

## 1. Métaheuristiques Implémentées

### 1.1. GRASP (Greedy Randomized Adaptive Search Procedure)

GRASP est une métaheuristique itérative qui combine une **phase de construction aléatoire** et une **phase de recherche locale**.

* **Construction Aléatoire (`src/graspSPP.jl`) :** Une solution admissible est générée en utilisant une approche gloutonne adaptative.
* **Recherche Locale:** La solution initiale est améliorée par une recherche locale, en utilisant l'heuristique **k-p exchange** (ici un 1-1 exchange par défaut).
* **Objectif:** Répéter le processus plusieurs fois (runs) et conserver la meilleure solution globale trouvée.

### 1.2. ReactiveGRASP

ReactiveGRASP est une extension de GRASP où le paramètre de randomisation **$\alpha$ est appris dynamiquement** au cours de l'exécution.

* **Principe d'Adaptation:** L'algorithme définit $m$ valeurs d' $\alpha$ et attribue à chacune une probabilité de sélection $P_k$.
* **Objectif:** Favoriser les valeurs d' $\alpha$ qui conduisent le plus souvent à des solutions de haute qualité.

## 2. Prérequis et Exécution

### 2.1 Prérequis

Le projet est développé en **JULIA**. Les packages requis sont :

* `JuMP`, `GLPK` (pour les dépendances du `kpexchange` si le solveur MIP est sollicité).
* `Combinatorics` (pour le k-p exchange).
* `Plots` (pour la visualisation des résultats).
* `Statistics` (pour le calcul des moyennes dans ReactiveGRASP).

Assurez-vous que ces packages sont installés dans votre environnement Julia.

### 2.2 Exécution

Pour exécuter les expérimentations (GRASP et ReactiveGRASP) sur toutes les instances `.dat` du dossier `dat/`, 
exécutez le script principal :

```bash
julia>  include("livrableEI1.jl")
julia>  experimentationSPP()
```
