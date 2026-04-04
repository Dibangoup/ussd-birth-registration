from pydantic import BaseModel
from typing import Optional
from datetime import date, time

class PreEnregistrementCreate(BaseModel):
    nom_enfant: str
    prenom_enfant: Optional[str] = None
    sexe: str
    date_naissance: date
    heure_naissance: Optional[time] = None
    telephone_declarant: Optional[str] = None
    parents_id: Optional[int] = None
    localite_id: Optional[int] = None

    class Config:
        from_attributes = True

class PreEnregistrementResponse(BaseModel):
    id: int
    numero_recu: Optional[str] = None
    nom_enfant: str
    prenom_enfant: Optional[str] = None
    sexe: Optional[str] = None
    date_naissance: Optional[date] = None
    statut: Optional[str] = None

    class Config:
        from_attributes = True

class StatutUpdate(BaseModel):
    statut: str