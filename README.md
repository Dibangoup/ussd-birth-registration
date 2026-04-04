# 🏥 USSD Birth Registration — Naissance+

Système complet d'enregistrement des naissances via USSD avec dashboard de gestion en temps réel.

> **Backend** : FastAPI (Python) · **Frontend** : React + Vite · **BDD** : SQLite / PostgreSQL

---

## 📋 Fonctionnalités

### Flux USSD (12 étapes)
Le parcours USSD collecte toutes les informations nécessaires à un enregistrement complet :

| Étape | Donnée collectée |
|-------|-----------------|
| 1 | Choix d'action (enregistrer / aide) |
| 2 | Nom de famille de l'enfant |
| 3 | Prénom de l'enfant |
| 4 | Sexe (Masculin / Féminin) |
| 5 | Date de naissance (JJ/MM/AAAA) |
| 6 | Nom du père |
| 7 | Prénom du père |
| 8 | Nom de la mère |
| 9 | Prénom de la mère |
| 10 | Lieu de naissance |
| 11 | Type de lieu (Hôpital / Domicile / Autre) |

### Dashboard Web
- **Tableau de bord** : statistiques en temps réel, graphique des naissances, calendrier
- **Déclarations** : liste complète avec filtres par période, statut, recherche et tri par colonnes
- **Demandes** : validation / rejet des déclarations en attente
- **Parents** : annuaire des parents déclarants
- **Lieux de naissance** : localités avec nombre de naissances
- **Statistiques** : vue d'ensemble filtrée par période

---

## 🚀 Installation

### Prérequis
- Python 3.10+
- Node.js 18+
- (Optionnel) PostgreSQL

### 1. Backend (FastAPI)

```bash
# Cloner le dépôt
git clone https://github.com/votre-repo/ussd-birth-registration.git
cd ussd-birth-registration

# Créer et activer l'environnement virtuel
python -m venv venv
# Windows :
venv\Scripts\activate
# Linux/Mac :
source venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Configurer l'environnement
cp .env.example .env
# Éditer .env avec vos paramètres (DATABASE_URL, FRONTEND_URL)
```

### 2. Frontend (React/Vite)

```bash
cd dashboard
npm install
```

---

## ▶️ Lancement

### Backend
```bash
# Depuis la racine du projet
uvicorn app.main:app --reload --port 8000
```

### Frontend
```bash
# Depuis le dossier dashboard/
cd dashboard
npm run dev
```

- Backend API : http://localhost:8000
- Dashboard : http://localhost:5173
- Documentation API : http://localhost:8000/docs

---

## 🧪 Tester le flux USSD

**Endpoint** : `POST http://localhost:8000/ussd`
**Content-Type** : `application/x-www-form-urlencoded`

### Scénario complet (curl)

```bash
# Étape 0 — Menu principal
curl -X POST http://localhost:8000/ussd \
  -d "sessionId=test1&serviceCode=*123#&phoneNumber=+237600000000&text="

# Étape 1 — Choisir "Enregistrer"
curl -X POST http://localhost:8000/ussd \
  -d "sessionId=test1&serviceCode=*123#&phoneNumber=+237600000000&text=1"

# Flux complet en une seule requête (11 niveaux)
curl -X POST http://localhost:8000/ussd \
  -d "sessionId=test2&serviceCode=*123#&phoneNumber=+237699887766&text=1*Fotso*Jean*1*15/03/2026*Fotso*Pierre*Ngono*Marie*Douala*1"
```

Le format du champ `text` est :
```
action*nom_enfant*prenom_enfant*sexe*date*nom_pere*prenom_pere*nom_mere*prenom_mere*localite*type_lieu
```

Valeurs pour le sexe : `1` = Masculin, `2` = Féminin
Valeurs pour le type de lieu : `1` = Hôpital, `2` = Domicile, `3` = Autre

---

## 📁 Structure du projet

```
ussd-birth-registration/
├── app/
│   ├── main.py              # Point d'entrée FastAPI + logique USSD
│   ├── core/
│   │   └── db.py            # Configuration SQLAlchemy (SQLite/PostgreSQL)
│   ├── models/
│   │   ├── birth.py         # Modèles : PreEnregistrement, Parent, Localite
│   │   └── schemas.py       # Schémas Pydantic
│   ├── routers/
│   │   ├── dashboard.py     # API dashboard (stats, charts, calendar)
│   │   └── pages.py         # API pages (parents, localités, demandes, statistiques)
│   └── services/            # Services métier
├── dashboard/
│   ├── src/
│   │   ├── Pages/           # Pages React (Dashboard, Déclarations, Demandes, etc.)
│   │   └── components/      # Composants réutilisables (Sidebar, Charts, etc.)
│   ├── package.json
│   └── vite.config.js
├── .env.example             # Variables d'environnement (template)
├── requirements.txt         # Dépendances Python
├── requirements-dev.txt     # Dépendances de test (pytest, httpx)
└── README.md
```

---

## 🔌 API Endpoints

### USSD
| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/ussd` | Point d'entrée USSD (Africa's Talking) |

### Dashboard
| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/dashboard/stats?period=Mois` | Statistiques filtrées |
| GET | `/api/dashboard/declarations?period=Mois` | Déclarations avec parents et localités |
| GET | `/api/dashboard/chart?period=Mois` | Données pour le graphique |
| GET | `/api/dashboard/calendar?period=Mois` | Taux de validation |

### Pages
| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/api/parents` | Liste des parents |
| GET | `/api/localites` | Localités avec nb naissances |
| GET | `/api/statistiques?period=Mois` | Statistiques complètes filtrées |
| GET | `/api/demandes?period=Mois&statut=en_attente` | Demandes filtrées |
| PATCH | `/api/demandes/{id}` | Valider/rejeter une demande |

---

## ⚙️ Variables d'environnement

| Variable | Description | Exemple |
|----------|-------------|---------|
| `DATABASE_URL` | URL de connexion BDD | `sqlite:///./ussd_births.db` |
| `FRONTEND_URL` | URLs CORS autorisées | `http://localhost:5173` |

---

## 📄 Licence

Projet académique — Usage éducatif.
