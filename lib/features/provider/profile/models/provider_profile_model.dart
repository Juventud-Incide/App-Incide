class ProviderProfileModel {
  final String id;
  final String name;
  final String initials;
  final String? avatarUrl;
  final bool isCertified;
  final bool hasUnreadNotifications;
  final bool isRadarActive;

  ProviderProfileModel({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarUrl,
    this.isCertified = false,
    this.hasUnreadNotifications = false,
    this.isRadarActive = true,
  });

  ProviderProfileModel copyWith({
    String? id,
    String? name,
    String? initials,
    String? avatarUrl,
    bool? isCertified,
    bool? hasUnreadNotifications,
    bool? isRadarActive,
  }) {
    return ProviderProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCertified: isCertified ?? this.isCertified,
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
      isRadarActive: isRadarActive ?? this.isRadarActive,
    );
  }
}
