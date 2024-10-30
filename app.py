import os
from flask import Flask, request, jsonify
import firebase_admin
from firebase_admin import credentials, firestore
from flask_cors import CORS
import math

application = Flask(__name__)
CORS(application)  # Para permitir requisições de diferentes origens (CORS)

# Inicialize o Firebase Admin SDK
cred_path = os.getenv('GOOGLE_APPLICATION_CREDENTIALS')  # Obtém o caminho do arquivo de credenciais
cred = credentials.Certificate(cred_path)  # Cria o objeto de credenciais

<<<<<<< HEAD
=======
firebase_admin.initialize_app(cred)  # Inicializa o Firebase Admin SDK com as credenciais
db = firestore.client()

# Função para calcular a idade preferida com base nas curtidas do usuário
def get_preferred_age_from_likes(user_id):
    # Obter as curtidas do usuário da coleção 'liked_pets'
    likes_ref = db.collection('liked_pets').where('userId', '==', user_id)
    liked_animals = likes_ref.stream()

    # Extrair idades dos animais curtidos
    ages = []
    for like in liked_animals:
        animal_id = like.get('petId')
        animal_doc = db.collection('animals').document(animal_id).get()
        if animal_doc.exists:
            animal_data = animal_doc.to_dict()
            age_str = animal_data.get('age', '0')
            try:
                # Extraindo o número da idade, por exemplo: '3 anos' -> 3
                age = int(age_str.split()[0])
                ages.append(age)
            except ValueError:
                continue

    # Calcular a idade média dos animais curtidos, se houver curtidas
    if ages:
        average_age = sum(ages) / len(ages)
        return average_age
    return None  # Se o usuário não curtiu nenhum animal, não tem preferência de idade

# Função para calcular a distância euclidiana
>>>>>>> ae27dc5 (Atualizações no projeto iPet: correção de ícones, adição de telas de edição e splash e demais etapas do desenvolvimento)
def euclidean_distance(user, animal):
    # Comparar a raça (1 se coincidir, 0 se não coincidir)
    breed_similarity = 1 if user['specificBreed'] == animal.get('breed', '') else 0
<<<<<<< HEAD
    
    # Para idade: lidar com o caso de 'Ambos' ou idade numérica, removendo texto como 'anos'
    user_age_preference = 0
    if user.get('preferred_age') and user.get('preferred_age').isdigit():
        user_age_preference = int(user.get('preferred_age'))
    
    animal_age_str = animal.get('age', '0')  # Pegue a idade como string, ou '0' se estiver ausente
    animal_age = 0
    
    try:
        # Tente extrair apenas os números da idade
        animal_age = int(''.join(filter(str.isdigit, animal_age_str)))
    except ValueError:
        print(f"Valor de idade inválido para o animal {animal.get('name', 'sem nome')}: {animal_age_str}")
    
=======

    # Calcular a diferença de idade
    user_age_preference = user.get('preferred_age', 0)  # Idade preferida do usuário
    animal_age = 0
    try:
        animal_age = int(animal.get('age', '0').split()[0])  # Idade do animal
    except ValueError:
        print(f"Erro ao converter idade para o animal {animal.get('name', 'desconhecido')}")

>>>>>>> ae27dc5 (Atualizações no projeto iPet: correção de ícones, adição de telas de edição e splash e demais etapas do desenvolvimento)
    age_difference = abs(user_age_preference - animal_age)

    # Comparar a cidade (1 se coincidir, 0 se não coincidir)
    city_similarity = 1 if user['city'] == animal.get('city', '') else 0

    # Calcular a distância euclidiana com base nas similaridades
    distance = math.sqrt((1 - breed_similarity)**2 + (age_difference)**2 + (1 - city_similarity)**2)
    return distance

<<<<<<< HEAD



@app.route('/recommend', methods=['POST'])
=======
# Endpoint para recomendar animais
@application.route('/recommend', methods=['POST'])
>>>>>>> ae27dc5 (Atualizações no projeto iPet: correção de ícones, adição de telas de edição e splash e demais etapas do desenvolvimento)
def recommend():
    # Receber dados do usuário da requisição
    data = request.json
    user_id = data.get('userId')
    city = data.get('city')

    # Obter dados do adotante (usuário) do Firestore
    adopter_doc = db.collection('form_responses').document(user_id).get()
    adopter_data = adopter_doc.to_dict() if adopter_doc.exists else {}

    # Obter a idade preferida com base nas curtidas do usuário
    preferred_age = get_preferred_age_from_likes(user_id)

    # Obter a raça preferida do Firestore
    specific_breed = adopter_data.get('specificBreed', None)

    # Buscar animais na cidade especificada
    animals_ref = db.collection('animals')
    query = animals_ref.where('city', '==', city)
    animals = query.stream()

    # Lista de recomendações e distâncias
    recommendations = []
    
    for doc in animals:
        animal = doc.to_dict()
        animal['id'] = doc.id

        # Preparar as preferências do usuário para comparação
        user_preferences = {
            'city': city,
            'specificBreed': specific_breed,
            'preferred_age': preferred_age  # Idade calculada com base nas curtidas
        }

        # Calcular a distância euclidiana entre o animal e as preferências do usuário
        distance = euclidean_distance(user_preferences, animal)
        recommendations.append((animal, distance))

    # Classificar os animais pela menor distância
    recommendations.sort(key=lambda x: x[1])

    # Retornar os K animais mais próximos (por exemplo, os 500 mais próximos)
    K = 500
    top_recommendations = [rec[0] for rec in recommendations[:K]]

    return jsonify(top_recommendations)

if __name__ == '__main__':
    application.run(debug=True)
