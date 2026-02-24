import 'user_role.dart';

/// Représente un coach ou formateur de l'académie.
class Encadreur {
  final String id;
  final String nom;
  final String prenom;
  final String? email;
  final String? motDePasse;
  final String telephone;
  final String photoUrl;
  final String specialite;
  final UserRole role;
  final String codeQrUnique;
  final DateTime createdAt;
  final int nbSeancesDirigees;
  final int nbAnnotations;

  Encadreur({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.motDePasse,
    required this.telephone,
    required this.photoUrl,
    required this.specialite,
    required this.role,
    required this.codeQrUnique,
    required this.createdAt,
    this.nbSeancesDirigees = 0,
    this.nbAnnotations = 0,
  });

  /// Crée une copie de l'encadreur avec des champs modifiés.
  Encadreur copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasse,
    String? telephone,
    String? photoUrl,
    String? specialite,
    UserRole? role,
    String? codeQrUnique,
    DateTime? createdAt,
    int? nbSeancesDirigees,
    int? nbAnnotations,
  }) {
    return Encadreur(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      telephone: telephone ?? this.telephone,
      photoUrl: photoUrl ?? this.photoUrl,
      specialite: specialite ?? this.specialite,
      role: role ?? this.role,
      codeQrUnique: codeQrUnique ?? this.codeQrUnique,
      createdAt: createdAt ?? this.createdAt,
      nbSeancesDirigees: nbSeancesDirigees ?? this.nbSeancesDirigees,
      nbAnnotations: nbAnnotations ?? this.nbAnnotations,
    );
  }

  /// Nom complet de l'encadreur.
  String get nomComplet => '$prenom $nom';

  /// Sérialisation vers Map pour le stockage local.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'photoUrl': photoUrl,
      'specialite': specialite,
      'role': role.id,
      'codeQrUnique': codeQrUnique,
      'createdAt': createdAt.toIso8601String(),
      'nbSeancesDirigees': nbSeancesDirigees,
      'nbAnnotations': nbAnnotations,
    };
    if (email != null) map['email'] = email;
    if (motDePasse != null) map['motDePasse'] = motDePasse;
    return map;
  }

  /// Désérialisation depuis Map.
  factory Encadreur.fromJson(Map<String, dynamic> json) {
    return Encadreur(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String?,
      telephone: json['telephone'] as String,
      photoUrl:
          json['photoUrl'] as String? ?? json['photo_url'] as String? ?? '',
      specialite: json['specialite'] as String,
      role: UserRole.fromId(json['role'] as String),
      codeQrUnique:
          json['codeQrUnique'] as String? ??
          json['code_qr_unique'] as String? ??
          '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            json['created_at'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      nbSeancesDirigees: json['nbSeancesDirigees'] as int? ?? 0,
      nbAnnotations: json['nbAnnotations'] as int? ?? 0,
    );
  }
}
