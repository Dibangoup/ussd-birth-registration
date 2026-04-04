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

# Messages en français — synchronisés avec le dashboard
MESSAGES = {
    "welcome": "CON Bienvenue sur le service d'état civil.\n1. Enregistrer une naissance\n2. Aide",
    "ask_nom": "CON Entrez le NOM de famille de l'enfant :",
    "ask_prenom": "CON Entrez le PRENOM de l'enfant :",
    "ask_sexe": "CON Sexe de l'enfant :\n1. Masculin\n2. Feminin",
    "ask_date": "CON Date de naissance (JJ/MM/AAAA) :",
    "ask_nom_pere": "CON Entrez le NOM du pere :",
    "ask_prenom_pere": "CON Entrez le PRENOM du pere :",
    "ask_nom_mere": "CON Entrez le NOM de la mere :",
    "ask_prenom_mere": "CON Entrez le PRENOM de la mere :",
    "ask_localite": "CON Nom du lieu de naissance :",
    "ask_type_lieu": "CON Type de lieu :\n1. Hopital\n2. Domicile\n3. Autre",
    "confusion": "END Option invalide.",
    "confirmation": "END Merci ! Enregistrement termine.\nVotre numero de suivi vous sera envoye par SMS."
}

# Mapping du type de lieu (choix numérique → libellé)
TYPE_LIEU_MAP = {
    "1": "Hôpital",
    "2": "Domicile",
    "3": "Autre"
}

@app.post("/ussd")
async def ussd_handler(
    sessionId: str = Form(default="", max_length=150),
    serviceCode: str = Form(default="", max_length=50),
    phoneNumber: str = Form(default="", max_length=20),
    text: str = Form(default="", max_length=500),
    db: Session = Depends(get_db)
):
    """
    Point d'entrée principal pour la passerelle Africa's Talking.
    Flux complet en 12 niveaux pour collecter toutes les informations
    nécessaires au dashboard (enfant, parents, localité).
    """
    text = text.strip()
    parts = text.split('*') if text != "" else []
    level = len(parts)
    response = ""

    # ── LEVEL 0 : Menu Principal ──
    if level == 0:
        response = MESSAGES["welcome"]

    # ── LEVEL 1 : Choix d'action → demande nom enfant ──
    elif level == 1:
        if parts[0] == "1":
            response = MESSAGES["ask_nom"]
        else:
            response = MESSAGES["confusion"]

    # ── LEVEL 2 : Nom enfant saisi → demande prénom enfant ──
    elif level == 2:
        response = MESSAGES["ask_prenom"]

    # ── LEVEL 3 : Prénom enfant saisi → demande sexe ──
    elif level == 3:
        response = MESSAGES["ask_sexe"]

    # ── LEVEL 4 : Sexe saisi → demande date de naissance ──
    elif level == 4:
        choix_sexe = parts[3].strip()
        if choix_sexe not in ("1", "2"):
            response = MESSAGES["confusion"]
        else:
            response = MESSAGES["ask_date"]

    # ── LEVEL 5 : Date saisie → demande nom du père ──
    elif level == 5:
        response = MESSAGES["ask_nom_pere"]

    # ── LEVEL 6 : Nom père saisi → demande prénom du père ──
    elif level == 6:
        response = MESSAGES["ask_prenom_pere"]

    # ── LEVEL 7 : Prénom père saisi → demande nom de la mère ──
    elif level == 7:
        response = MESSAGES["ask_nom_mere"]

    # ── LEVEL 8 : Nom mère saisi → demande prénom de la mère ──
    elif level == 8:
        response = MESSAGES["ask_prenom_mere"]

    # ── LEVEL 9 : Prénom mère saisie → demande localité ──
    elif level == 9:
        response = MESSAGES["ask_localite"]

    # ── LEVEL 10 : Localité saisie → demande type de lieu ──
    elif level == 10:
        response = MESSAGES["ask_type_lieu"]

    # ── LEVEL 11 : FINAL — Enregistrement complet en BDD ──
    elif level == 11:
        # Vérifier que le premier choix était bien "1"
        if parts[0] != "1":
            return MESSAGES["confusion"]

        # ── Extraction des champs ──
        nom_enfant     = parts[1].strip()
        prenom_enfant  = parts[2].strip()
        choix_sexe     = parts[3].strip()
        date_str       = parts[4].strip()
        nom_pere       = parts[5].strip()
        prenom_pere    = parts[6].strip()
        nom_mere       = parts[7].strip()
        prenom_mere    = parts[8].strip()
        nom_localite   = parts[9].strip()
        choix_type     = parts[10].strip()

        # ── Sexe ──
        sexe = "M" if choix_sexe == "1" else "F"

        # ── Date de naissance ──
        try:
            date_naissance = datetime.strptime(date_str, "%d/%m/%Y").date()
        except ValueError:
            date_naissance = datetime.utcnow().date()

        # ── Type de lieu ──
        type_lieu = TYPE_LIEU_MAP.get(choix_type, "Autre")

        # ── Référence unique (ex: REC-2026-A1B2C3) ──
        reference = f"REC-{datetime.utcnow().year}-{str(uuid.uuid4())[:6].upper()}"

        # ── 1) Créer le Parent ──
        nouveau_parent = Parent(
            nom_pere=nom_pere,
            prenom_pere=prenom_pere,
            telephone_pere=phoneNumber,
            nom_mere=nom_mere,
            prenom_mere=prenom_mere,
            telephone_mere=""
        )
        db.add(nouveau_parent)
        db.flush()  # Pour obtenir l'ID avant le commit

        # ── 2) Chercher ou créer la Localité ──
        localite = db.query(Localite).filter(
            Localite.nom == nom_localite,
            Localite.type == type_lieu
        ).first()

        if not localite:
            localite = Localite(nom=nom_localite, type=type_lieu)
            db.add(localite)
            db.flush()

        # ── 3) Créer le Pré-Enregistrement avec les FK ──
        nouvel_enregistrement = PreEnregistrement(
            numero_recu=reference,
            nom_enfant=nom_enfant,
            prenom_enfant=prenom_enfant,
            sexe=sexe,
            date_naissance=date_naissance,
            heure_naissance=datetime.utcnow().time(),
            telephone_declarant=phoneNumber,
            parents_id=nouveau_parent.id,
            localite_id=localite.id,
            statut="en_attente"
        )
        db.add(nouvel_enregistrement)
        db.commit()
        db.refresh(nouvel_enregistrement)

        response = MESSAGES["confirmation"]

    return response