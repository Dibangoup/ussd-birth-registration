from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
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
    # Défaut : "Mois" (30 jours)
    return now - timedelta(days=30)

@router.get("/stats")
def get_dashboard_stats(period: str = "Mois", db: Session = Depends(get_db)):
    threshold = get_threshold_date(period)
    base = db.query(PreEnregistrement).filter(PreEnregistrement.created_at >= threshold)
    
    total_recues = base.count()
    total_valide = base.filter(PreEnregistrement.statut == "valide").count()
    total_rejete = base.filter(PreEnregistrement.statut == "rejete").count()
    total_attente = base.filter(PreEnregistrement.statut == "en_attente").count()

    return {
        "valides": total_valide,
        "recues": total_recues,
        "rejetees": total_rejete,
        "en_attente": total_attente
    }

@router.get("/declarations")
def get_dashboard_declarations(period: str = "Mois", db: Session = Depends(get_db)):
    threshold = get_threshold_date(period)
    
    declarations = (
        db.query(PreEnregistrement, Parent, Localite)
        .outerjoin(Parent, PreEnregistrement.parents_id == Parent.id)
        .outerjoin(Localite, PreEnregistrement.localite_id == Localite.id)
        .filter(PreEnregistrement.created_at >= threshold)
        .order_by(PreEnregistrement.created_at.desc())
        .limit(50)
        .all()
    )
    
    result = []
    statut_map = {
        "en_attente": "En attente",
        "valide": "Enregistrée",
        "rejete": "Rejetée"
    }
    
    for enr, par, loc in declarations:
        nom_pere = f"{par.nom_pere or ''} {par.prenom_pere or ''}".strip() if par else "Inconnu"
        nom_mere = f"{par.nom_mere or ''} {par.prenom_mere or ''}".strip() if par else "Inconnue"
        
        result.append({
            "id": enr.id,
            "localite": loc.nom if loc else "Inconnue",
            "pere": nom_pere,
            "mere": nom_mere,
            "heure": enr.heure_naissance.strftime("%Hh%Mmin") if enr.heure_naissance else "00h00min",
            "date": enr.date_naissance.strftime("%d/%m/%Y") if enr.date_naissance else "Inconnue",
            "enfant": f"{enr.nom_enfant or ''} {enr.prenom_enfant or ''}".strip(),
            "sexe": enr.sexe,
            "statut": statut_map.get(enr.statut, "Inconnu")
        })
        
    return result

@router.get("/chart")
def get_dashboard_chart(period: str = "Mois", db: Session = Depends(get_db)):
    threshold = get_threshold_date(period)
    records = db.query(PreEnregistrement).filter(PreEnregistrement.created_at >= threshold).all()
    
    # Agrégation simple en Python pour la compatibilité
    counts_by_date = {}
    for r in records:
        fmt = "%Y-%m-%d"
        if period == "Jour":
            fmt = "%H:00" # Par heure
        elif period == "Année":
            fmt = "%Y-%m" # Par mois
            
        key = r.created_at.strftime(fmt) if r.created_at else "Inconnu"
        counts_by_date[key] = counts_by_date.get(key, 0) + 1

    # Trier les clés
    sorted_keys = sorted(counts_by_date.keys())
    
    # Mapper vers le format Recharts attendu: [{jour: "...", naissances: int, label: "..."}]
    data = []
    for k in sorted_keys:
        data.append({
            "jour": k,
            "naissances": counts_by_date[k],
            "label": str(counts_by_date[k])
        })
        
    # Si base de données vide ou pas assez de data, on pré-remplit pour ne pas casser le design
    if not data:
        data = [
            {"jour": "Lun", "naissances": 0, "label": "0"},
            {"jour": "Mar", "naissances": 0, "label": "0"},
            {"jour": "Mer", "naissances": 0, "label": "0"}
        ]
        
    return data

@router.get("/calendar")
def get_dashboard_calendar(period: str = "Mois", db: Session = Depends(get_db)):
    threshold = get_threshold_date(period)
    total = db.query(PreEnregistrement).filter(PreEnregistrement.created_at >= threshold).count()
    valides = db.query(PreEnregistrement).filter(
        PreEnregistrement.created_at >= threshold, 
        PreEnregistrement.statut == "valide"
    ).count()
    
    rate = (valides / total * 100) if total > 0 else 0
    
    return {
        "validation_rate": round(rate, 1),
        "total": total
    }
