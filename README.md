# USSD Birth Registration

Application backend (FastAPI) + frontend (React/Vite) pour enregistrement de naissance via USSD.

## Installation

1. Créez et activez un virtualenv (python3 >= 3.12 recommandé)

```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Installez les dépendances Python

```bash
pip install -r requirements.txt
```

Si `psycopg2-binary` échoue :

```bash
sudo apt update && sudo apt install -y libpq-dev
pip install -r requirements.txt
```

3. Installez les dépendances frontend

```bash
npm install
```

## Lancement

- Backend :

```bash
python -m uvicorn main:app --reload
```

- Frontend :

```bash
npm run dev
```

## API USSD à tester (Postman)

Endpoint : `POST http://127.0.0.1:8000/ussd`
Headers : `Content-Type: multipart/form-data` (form-data en Postman)

Paramètres `form-data` :

- `sessionId` (string)
- `serviceCode` (string)
- `phoneNumber` (string)
- `text` (string)

### Scénario de test

1. `text` vide -> doit renvoyer
   `CON Choisissez votre langue / Choice language:\n1. Français\n2. Langue Locale`

2. `text = 1` -> doit renvoyer (Français)
   `CON Bienvenue sur le service d'état civil...`

3. `text = 1*1` -> doit renvoyer
   `CON Entrez le NOM complet de l'enfant :`

4. `text = 1*1*Jean Dupont` -> doit renvoyer
   `END Merci. L'enregistrement est en cours...`

5. test invalides : `text = 3` -> `END Option invalide / Invalid option.`

## Exemples curl

(utile si tu veux tester via terminal sans Postman)

- Étape 1 (langue) :

```bash
curl -X POST http://127.0.0.1:8000/ussd \
  -F "sessionId=123" \
  -F "serviceCode=*123#" \
  -F "phoneNumber=+22501234567" \
  -F "text="
```

- Étape 2 (Français) :

```bash
curl -X POST http://127.0.0.1:8000/ussd \
  -F "sessionId=123" \
  -F "serviceCode=*123#" \
  -F "phoneNumber=+22501234567" \
  -F "text=1"
```

- Étape 3 (choix 1) :

```bash
curl -X POST http://127.0.0.1:8000/ussd \
  -F "sessionId=123" \
  -F "serviceCode=*123#" \
  -F "phoneNumber=+22501234567" \
  -F "text=1*1"
```

- Étape 4 (nom enfant) :

```bash
curl -X POST http://127.0.0.1:8000/ussd \
  -F "sessionId=123" \
  -F "serviceCode=*123#" \
  -F "phoneNumber=+22501234567" \
  -F "text=1*1*Jean Dupont"
```

## Structure du code

- `main.py` : point d'entrée FastAPI + logique USSD
- `app/api/` : futurs endpoints API (actuellement vide)
- `envoie_message/` : module d'envoi SMS (exemple)
- `src/` : interface React/Vite
- `database/database_dump.sql` : dump SQL

## Notes

L'API renvoie du texte en `PlainTextResponse` avec protocole USSD :

- `CON` (continuer la session)
- `END` (terminer la session).
