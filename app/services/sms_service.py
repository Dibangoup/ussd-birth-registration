import asyncio
import africastalking
import os
from dotenv import load_dotenv

# Charger les variables d'environnement (.env)
load_dotenv()

# Configuration Africa's Talking
username = "sandbox"
api_key = os.getenv("AFRICASTALKING_API_KEY")

# Initialisation du SDK
africastalking.initialize(username, api_key)
sms = africastalking.SMS

async def envoyer_confirmation_naissance(numero, nom_enfant, numero_recu, max_retries=3, delay=2):
    """
    Envoie un SMS de confirmation après un enregistrement USSD.
    Nettoie le numéro et gère les tentatives d'envoi de manière asynchrone.
    """
    
    # 1. Nettoyage du numéro de téléphone
    # On enlève les espaces vides et on s'assure que le numéro commence par +
    numero = numero.strip()
    if not numero.startswith('+'):
        numero = f"+{numero}"
    
    # 2. Préparation du message
    texte = f"Félicitations ! L'enregistrement de {nom_enfant} est réussi. Votre n° de reçu est : {numero_recu}."
    
    # 3. Logique de tentatives (Retry) héritée du travail d'Emmanuel
    for tentative in range(1, max_retries + 1):
        try:
            # Utilisation de asyncio.to_thread pour ne pas bloquer le serveur FastAPI
            # pendant que le SDK Africa's Talking communique avec l'opérateur
            response = await asyncio.to_thread(sms.send, texte, [numero])
            
            print(f"Succès : SMS envoyé à {numero} (Tentative {tentative})")
            return response
            
        except Exception as e:
            print(f"Erreur Tentative {tentative} pour {numero} : {e}")
            
            # Si ce n'est pas la dernière tentative, on attend avant de réessayer
            if tentative < max_retries:
                # Pause asynchrone (libère le serveur pour d'autres utilisateurs)
                await asyncio.sleep(delay)
                
    print(f"Échec définitif : Impossible d'envoyer le SMS à {numero} après {max_retries} essais.")
    return None