from sqlalchemy import Column, Integer, String, DateTime, Date, Time, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.db import Base

class Localite(Base):
    __tablename__ = "localites"
    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String, nullable=False)
    type = Column(String, nullable=False)

class Parent(Base):
    __tablename__ = "parents"
    id = Column(Integer, primary_key=True, index=True)
    nom_pere = Column(String)
    prenom_pere = Column(String)
    telephone_pere = Column(String)
    nom_mere = Column(String)
    prenom_mere = Column(String)
    telephone_mere = Column(String)

class PreEnregistrement(Base):
    __tablename__ = "pre_enregistrements"
    id = Column(Integer, primary_key=True, index=True)
    numero_recu = Column(String)
    nom_enfant = Column(String, nullable=False)
    prenom_enfant = Column(String)
    sexe = Column(String)
    date_naissance = Column(Date)
    heure_naissance = Column(Time)
    
    parents_id = Column(Integer, ForeignKey("parents.id"))
    localite_id = Column(Integer, ForeignKey("localites.id"))
    
    telephone_declarant = Column(String)
    statut = Column(String, default="en_attente")
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relations
    parent = relationship("Parent", backref="enregistrements")
    localite = relationship("Localite", backref="enregistrements")