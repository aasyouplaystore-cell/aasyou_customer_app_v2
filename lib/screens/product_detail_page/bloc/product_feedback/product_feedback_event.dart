part of 'product_feedback_bloc.dart';

abstract class ProductFeedbackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddProductFeedback extends ProductFeedbackEvent {
  final int orderItemId;
  final String title;
  final String description;
  final int rating;
  final List<XFile> images;

  AddProductFeedback({
    required this.orderItemId,
    required this.title,
    required this.description,
    required this.rating,
    this.images = const [],
  });

  @override
  List<Object?> get props => [
    orderItemId,
    title,
    description,
    rating,
    images
  ];
}

class UpdateProductFeedback extends ProductFeedbackEvent {
  final int feedbackId;
  final String title;
  final String description;
  final int rating;
  final List<XFile> images;

  UpdateProductFeedback({
    required this.feedbackId,
    required this.title,
    required this.description,
    required this.rating,
    this.images = const [],
  });

  @override
  List<Object?> get props => [
    feedbackId,
    title,
    description,
    rating,
    images
  ];
}

class DeleteProductFeedback extends ProductFeedbackEvent {
  final int feedbackId;

  DeleteProductFeedback({
    required this.feedbackId,
  });

  @override
  List<Object?> get props => [feedbackId];
}

class ResetProductFeedback extends ProductFeedbackEvent {}































//
