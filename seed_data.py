"""
Script de peuplement de la base de données avec des données réalistes.
Exécuter avec : python seed_data.py (depuis la racine du projet, venv activé)
"""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from datetime import datetime, timedelta, date, time
import random

from app.core.db import SessionLocal, engine, Base
from app.models.birth import PreEnregistrement, Parent, Localite

# Créer les tables si elles n'existent pas encore
Base.metadata.create_all(bind=engine)

db = SessionLocal()

# ==========================================
# 1. LOCALITES
# ==========================================
localites_data = [
    ("Abobo", "ville"),
    ("Yopougon", "ville"),
    ("Bouaké", "ville"),
    ("Daloa", "ville"),
    ("Korhogo", "ville"),
    ("San-Pédro", "ville"),
    ("Yamoussoukro", "ville"),
    ("Man", "ville"),
    ("Gagnoa", "ville"),
    ("Divo", "ville"),
    ("Katiola", "village"),
    ("Bondoukou", "village"),
    ("Séguéla", "village"),
    ("Odienné", "village"),
    ("Ferkessédougou", "village"),
]

localites = []
for nom, type_loc in localites_data:
    loc = Localite(nom=nom, type=type_loc)
    db.add(loc)
    db.flush()
    localites.append(loc)

print(f"✅ {len(localites)} localités insérées")

# ==========================================
# 2. PARENTS
# ==========================================
noms = ["Koné", "Touré", "Coulibaly", "Diallo", "Ouattara", "Bamba", "Traoré", "Soro", "Yao", "Koffi",
        "Diabaté", "Cissé", "Sanogo", "Doumbia", "Camara", "Bah", "Sylla", "Fofana", "Keita", "Dembélé"]
prenoms_m = ["Moussa", "Ibrahim", "Amadou", "Sékou", "Ousmane", "Abou", "Mamadou", "Bakary", "Lassina", "Drissa"]
prenoms_f = ["Aminata", "Fatoumata", "Mariam", "Aïssata", "Kadiatou", "Rokia", "Awa", "Djénéba", "Oumou", "Salimata"]

parents_list = []
for i in range(30):
    parent = Parent(
        nom_pere=random.choice(noms),
        prenom_pere=random.choice(prenoms_m),
        telephone_pere=f"+225 07{random.randint(10000000, 99999999)}",
        nom_mere=random.choice(noms),
        prenom_mere=random.choice(prenoms_f),
        telephone_mere=f"+225 05{random.randint(10000000, 99999999)}"
    )
    db.add(parent)
    db.flush()
    parents_list.append(parent)

print(f"✅ {len(parents_list)} parents insérés")

# ==========================================
# 3. PRE-ENREGISTREMENTS (Déclarations)
# ==========================================
prenoms_enfant_m = ["Youssouf", "Ali", "Mohamed", "Jean", "Pierre", "Paul", "Ismaël", "David", "Samuel", "Emmanuel"]
prenoms_enfant_f = ["Marie", "Grace", "Ruth", "Esther", "Sarah", "Naomi", "Rebecca", "Rachel", "Léa", "Hawa"]
statuts = ["en_attente", "valide", "rejete"]

declarations = []
for i in range(80):
    sexe = random.choice(["M", "F"])
    prenom = random.choice(prenoms_enfant_m if sexe == "M" else prenoms_enfant_f)
    nom = random.choice(noms)
    
    # Dates réparties sur les 6 derniers mois
    jours_avant = random.randint(0, 180)
    date_creation = datetime.utcnow() - timedelta(days=jours_avant)
    date_naiss = date_creation.date() - timedelta(days=random.randint(0, 14))
    
    # Distribution réaliste des statuts: 50% en attente, 35% validé, 15% rejeté
    rand_statut = random.random()
    if rand_statut < 0.35:
        statut = "valide"
    elif rand_statut < 0.85:
        statut = "en_attente"
    else:
        statut = "rejete"
    
    decl = PreEnregistrement(
        numero_recu=f"REC-2026-{str(i+1).zfill(6)}",
        nom_enfant=nom,
        prenom_enfant=prenom,
        sexe=sexe,
        date_naissance=date_naiss,
        heure_naissance=time(random.randint(0, 23), random.randint(0, 59)),
        parents_id=random.choice(parents_list).id,
        localite_id=random.choice(localites).id,
        telephone_declarant=f"+225 07{random.randint(10000000, 99999999)}",
        statut=statut,
        created_at=date_creation
    )
    db.add(decl)
    declarations.append(decl)

db.commit()
print(f"✅ {len(declarations)} déclarations insérées")
print(f"\n🎉 Base de données peuplée avec succès !")
print(f"   - {len(localites)} localités")
print(f"   - {len(parents_list)} parents")
print(f"   - {len(declarations)} déclarations de naissance")

valides = sum(1 for d in declarations if d.statut == "valide")
attente = sum(1 for d in declarations if d.statut == "en_attente")
rejetes = sum(1 for d in declarations if d.statut == "rejete")
print(f"   - Statuts: {valides} validées, {attente} en attente, {rejetes} rejetées")

db.close()
