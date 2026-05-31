class AdTrackingResponse {
  final bool success;
  final String message;
  final List<dynamic> data;

  AdTrackingResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdTrackingResponse.fromJson(Map<String, dynamic> json) {
    return AdTrackingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? [],
    );
  }
}