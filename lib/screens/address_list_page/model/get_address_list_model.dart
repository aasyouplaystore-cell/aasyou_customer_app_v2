
import '../../../config/helper.dart';

class GetAddressListModel {
  bool? success;
  String? message;
  GetAddressListData? data;

  GetAddressListModel({this.success, this.message, this.data});

  GetAddressListModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? GetAddressListData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class GetAddressListData {
  int? currentPage;
  List<AddressListData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  GetAddressListData(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total});

  GetAddressListData.fromJson(Map<String, dynamic> json) {
    currentPage = parseInt(json['current_page']);
    if (json['data'] != null) {
      data = <AddressListData>[];
      json['data'].forEach((v) {
        data!.add(AddressListData.fromJson(v));
      });
    }
    firstPageUrl = parseString(json['first_page_url']);
    from = parseInt(json['from']);
    lastPage = parseInt(json['last_page']);
    lastPageUrl = parseString(json['last_page_url']);
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    nextPageUrl = parseString(json['next_page_url']);
    path = parseString(json['path']);
    perPage = parseInt(json['per_page']);
    prevPageUrl = parseString(json['prev_page_url']);
    to = parseInt(json['to']);
    total = parseInt(json['total']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class AddressListData {
  int? id;
  int? userId;
  String? addressLine1;
  String? addressLine2;
  String? city;
  String? landmark;
  String? state;
  String? zipcode;
  String? mobile;
  String? addressType;
  String? country;
  String? countryCode;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? updatedAt;

  AddressListData(
      {this.id,
        this.userId,
        this.addressLine1,
        this.addressLine2,
        this.city,
        this.landmark,
        this.state,
        this.zipcode,
        this.mobile,
        this.addressType,
        this.country,
        this.countryCode,
        this.latitude,
        this.longitude,
        this.createdAt,
        this.updatedAt});

  AddressListData.fromJson(Map<String, dynamic> json) {
    id = parseInt(json['id']);
    userId = parseInt(json['user_id']);
    addressLine1 = parseString(json['address_line1']);
    addressLine2 = parseString(json['address_line2']);
    city = parseString(json['city']);
    landmark = parseString(json['landmark']);
    state = parseString(json['state']);
    zipcode = parseString(json['zipcode']);
    mobile = parseString(json['mobile']);
    addressType = parseString(json['address_type']);
    country = parseString(json['country']);
    countryCode = parseString(json['country_code']);
    latitude = parseString(json['latitude']);
    longitude = parseString(json['longitude']);
    createdAt = parseString(json['created_at']);
    updatedAt = parseString(json['updated_at']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['address_line1'] = addressLine1;
    data['address_line2'] = addressLine2;
    data['city'] = city;
    data['landmark'] = landmark;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['mobile'] = mobile;
    data['address_type'] = addressType;
    data['country'] = country;
    data['country_code'] = countryCode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  int? page;
  bool? active;

  Links({this.url, this.label, this.page, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = parseString(json['url']);
    label = parseString(json['label']);
    page = parseInt(json['page']);
    active = parseBool(json['active']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['page'] = page;
    data['active'] = active;
    return data;
  }
}
