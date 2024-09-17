class Veterinarian {
  String id;
  String ownerId;
  String name;
  String contactMethod;
  String contactInfo;
  String specialization;
  String experience;
  String city;
  String neighborhood;
  bool homeService;
  String clinicAddress;
  String workingHours;

  Veterinarian({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.contactMethod,
    required this.contactInfo,
    required this.specialization,
    required this.experience,
    required this.city,
    required this.neighborhood,
    required this.homeService,
    required this.clinicAddress,
    required this.workingHours,
  });

  // Método para criar um objeto Veterinarian a partir de um Map (usado ao recuperar dados do Firebase)
  factory Veterinarian.fromMap(Map<String, dynamic> data) {
    return Veterinarian(
      id: data['id'] ?? '',
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      contactMethod: data['contactMethod'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      specialization: data['specialization'] ?? '',
      experience: data['experience'] ?? '',
      city: data['city'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      homeService: data['homeService'] ?? false,
      clinicAddress: data['clinicAddress'] ?? '',
      workingHours: data['workingHours'] ?? '',
    );
  }

  // Método para converter um objeto Veterinarian para Map (usado para salvar no Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'contactMethod': contactMethod,
      'contactInfo': contactInfo,
      'specialization': specialization,
      'experience': experience,
      'city': city,
      'neighborhood': neighborhood,
      'homeService': homeService,
      'clinicAddress': clinicAddress,
      'workingHours': workingHours,
    };
  }

  // Método copyWith para criar uma nova instância de Veterinarian alterando apenas campos específicos
  Veterinarian copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? contactMethod,
    String? contactInfo,
    String? specialization,
    String? experience,
    String? city,
    String? neighborhood,
    bool? homeService,
    String? clinicAddress,
    String? workingHours,
  }) {
    return Veterinarian(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      contactMethod: contactMethod ?? this.contactMethod,
      contactInfo: contactInfo ?? this.contactInfo,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      homeService: homeService ?? this.homeService,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      workingHours: workingHours ?? this.workingHours,
    );
  }
}
