from fastapi import FastAPI, Form
from fastapi.responses import PlainTextResponse

app = FastAPI(title="Système USSD d'Enregistrement des Naissances")

# 🔥 Textes en français uniquement
TEXTS = {
    "welcome": "CON Bienvenue sur le service d'état civil.\n1. Enregistrer une naissance\n2. Aide",
    "ask_name": "CON Entrez le NOM complet de l'enfant :",
    "help": "CON Ce service permet d'enregistrer une naissance.\nChoisissez 1 pour continuer.",
    "confirmation": "END Merci. L'enregistrement est en cours. Un numéro de référence vous sera envoyé par SMS.",
    "invalid": "END Option invalide. Veuillez réessayer."
}

@app.post("/ussd", response_class=PlainTextResponse)
async def ussd_handler(
    sessionId: str = Form(...),
    serviceCode: str = Form(...),
    phoneNumber: str = Form(...),
    text: str = Form("")
):
    text = text.strip()
    parts = text.split('*') if text != "" else []
    level = len(parts)

    # 🔹 ÉTAPE 0 : Menu principal direct
    if level == 0:
        return PlainTextResponse(TEXTS["welcome"])

    # 🔹 ÉTAPE 1 : Choix utilisateur
    elif level == 1:
        choice = parts[0]

        if choice == "1":
            return PlainTextResponse(TEXTS["ask_name"])
        elif choice == "2":
            return PlainTextResponse(TEXTS["help"])
        else:
            return PlainTextResponse(TEXTS["invalid"])

    # 🔹 ÉTAPE 2 : Nom saisi
    elif level == 2:
        nom_enfant = parts[1]

        

        return PlainTextResponse(TEXTS["confirmation"])

    # 🔹 Cas non prévu
    return PlainTextResponse("END Session terminée.")