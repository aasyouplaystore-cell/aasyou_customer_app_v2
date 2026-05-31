import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/cart_product_item.dart';
part 'attachment_event.dart';
part 'attachment_state.dart';

class AttachmentBloc extends Bloc<AttachmentEvent, AttachmentState> {
  AttachmentBloc() : super(const AttachmentInitial()) {
    on<AddAttachments>(_onAddAttachments);
    on<RemoveAttachment>(_onRemove);
    on<ClearAllAttachments>(_onClearAll);
  }

  Future<void> _onAddAttachments(AddAttachments event, Emitter<AttachmentState> emit) async {
    final current = Map<int, List<CartItemAttachment>>.from(state.attachments);
    final existing = current[event.productId] ?? <CartItemAttachment>[];
    final updatedList = [...existing, ...event.attachment];
    current[event.productId] = updatedList;
    emit(AttachmentLoaded(attachmentsList: current));
  }

  Future<void> _onRemove(
      RemoveAttachment event,
      Emitter<AttachmentState> emit,
      ) async {
    final current = Map<int, List<CartItemAttachment>>.from(
      state is AttachmentLoaded ? (state as AttachmentLoaded).attachments : {},
    );

    final list = current[event.productId];
    if (list != null) {
      final updatedList = list.where((a) => a.id != event.attachment.id).toList();

      if (updatedList.isEmpty) {
        current.remove(event.productId);
      } else {
        current[event.productId] = updatedList;
      }
    }

    emit(AttachmentLoaded(attachmentsList: current));
  }

  Future<void> _onClearAll(
      ClearAllAttachments event,
      Emitter<AttachmentState> emit,
      ) async {
    emit(const AttachmentLoaded(attachmentsList: {}));
  }
}