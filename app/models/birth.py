from sqlalchemy import Column, Integer, String, DateTime
from datetime import datetime
from app.core.db import Base #Maxime gère la config DB ici

class BirthRegistration(Base):
    __tablename__ = "birth_registrations"

    id = Column(Integer, primary_key=True, index=True)
    
    # Le numéro de référence unique (ex: CI-2603-K9P2)
    reference_id = Column(String, unique=True, index=True, nullable=False)
    
    # Informations de l'enfant
    full_name = Column(String, nullable=False)
    birth_date = Column(String) # Format JJ/MM/AAAA reçu par USSD
    
    # Métadonnées pour le suivi
    parent_phone = Column(String, nullable=False)
    language = Column(String, default="fr") # "1" pour FR, "2" pour local
    created_at = Column(DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<BirthRegistration(reference={self.reference_id}, name={self.full_name})>"