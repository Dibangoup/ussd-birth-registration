"""
Tests USSD - Base de données isolée en mémoire SQLite.
Exécuter avec: pytest tests/test_ussd.py -v
"""
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.db import Base, get_db
from app.main import app
from app.models.birth import PreEnregistrement, Parent, Localite

# Base de test isolée en mémoire
TEST_DATABASE_URL = "sqlite:///./test_ussd.db"
engine_test = create_engine(TEST_DATABASE_URL, connect_args={"check_same_thread": False})
TestSession = sessionmaker(autocommit=False, autoflush=False, bind=engine_test)

def override_get_db():
    db = TestSession()
    try:
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture(autouse=True)
def setup_database():
    Base.metadata.create_all(bind=engine_test)
    yield
    Base.metadata.drop_all(bind=engine_test)

client = TestClient(app)

# ============================================================
# Tests du flux USSD
# ============================================================

def test_ussd_level_0():
    """Étape 0: Menu principal"""
    response = client.post(
        "/ussd",
        data={
            "sessionId": "12345",
            "serviceCode": "*129#",
            "phoneNumber": "+2250102030405",
            "text": ""
        }
    )
    assert response.status_code == 200
    assert "CON Bienvenue sur le service d'état civil" in response.text

def test_ussd_level_1_enregistrer():
    """Étape 1: Choix 'Enregistrer une naissance'"""
    response = client.post(
        "/ussd",
        data={
            "sessionId": "12345",
            "serviceCode": "*129#",
            "phoneNumber": "+2250102030405",
            "text": "1"
        }
    )
    assert response.status_code == 200
    assert "CON Entrez le NOM complet de l'enfant" in response.text

def test_ussd_level_1_invalide():
    """Étape 1: Choix invalide"""
    response = client.post(
        "/ussd",
        data={
            "sessionId": "12345",
            "serviceCode": "*129#",
            "phoneNumber": "+2250102030405",
            "text": "9"
        }
    )
    assert response.status_code == 200
    assert "END" in response.text

def test_ussd_level_2_nom():
    """Étape 2: Saisie du nom → demande sexe"""
    response = client.post(
        "/ussd",
        data={
            "sessionId": "12345",
            "serviceCode": "*129#",
            "phoneNumber": "+2250102030405",
            "text": "1*Jean Dupont"
        }
    )
    assert response.status_code == 200
    assert "CON Entrez le sexe de l'enfant (M ou F)" in response.text

def test_ussd_level_3_sexe():
    """Étape 3: Saisie du sexe → demande date"""
    response = client.post(
        "/ussd",
        data={
            "sessionId": "12345",
            "serviceCode": "*129#",
            "phoneNumber": "+2250102030405",
            "text": "1*Jean Dupont*M"
        }
    )
    assert response.status_code == 200
    assert "CON Entrez la date de naissance (JJ/MM/AAAA)" in response.text

def test_ussd_level_4_final():
    """Étape 4: Confirmation + insertion en base"""
    response = client.post(
        "/ussd",
        data={
            "sessionId": "12345",
            "serviceCode": "*129#",
            "phoneNumber": "+2250102030405",
            "text": "1*Jean Dupont*M*01/01/2026"
        }
    )
    assert response.status_code == 200
    assert "END Merci. L'enregistrement est terminé" in response.text

def test_ussd_level_4_insertion_db():
    """Vérifie que l'enregistrement est bien inséré en base"""
    client.post(
        "/ussd",
        data={
            "sessionId": "test-db-check",
            "serviceCode": "*129#",
            "phoneNumber": "+2250708090010",
            "text": "1*Awa Koné*F*15/03/2026"
        }
    )
    
    db = TestSession()
    record = db.query(PreEnregistrement).filter(
        PreEnregistrement.telephone_declarant == "+2250708090010"
    ).first()
    db.close()
    
    assert record is not None
    assert record.nom_enfant == "Awa Koné"
    assert record.sexe == "F"
    assert record.statut == "en_attente"
    assert record.numero_recu is not None
    assert record.numero_recu.startswith("REC-2026-")

# ============================================================
# Tests des endpoints API Dashboard
# ============================================================

def test_api_stats():
    """Vérifie l'endpoint /api/dashboard/stats"""
    response = client.get("/api/dashboard/stats?period=Année")
    assert response.status_code == 200
    data = response.json()
    assert "valides" in data
    assert "recues" in data
    assert "rejetees" in data
    assert "en_attente" in data

def test_api_declarations():
    """Vérifie l'endpoint /api/dashboard/declarations"""
    response = client.get("/api/dashboard/declarations?period=Année")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_api_parents():
    """Vérifie l'endpoint /api/parents"""
    response = client.get("/api/parents")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_api_localites():
    """Vérifie l'endpoint /api/localites"""
    response = client.get("/api/localites")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_api_statistiques():
    """Vérifie l'endpoint /api/statistiques"""
    response = client.get("/api/statistiques")
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "garcons" in data
    assert "filles" in data

def test_api_demandes():
    """Vérifie l'endpoint /api/demandes"""
    response = client.get("/api/demandes")
    assert response.status_code == 200
    assert isinstance(response.json(), list)

def test_api_chart():
    """Vérifie l'endpoint /api/dashboard/chart"""
    response = client.get("/api/dashboard/chart?period=Mois")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0

def test_api_calendar():
    """Vérifie l'endpoint /api/dashboard/calendar"""
    response = client.get("/api/dashboard/calendar?period=Mois")
    assert response.status_code == 200
    data = response.json()
    assert "validation_rate" in data
    assert "total" in data
