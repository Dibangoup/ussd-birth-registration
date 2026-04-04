from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_ussd_level_0():
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

def test_ussd_level_2_nom():
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

