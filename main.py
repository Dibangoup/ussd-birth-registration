from fastapi import FastAPI, Form
from typing import Optional

app = FastAPI(title="Système USSD d'Enregistrement des Naissances")

# 1. Dictionnaire de traduction (À affiner avec Désiré) [cite: 32, 85]
TRADUCTIONS = {
    "1": {  # Français
        "welcome": "CON Bienvenue sur le service d'état civil.\n1. Enregistrer une naissance\n2. Aide",
        "ask_name": "CON Entrez le NOM complet de l'enfant :",
        "confirmation": "END Merci. L'enregistrement est en cours. Un numéro de référence vous sera envoyé par SMS."
    },
    "2": {  # Langue Locale (Exemple)
        "welcome": "CON I ni ce. Sélikɛnɛ dɔnniyoro.\n1. Wolon fɛn dɔn\n2. Dɛmɛ",
        "ask_name": "CON Den tɔgɔ bɛn :",
        "confirmation": "END I ni ce. An bɛna SMS ci i ma ni reference ye."
    }
}

@app.post("/ussd")
async def ussd_handler(
    sessionId: str = Form(...),
    serviceCode: str = Form(...),
    phoneNumber: str = Form(...),
    text: str = Form(...)
):
    """
    Point d'entrée principal pour la passerelle Africa's Talking[cite: 27, 31, 58].
    """
    parts = text.split('*') if text != "" else []
    level = len(parts)
    response = ""

    # ÉTAPE 0 : Choix de la langue [cite: 25, 32]
    if level == 0:
        response = "CON Choisissez votre langue / Choice language:\n1. Français\n2. Langue Locale"

    # ÉTAPE 1 : Menu Principal [cite: 25]
    elif level == 1:
        lang = parts[0]
        if lang in TRADUCTIONS:
            response = TRADUCTIONS[lang]["welcome"]
        else:
            response = "END Option invalide / Invalid option."

    # ÉTAPE 2 : Saisie du Nom [cite: 25, 57]
    elif level == 2:
        lang = parts[0]
        action = parts[1]
        if action == "1":
            response = TRADUCTIONS[lang]["ask_name"]
        else:
            response = TRADUCTIONS[lang]["welcome"] # Retour au menu ou Aide

    # ÉTAPE FINALE : Validation & Notification [cite: 25, 33, 34]
    elif level == 3:
        lang = parts[0]
        nom_enfant = parts[2]
        
        # TODO: Appel au module de Maxime (MA) pour le stockage sécurisé [cite: 37, 70, 72]
        # reference = generate_reference()
        
        # TODO: Appel au module d'Emmanuel (EM) pour l'envoi du SMS [cite: 34, 98]
        
        response = TRADUCTIONS[lang]["confirmation"]

    return response