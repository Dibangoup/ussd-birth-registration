from fastapi import FastAPI, Request, Form
from app.services.sms_service import envoyer_confirmation_naissance
import uvicorn
import random

app = FastAPI(title="Système d'enregistrement des naissances - USSD")

@app.post("/ussd")
async def ussd_handler(
    sessionId: str = Form(...),
    serviceCode: str = Form(...),
    phoneNumber: str = Form(...),
    text: str = Form("")
):
    """
    Handler principal pour les requêtes USSD.
    """
    # On sépare les saisies de l'utilisateur par l'étoile (*)
    levels = text.split('*')
    response = ""

    # --- Logique du menu USSD ---
    if text == "":
        # Menu principal
        response = "CON Bienvenue sur TECHNOVIEW\n"
        response += "1. Enregistrer une naissance\n"
        response += "2. Quitter"

    elif text == "1":
        response = "CON Entrez le nom complet de l'enfant :"

    elif len(levels) == 2 and levels[0] == "1":
        response = "CON Entrez la date de naissance (JJ/MM/AAAA) :"

    elif len(levels) == 3 and levels[0] == "1":
        # C'est l'étape finale de la saisie
        nom_enfant = levels[1]
        date_naissance = levels[2]
        
        # 1. Génération d'un numéro de reçu (Simulation)
        numero_recu = f"REC-{random.randint(1000, 9999)}"

        # 2. Emplacement pour la sauvegarde en base de données
        # Ici, tu appelleras la logique de ton fichier database_dump.sql
        print(f"Sauvegarde en base : {nom_enfant}, né le {date_naissance}")

        # 3. Envoi du SMS de confirmation (Logique d'Emmanuel)
        # On utilise 'await' car la fonction est asynchrone
        await envoyer_confirmation_naissance(
            numero=phoneNumber,
            nom_enfant=nom_enfant,
            numero_recu=numero_recu
        )

        response = f"END Merci. L'enregistrement de {nom_enfant} est terminé.\nUn SMS de confirmation a été envoyé au {phoneNumber}."

    else:
        response = "END Session terminée. Merci d'avoir utilisé notre service."

    return response

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)