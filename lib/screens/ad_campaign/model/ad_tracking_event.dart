class AdTrackingEvent {
  final int campaignId;
  final String visitorKey;
  final DateTime timestamp;

  const AdTrackingEvent({
    required this.campaignId,
    required this.visitorKey,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'campaign_id': campaignId,
        'visitor_key': visitorKey,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };
}
