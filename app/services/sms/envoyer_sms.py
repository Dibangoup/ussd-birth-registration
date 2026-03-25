# ===== Import des modules nécessaires =====
import time  # Pour gérer les pauses entre les tentatives d'envoi de SMS
import africastalking  # Bibliothèque officielle Africa's Talking pour envoyer des SMS
from dotenv import load_dotenv  # Pour charger les variables d'environnement depuis un fichier .env
import os  # Pour accéder aux variables d'environnement

# ===== Charger les variables d'environnement =====
load_dotenv()  # Cela lit le fichier .env et charge les variables définies dedans

# ===== Récupérer les informations de connexion Africa's Talking =====
username = "sandbox"  # Nom d'utilisateur Africa's Talking (sandbox pour test)
api_key = os.getenv("AFRICASTALKING_API_KEY")  # Récupère la clé API depuis le fichier .env

# ===== Initialiser Africa's Talking =====
africastalking.initialize(username, api_key)  # Connexion à Africa's Talking avec nos identifiants
sms = africastalking.SMS  # Crée un objet pour envoyer des SMS

# ===== Définition de la fonction pour envoyer un SMS =====
def envoyer_sms(numero, texte, max_retries=3, delay=5):
    """
    Envoie un SMS au numéro spécifié avec gestion des erreurs et retry automatique.

    Args:
        numero (str): numéro de téléphone au format international (+225xxxxxxxx)
        texte (str): texte du SMS à envoyer
        max_retries (int): nombre maximum de tentatives en cas d'échec
        delay (int): délai (en secondes) entre chaque tentative

    Returns:
        dict ou None: réponse Africa's Talking si succès, None sinon
    """

    # Boucle pour gérer les tentatives multiples
    for tentative in range(1, max_retries + 1):
        try:
            # Tente d'envoyer le SMS
            response = sms.send(texte, [numero])
            print(f"SMS envoyé avec succès à {numero} !")  # Confirmation
            return response  # Retourne la réponse et sort de la fonction
        except Exception as e:  # <- Attraper toutes les erreurs ici
            # Gestion des erreurs spécifiques Africa's Talking
            print(f"Tentative {tentative} : Erreur Africa’s Talking : {e}")
        except Exception as e:
            # Gestion de toute autre erreur
            print(f"Tentative {tentative} : Une erreur est survenue : {e}")

        # Si ce n'était pas la dernière tentative, attendre avant de réessayer
        if tentative < max_retries:
            print(f"Nouvelle tentative dans {delay} secondes...")
            time.sleep(delay)  # Pause avant la prochaine tentative

    # Si toutes les tentatives échouent
    print("Échec de l'envoi du SMS après plusieurs tentatives.")
    return None

