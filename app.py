from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
from flask_cors import CORS
import math

app = Flask(__name__)
CORS(app)  # Para permitir requisições de diferentes origens (CORS)

# Inicialize o Firebase Admin SDK
cred = credentials.Certificate('C:/aaaaaaa/projetoipet/android/app/ad-ipet-firebase-adminsdk-ndii9-19c533fbe2.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Função para calcular a distância Euclidiana entre o usuário e os animais
def euclidean_distance(user, animal):
    # Para raça (1 se coincidir, 0 se não coincidir)
    breed_similarity = 1 if user['specificBreed'] == animal.get('breed', '') else 0
    
    # Para idade: lidar com o caso de 'Ambos' ou idade numérica
    user_age_preference = 0
    if user.get('preferred_age') and user.get('preferred_age').isdigit():
        user_age_preference = int(user.get('preferred_age'))
    
    animal_age = int(animal.get('age', 0)) if animal.get('age') else 0
    age_difference = abs(user_age_preference - animal_age)

    # Para cidade (1 se coincidir, 0 se não coincidir)
    city_similarity = 1 if user['city'] == animal.get('city', '') else 0

    # Combinar todos os fatores em uma distância Euclidiana
    distance = math.sqrt((1 - breed_similarity)**2 + (age_difference)**2 + (1 - city_similarity)**2)
    return distance


@app.route('/recommend', methods=['POST'])
def recommend():
    # Receber dados do usuário da requisição
    data = request.json
    user_id = data.get('userId')
    city = data.get('city')
    neighborhood = data.get('neighborhood')

    # Obter dados do adotante (usuário) do Firestore
    adopter_doc = db.collection('form_responses').document(user_id).get()
    adopter_data = adopter_doc.to_dict() if adopter_doc.exists else {}

    # Preferências do usuário
    specific_breed = adopter_data.get('specificBreed', None)
    preferred_age = adopter_data.get('petPreference', None)  # Se preferir uma idade específica de animal

    # Obter todos os animais da cidade especificada
    animals_ref = db.collection('animals')
    query = animals_ref.where('city', '==', city)
    animals = query.stream()

    # Lista de recomendações e distâncias
    recommendations = []
    
    for doc in animals:
        animal = doc.to_dict()
        animal['id'] = doc.id

        # Calcular a distância Euclidiana entre as preferências do usuário e as características do animal
        user_preferences = {
            'city': city,
            'specificBreed': specific_breed,
            'preferred_age': preferred_age
        }
        distance = euclidean_distance(user_preferences, animal)

        # Adicionar o animal e a distância calculada à lista de recomendações
        recommendations.append((animal, distance))

    # Classificar os animais pela menor distância
    recommendations.sort(key=lambda x: x[1])

    # Retornar os K animais mais próximos (por exemplo, os 5 mais próximos)
    K = 5
    top_recommendations = [rec[0] for rec in recommendations[:K]]

    return jsonify(top_recommendations)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
