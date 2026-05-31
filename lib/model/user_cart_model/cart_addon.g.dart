// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_addon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartAddonAdapter extends TypeAdapter<CartAddon> {
  @override
  final int typeId = 12;

  @override
  CartAddon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartAddon(
      addonGroupId: fields[0] as int,
      addonItemId: fields[1] as int,
      title: fields[2] as String,
      price: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CartAddon obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.addonGroupId)
      ..writeByte(1)
      ..write(obj.addonItemId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartAddonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
