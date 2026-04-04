from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from app.core.db import get_db
from app.models.birth import PreEnregistrement, Parent, Localite

router = APIRouter()

def get_threshold_date(period: str) -> datetime:
    now = datetime.utcnow()
    if period == "Jour":
        return now - timedelta(days=1)
    elif period == "Semaine":
        return now - timedelta(days=7)
    elif period == "Année":
        return now - timedelta(days=365)
    return now - timedelta(days=30)

@router.get("/parents")
def get_all_parents(db: Session = Depends(get_db)):
    parents = db.query(Parent).all()
    return [
        {
            "id": p.id,
            "nom_pere": p.nom_pere,
            "prenom_pere": p.prenom_pere,
            "telephone_pere": p.telephone_pere,
            "nom_mere": p.nom_mere,
            "prenom_mere": p.prenom_mere,
            "telephone_mere": p.telephone_mere
        }
        for p in parents
    ]

@router.get("/localites")
def get_all_localites(db: Session = Depends(get_db)):
    localites = db.query(
        Localite,
        func.count(PreEnregistrement.id).label("nb_naissances")
    ).outerjoin(
        PreEnregistrement, PreEnregistrement.localite_id == Localite.id
    ).group_by(Localite.id).all()

    return [
        {
            "id": loc.id,
            "nom": loc.nom,
            "type": loc.type,
            "nb_naissances": nb
        }
        for loc, nb in localites
    ]

@router.get("/statistiques")
def get_full_stats(
    period: str = Query("Tout", description="Période : Jour, Semaine, Mois, Année, Tout"),
    db: Session = Depends(get_db)
):
    # Construction de la requête de base selon la période
    if period == "Tout":
        base = db.query(PreEnregistrement)
    else:
        threshold = get_threshold_date(period)
        base = db.query(PreEnregistrement).filter(PreEnregistrement.created_at >= threshold)

    total = base.count()
    valides = base.filter(PreEnregistrement.statut == "valide").count()
    rejetees = base.filter(PreEnregistrement.statut == "rejete").count()
    en_attente = base.filter(PreEnregistrement.statut == "en_attente").count()
    garcons = base.filter(PreEnregistrement.sexe == "M").count()
    filles = base.filter(PreEnregistrement.sexe == "F").count()

    # Localités et parents sont des totaux absolus (pas filtrés par période)
    localites = db.query(Localite).count()
    parents_count = db.query(Parent).count()

    return {
        "total": total,
        "valides": valides,
        "rejetees": rejetees,
        "en_attente": en_attente,
        "garcons": garcons,
        "filles": filles,
        "localites": localites,
        "parents": parents_count
    }

@router.get("/demandes")
def get_demandes(
    period: str = Query("Tout", description="Période : Jour, Semaine, Mois, Année, Tout"),
    statut: str = Query("Tous", description="Statut : Tous, en_attente, valide, rejete"),
    db: Session = Depends(get_db)
):
    # Requête de base
    base = db.query(PreEnregistrement)

    # Filtre par période
    if period != "Tout":
        threshold = get_threshold_date(period)
        base = base.filter(PreEnregistrement.created_at >= threshold)

    # Filtre par statut
    if statut != "Tous":
        base = base.filter(PreEnregistrement.statut == statut)

    records = base.order_by(PreEnregistrement.created_at.desc()).all()

    statut_map = {
        "en_attente": "En attente",
        "valide": "Enregistrée",
        "rejete": "Rejetée"
    }

    return [
        {
            "id": r.id,
            "enfant": f"{r.nom_enfant or ''} {r.prenom_enfant or ''}".strip(),
            "sexe": r.sexe,
            "date": r.date_naissance.strftime("%d/%m/%Y") if r.date_naissance else "Inconnue",
            "telephone": r.telephone_declarant or "—",
            "statut": statut_map.get(r.statut, "Inconnu")
        }
        for r in records
    ]

@router.patch("/demandes/{demande_id}")
def update_demande_statut(demande_id: int, body: dict, db: Session = Depends(get_db)):
    record = db.query(PreEnregistrement).filter(PreEnregistrement.id == demande_id).first()
    if not record:
        return {"error": "Déclaration introuvable"}
    
    record.statut = body.get("statut", record.statut)
    db.commit()
    return {"success": True, "id": record.id, "statut": record.statut}
