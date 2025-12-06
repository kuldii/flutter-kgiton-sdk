/// System setting model
class SystemSetting {
  final String id;
  final String settingKey;
  final String settingValue;
  final String description;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SystemSetting({
    required this.id,
    required this.settingKey,
    required this.settingValue,
    required this.description,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SystemSetting.fromJson(Map<String, dynamic> json) {
    return SystemSetting(
      id: json['id'] as String,
      settingKey: json['setting_key'] as String,
      settingValue: json['setting_value'] as String,
      description: json['description'] as String,
      updatedBy: json['updated_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setting_key': settingKey,
      'setting_value': settingValue,
      'description': description,
      if (updatedBy != null) 'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// System settings list data
class SystemSettingsData {
  final List<SystemSetting> settings;

  SystemSettingsData({required this.settings});

  factory SystemSettingsData.fromJson(Map<String, dynamic> json) {
    return SystemSettingsData(settings: (json['settings'] as List).map((e) => SystemSetting.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'settings': settings.map((e) => e.toJson()).toList()};
  }
}

/// Cart processing fee data
class CartProcessingFeeData {
  final double cartProcessingFee;

  CartProcessingFeeData({required this.cartProcessingFee});

  factory CartProcessingFeeData.fromJson(Map<String, dynamic> json) {
    return CartProcessingFeeData(cartProcessingFee: (json['cart_processing_fee'] as num).toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'cart_processing_fee': cartProcessingFee};
  }
}

/// Update cart processing fee request
class UpdateCartProcessingFeeRequest {
  final double fee;

  UpdateCartProcessingFeeRequest({required this.fee});

  Map<String, dynamic> toJson() {
    return {'fee': fee};
  }
}

/// Update setting response data
class UpdateSettingData {
  final SystemSetting setting;

  UpdateSettingData({required this.setting});

  factory UpdateSettingData.fromJson(Map<String, dynamic> json) {
    return UpdateSettingData(setting: SystemSetting.fromJson(json['setting'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'setting': setting.toJson()};
  }
}
