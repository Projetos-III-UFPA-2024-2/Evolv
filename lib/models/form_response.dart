class FormResponse {
  String name;
  String timeAvailable;
  String specificBreed;

  FormResponse({
    required this.name,
    required this.timeAvailable,
    required this.specificBreed,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'timeAvailable': timeAvailable,
      'specificBreed': specificBreed,
    };
  }

  factory FormResponse.fromMap(Map<String, dynamic> map) {
    return FormResponse(
      name: map['name'],
      timeAvailable: map['timeAvailable'],
      specificBreed: map['specificBreed'],
    );
  }
}
