from fastapi import FastAPI, Form, Depends
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from app.routers import dashboard, pages
from app.core.db import get_db
from app.models.birth import PreEnregistrement, Parent, Localite

app = FastAPI(title="Système USSD d'Enregistrement des Naissances")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://localhost:5174", "http://127.0.0.1:5173", "http://127.0.0.1:5174"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(dashboard.router, prefix="/api/dashboard", tags=["Dashboard"])
app.include_router(pages.router, prefix="/api", tags=["Pages"])

# 1. Dictionnaire de traduction (À affiner avec Désiré) [cite: 32, 85]
TRADUCTIONS = {
    "1": {  # Français
        "welcome": "CON Bienvenue sur le service d'état civil.\n1. Enregistrer une naissance\n2. Aide",
        "ask_name": "CON Entrez le NOM complet de l'enfant :",
        "ask_sexe": "CON Entrez le sexe de l'enfant (M ou F) :",
        "ask_date": "CON Entrez la date de naissance (JJ/MM/AAAA) :",
        "confusion": "END Option invalide.",
        "confirmation": "END Merci. L'enregistrement est terminé. Votre numéro de suivi vous sera envoyé par SMS."
    },
    "2": {  # Langue Locale (Exemple)
        "welcome": "CON I ni ce. Sélikɛnɛ dɔnniyoro.\n1. Wolon fɛn dɔn\n2. Dɛmɛ",
        "ask_name": "CON Den tɔgɔ bɛn :",
        "ask_sexe": "CON Cɛ don walima muso don (M/F) :",
        "ask_date": "CON A wolo don (JJ/MM/AAAA) :",
        "confusion": "END I filila.",
        "confirmation": "END I ni ce. An bɛna SMS ci i ma ni reference ye."
    }
}

@app.post("/ussd")
async def ussd_handler(
    sessionId: str = Form(...),
    serviceCode: str = Form(...),
    phoneNumber: str = Form(...),
    text: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    Point d'entrée principal pour la passerelle Africa's Talking.
    Reçoit les entrées USSD, gère l'état et enregistre dans PostgreSQL.
    """
    parts = text.split('*') if text != "" else []
    level = len(parts)
    response = ""

    # ÉTAPE 0 : Choix de la langue
    if level == 0:
        response = "CON Choisissez votre langue / Choice language:\n1. Français\n2. Langue Locale"

    # ÉTAPE 1 : Menu Principal
    elif level == 1:
        lang = parts[0]
        if lang in TRADUCTIONS:
            response = TRADUCTIONS[lang]["welcome"]
        else:
            response = "END Option invalide / Invalid option."

    # ÉTAPE 2 : Saisie du Nom
    elif level == 2:
        lang = parts[0]
        action = parts[1]
        if action == "1":
            response = TRADUCTIONS[lang]["ask_name"]
        else:
            # Aide ou retour
            response = TRADUCTIONS[lang]["confusion"]

    # ÉTAPE 3 : Saisie du Sexe
    elif level == 3:
        lang = parts[0]
        response = TRADUCTIONS[lang]["ask_sexe"]

    # ÉTAPE 4 : Saisie de la Date de Naissance
    elif level == 4:
        lang = parts[0]
        response = TRADUCTIONS[lang]["ask_date"]

    # ÉTAPE 5 FINALE : Validation & Notification
    elif level == 5:
        lang = parts[0]
        nom_enfant = parts[2]
        sexe = parts[3].strip().upper()
        date_str = parts[4].strip()
        
        # Génération d'une référence unique (ex: REC-2026-A1B2C3)
        reference = f"REC-2026-{str(uuid.uuid4())[:6].upper()}"
        
        # Parsing basique de la date pour PostgreSQL
        try:
            date_naissance = datetime.strptime(date_str, "%d/%m/%Y").date()
        except ValueError:
            date_naissance = datetime.utcnow().date() # Fallback si le formattage échoue
            
        # Création et Sauvegarde de l'enregistrement en Base
        nouvel_enregistrement = PreEnregistrement(
            numero_recu=reference,
            nom_enfant=nom_enfant,
            sexe='M' if sexe.startswith('M') else 'F',
            date_naissance=date_naissance,
            heure_naissance=datetime.utcnow().time(),
            telephone_declarant=phoneNumber,
            statut="en_attente"
        )
        
        # Insertion dans la base de données !
        db.add(nouvel_enregistrement)
        db.commit()
        db.refresh(nouvel_enregistrement)
        
        # TODO: Appel au module de SMS
        response = TRADUCTIONS[lang]["confirmation"]

    return response