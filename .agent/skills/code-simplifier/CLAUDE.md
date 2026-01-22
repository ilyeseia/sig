# CLAUD – Coding & Architecture Guidelines

Ce fichier définit les conventions et bonnes pratiques à respecter dans l’ensemble du projet, en particulier pour le développement de *skills*.

---

## 1. Modules & Imports

* Utiliser exclusivement **ES Modules** (`import` / `export`).
* Toujours inclure les **extensions de fichiers explicites** (`.ts`, `.tsx`, `.js`).
* Trier les imports de manière cohérente :

  1. Imports standards / externes
  2. Imports internes (par alias puis chemins relatifs)
  3. Imports de styles / assets
* Éviter les imports inutilisés ou implicites.

---

## 2. Fonctions

* **Privilégier le mot-clé `function`** au lieu des fonctions fléchées.
* Réserver les fonctions fléchées aux callbacks simples et inline.
* Les fonctions de haut niveau doivent être clairement nommées et lisibles.

### Typage

* Toutes les **fonctions de haut niveau** doivent avoir une **annotation de type de retour explicite**.
* Éviter `any` ; préférer des types explicites ou génériques.

Exemple recommandé :

```ts
export function buildSkillConfig(): SkillConfig {
  return { /* ... */ };
}
```

---

## 3. React & Composants

* Utiliser des **composants fonctionnels** uniquement.
* Définir un type `Props` explicite pour chaque composant.
* Le type `Props` doit être nommé et exportable si réutilisé.

```ts
type SkillCardProps = {
  title: string;
  isActive: boolean;
};

export function SkillCard(props: SkillCardProps): JSX.Element {
  return <div>{props.title}</div>;
}
```

* Éviter les composants anonymes exportés par défaut.
* Un composant = une responsabilité claire.

---

## 4. Gestion des erreurs

* **Éviter `try/catch` lorsque ce n’est pas nécessaire**.

* Préférer :

  * la validation en amont des données
  * les types discriminants (`Result`, `Either`, unions)
  * les fonctions qui retournent explicitement un état d’erreur

* Utiliser `throw` uniquement pour les erreurs réellement exceptionnelles.

* Les erreurs doivent être :

  * typées
  * explicites
  * traçables

---

## 5. Nommage & Conventions

* Utiliser une **convention de nommage cohérente** dans tout le projet.

### Général

* `camelCase` : variables, fonctions, hooks
* `PascalCase` : composants React, types, interfaces
* `SCREAMING_SNAKE_CASE` : constantes globales

### Skills

* Les noms liés aux skills doivent être :

  * explicites
  * orientés métier
  * stables dans le temps

Exemples :

* `buildSkillContext`
* `SkillExecutionResult`
* `resolveSkillInput`

---

## 6. Lisibilité & Maintenance

* Préférer du code explicite plutôt que "malin".
* Limiter la profondeur d’imbrication.
* Une fonction ne doit faire **qu’une seule chose**.
* Documenter les parties non évidentes par des commentaires courts et utiles.

---

## 7. Cycle de vie d’un Skill

Chaque *skill* doit suivre un cycle clair et prévisible.

### 1. Input

* Les entrées doivent être validées dès la frontière du skill.
* Utiliser des types explicites (`SkillInput`, `SkillOptions`).
* Aucune logique métier ne doit exister avant la validation complète.

```ts
export type SkillInput = {
  userId: string;
  payload: unknown;
};
```

---

### 2. Validation

* La validation doit être :

  * déterministe
  * pure (sans effets de bord)
* Retourner un résultat typé plutôt que lever une exception.

```ts
export function validateSkillInput(input: SkillInput): ValidationResult {
  return { isValid: true };
}
```

---

### 3. Execution

* L’exécution contient la logique métier principale.
* Une fonction d’exécution = un skill.
* Aucun accès direct à des données non validées.

```ts
export function executeSkill(input: ValidatedSkillInput): SkillExecutionResult {
  return { status: "success" };
}
```

---

### 4. Output

* La sortie doit être :

  * typée
  * stable
  * indépendante du format de transport (API, UI, logs)

```ts
export type SkillExecutionResult = {
  status: "success" | "error";
  message?: string;
};
```

---

## 8. Objectif

Ces règles existent pour garantir :

* une base de code prévisible
* une lecture rapide
* une maintenance facilitée
* une cohérence forte entre les skills

Toute exception doit être justifiée et rare.
