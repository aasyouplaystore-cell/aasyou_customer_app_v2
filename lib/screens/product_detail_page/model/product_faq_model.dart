
import '../../../config/helper.dart';

class ProductFAQModel {
  final bool success;
  final String message;
  final ProductFAQData data;

  ProductFAQModel({
    bool? success,
    String? message,
    ProductFAQData? data,
  })  : success = success ?? false,
        message = message ?? '',
        data = data ?? ProductFAQData();

  factory ProductFAQModel.fromJson(Map<String, dynamic> json) {
    return ProductFAQModel(
      success: parseBool(json['success']) ?? false,
      message: parseString(json['message']) ?? '',
      data: json['data'] != null ? ProductFAQData.fromJson(json['data']) : ProductFAQData(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };
}

class ProductFAQData {
  final int currentPage;
  final List<ProductFAQ> faqs;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<Links> links;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final String prevPageUrl;
  final int to;
  final int total;

  ProductFAQData({
    int? currentPage,
    List<ProductFAQ>? faqs,
    String? firstPageUrl,
    int? from,
    int? lastPage,
    String? lastPageUrl,
    List<Links>? links,
    String? nextPageUrl,
    String? path,
    int? perPage,
    String? prevPageUrl,
    int? to,
    int? total,
  })  : currentPage = currentPage ?? 1,
        faqs = faqs ?? const [],
        firstPageUrl = firstPageUrl ?? '',
        from = from ?? 0,
        lastPage = lastPage ?? 1,
        lastPageUrl = lastPageUrl ?? '',
        links = links ?? const [],
        nextPageUrl = nextPageUrl ?? '',
        path = path ?? '',
        perPage = perPage ?? 10,
        prevPageUrl = prevPageUrl ?? '',
        to = to ?? 0,
        total = total ?? 0;

  factory ProductFAQData.fromJson(Map<String, dynamic> json) {
    return ProductFAQData(
      currentPage: parseInt(json['current_page']) ?? 1,
      faqs: _parseFaqs(json['data']),
      firstPageUrl: parseString(json['first_page_url']) ?? '',
      from: parseInt(json['from']) ?? 0,
      lastPage: parseInt(json['last_page']) ?? 1,
      lastPageUrl: parseString(json['last_page_url']) ?? '',
      links: _parseLinks(json['links']),
      nextPageUrl: parseString(json['next_page_url']) ?? '',
      path: parseString(json['path']) ?? '',
      perPage: parseInt(json['per_page']) ?? 10,
      prevPageUrl: parseString(json['prev_page_url']) ?? '',
      to: parseInt(json['to']) ?? 0,
      total: parseInt(json['total']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': faqs.map((e) => e.toJson()).toList(),
    'first_page_url': firstPageUrl,
    'from': from,
    'last_page': lastPage,
    'last_page_url': lastPageUrl,
    'links': links.map((e) => e.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'path': path,
    'per_page': perPage,
    'prev_page_url': prevPageUrl,
    'to': to,
    'total': total,
  };

  static List<ProductFAQ> _parseFaqs(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(ProductFAQ.fromJson)
        .toList();
  }

  static List<Links> _parseLinks(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(Links.fromJson)
        .toList();
  }
}

class ProductFAQ {
  final int id;
  final int productId;
  final String productSlug;
  final Product product;
  final String question;
  final String answer;
  final String status;
  final String createdAt;
  final String updatedAt;

  ProductFAQ({
    int? id,
    int? productId,
    String? productSlug,
    Product? product,
    String? question,
    String? answer,
    String? status,
    String? createdAt,
    String? updatedAt,
  })  : id = id ?? 0,
        productId = productId ?? 0,
        productSlug = productSlug ?? '',
        product = product ?? Product(),
        question = question ?? '',
        answer = answer ?? '',
        status = status ?? '',
        createdAt = createdAt ?? '',
        updatedAt = updatedAt ?? '';

  factory ProductFAQ.fromJson(Map<String, dynamic> json) {
    return ProductFAQ(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      productSlug: parseString(json['product_slug']),
      product: json['product'] != null ? Product.fromJson(json['product']) : Product(),
      question: parseString(json['question']),
      answer: parseString(json['answer']),
      status: parseString(json['status']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_slug': productSlug,
    'product': product.toJson(),
    'question': question,
    'answer': answer,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class Product {
  final int id;
  final String title;
  final String slug;

  Product({
    int? id,
    String? title,
    String? slug,
  })  : id = id ?? 0,
        title = title ?? '',
        slug = slug ?? '';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: parseInt(json['id']),
      title: parseString(json['title']),
      slug: parseString(json['slug']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
  };
}

class Links {
  final String url;
  final String label;
  final int page;
  final bool active;

  Links({
    String? url,
    String? label,
    int? page,
    bool? active,
  })  : url = url ?? '',
        label = label ?? '',
        page = page ?? 0,
        active = active ?? false;

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      url: parseString(json['url']),
      label: parseString(json['label']),
      page: parseInt(json['page']) ?? 0,
      active: parseBool(json['active']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'page': page,
    'active': active,
  };
}