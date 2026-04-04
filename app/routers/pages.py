from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.db import get_db
from app.models.birth import PreEnregistrement, Parent, Localite

router = APIRouter()

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
def get_full_stats(db: Session = Depends(get_db)):
    total = db.query(PreEnregistrement).count()
    valides = db.query(PreEnregistrement).filter(PreEnregistrement.statut == "valide").count()
    rejetees = db.query(PreEnregistrement).filter(PreEnregistrement.statut == "rejete").count()
    en_attente = db.query(PreEnregistrement).filter(PreEnregistrement.statut == "en_attente").count()
    garcons = db.query(PreEnregistrement).filter(PreEnregistrement.sexe == "M").count()
    filles = db.query(PreEnregistrement).filter(PreEnregistrement.sexe == "F").count()
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
def get_demandes(db: Session = Depends(get_db)):
    records = db.query(PreEnregistrement).order_by(PreEnregistrement.created_at.desc()).all()
    
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
