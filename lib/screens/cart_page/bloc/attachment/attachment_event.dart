part of 'attachment_bloc.dart';

abstract class AttachmentEvent extends Equatable {
  const AttachmentEvent();

  @override
  List<Object?> get props => [];
}

class AddAttachments extends AttachmentEvent {
  final int productId;
  final List<CartItemAttachment> attachment;

  const AddAttachments({
    required this.productId,
    required this.attachment,
  });

  @override
  List<Object?> get props => [productId, attachment];
}

class RemoveAttachment extends AttachmentEvent {
  final int productId;
  final CartItemAttachment attachment;

  const RemoveAttachment({
    required this.productId,
    required this.attachment,
  });

  @override
  List<Object?> get props => [productId, attachment];
}

class ClearAllAttachments extends AttachmentEvent {}