from fastapi import FastAPI, Form, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from sqlalchemy.orm import Session
from datetime import datetime
import uuid
import os

from app.routers import dashboard, pages
from app.core.db import get_db
from app.models.birth import PreEnregistrement, Parent, Localite

app = FastAPI(title="Système USSD d'Enregistrement des Naissances")

# Sécurisation des CORS par variable d'environnement
frontend_urls = os.getenv("FRONTEND_URL", "http://localhost:5173,http://127.0.0.1:5173").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=frontend_urls,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Sécurisation globale : Headers HTTP de protection
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    return response

app.include_router(dashboard.router, prefix="/api/dashboard", tags=["Dashboard"])
app.include_router(pages.router, prefix="/api", tags=["Pages"])

# Messages en français
MESSAGES = {
    "welcome": "CON Bienvenue sur le service d'état civil.\n1. Enregistrer une naissance\n2. Aide",
    "ask_name": "CON Entrez le NOM complet de l'enfant :",
    "ask_sexe": "CON Entrez le sexe de l'enfant (M ou F) :",
    "ask_date": "CON Entrez la date de naissance (JJ/MM/AAAA) :",
    "confusion": "END Option invalide.",
    "confirmation": "END Merci. L'enregistrement est terminé. Votre numéro de suivi vous sera envoyé par SMS."
}

@app.post("/ussd")
async def ussd_handler(
    sessionId: str = Form(default="", max_length=150),
    serviceCode: str = Form(default="", max_length=50),
    phoneNumber: str = Form(default="", max_length=20),
    text: str = Form(default="", max_length=500), # Limitation stricte pour empêcher le buffer overload
    db: Session = Depends(get_db)
):
    """
    Point d'entrée principal pour la passerelle Africa's Talking.
    Reçoit les entrées USSD, gère l'état et enregistre dans PostgreSQL.
    """
    text = text.strip()
    parts = text.split('*') if text != "" else []
    level = len(parts)
    response = ""

    # ÉTAPE 0 : Menu Principal
    if level == 0:
        response = MESSAGES["welcome"]

    # ÉTAPE 1 : Saisie du Nom
    elif level == 1:
        action = parts[0]
        if action == "1":
            response = MESSAGES["ask_name"]
        else:
            # Aide ou retour
            response = MESSAGES["confusion"]

    # ÉTAPE 2 : Saisie du Sexe
    elif level == 2:
        response = MESSAGES["ask_sexe"]

    # ÉTAPE 3 : Saisie de la Date de Naissance
    elif level == 3:
        response = MESSAGES["ask_date"]

    # ÉTAPE 4 FINALE : Validation & Notification
    elif level == 4:
        action = parts[0]
        if action != "1":
            return MESSAGES["confusion"]
            
        nom_enfant = parts[1]
        sexe = parts[2].strip().upper()
        date_str = parts[3].strip()
        
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
        response = MESSAGES["confirmation"]

    return response