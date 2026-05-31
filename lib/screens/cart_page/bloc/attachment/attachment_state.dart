part of 'attachment_bloc.dart';

abstract class AttachmentState extends Equatable {
  const AttachmentState();

  Map<int, List<CartItemAttachment>> get attachments => {};
}

class AttachmentInitial extends AttachmentState {
  const AttachmentInitial();

  @override
  List<Object> get props => [];
}

class AttachmentLoaded extends AttachmentState {
  final Map<int, List<CartItemAttachment>> attachmentsList;

  const AttachmentLoaded({required this.attachmentsList});

  @override
  Map<int, List<CartItemAttachment>> get attachments => attachmentsList;

  @override
  List<Object> get props => [attachmentsList];
}