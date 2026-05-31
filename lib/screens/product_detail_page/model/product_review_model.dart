
import '../../../config/helper.dart';

class ProductReviewModel {
  final bool success;
  final String message;
  final ProductReviewData data;

  ProductReviewModel({
    bool? success,
    String? message,
    ProductReviewData? data,
  })  : success = success ?? false,
        message = message ?? '',
        data = data ?? ProductReviewData();

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      success: parseBool(json['success']) ?? false,
      message: parseString(json['message']) ?? '',
      data: json['data'] != null
          ? ProductReviewData.fromJson(json['data'])
          : ProductReviewData(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };
}

class ProductReviewData {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final ReviewData data;

  ProductReviewData({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    ReviewData? data,
  })  : currentPage = currentPage ?? 1,
        lastPage = lastPage ?? 1,
        perPage = perPage ?? 10,
        total = total ?? 0,
        data = data ?? ReviewData();

  factory ProductReviewData.fromJson(Map<String, dynamic> json) {
    return ProductReviewData(
      currentPage: parseInt(json['current_page']) ?? 1,
      lastPage: parseInt(json['last_page']) ?? 1,
      perPage: parseInt(json['per_page']) ?? 10,
      total: parseInt(json['total']) ?? 0,
      data: json['data'] != null
          ? ReviewData.fromJson(json['data'])
          : ReviewData(),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
    'data': data.toJson(),
  };
}

class ReviewData {
  final int totalReviews;
  final String averageRating;
  final RatingsBreakdown ratingsBreakdown;
  final List<Reviews> reviews;

  ReviewData({
    int? totalReviews,
    String? averageRating,
    RatingsBreakdown? ratingsBreakdown,
    List<Reviews>? reviews,
  })  : totalReviews = totalReviews ?? 0,
        averageRating = averageRating ?? '0.0',
        ratingsBreakdown = ratingsBreakdown ?? RatingsBreakdown(),
        reviews = reviews ?? const [];

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      totalReviews: parseInt(json['total_reviews']) ?? 0,
      averageRating: parseString(json['average_rating']) ?? '0.0',
      ratingsBreakdown: json['ratings_breakdown'] != null
          ? RatingsBreakdown.fromJson(json['ratings_breakdown'])
          : RatingsBreakdown(),
      reviews: _parseReviews(json['reviews']),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_reviews': totalReviews,
    'average_rating': averageRating,
    'ratings_breakdown': ratingsBreakdown.toJson(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
  };

  static List<Reviews> _parseReviews(dynamic value) {
    if (value is! Iterable) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map(Reviews.fromJson)
        .toList();
  }
}

class RatingsBreakdown {
  final String star1;
  final String star2;
  final String star3;
  final String star4;
  final String star5;

  RatingsBreakdown({
    String? star1,
    String? star2,
    String? star3,
    String? star4,
    String? star5,
  })  : star1 = star1 ?? '0',
        star2 = star2 ?? '0',
        star3 = star3 ?? '0',
        star4 = star4 ?? '0',
        star5 = star5 ?? '0';

  factory RatingsBreakdown.fromJson(Map<String, dynamic> json) {
    return RatingsBreakdown(
      star1: parseString(json['1_star']) ?? '0',
      star2: parseString(json['2_star']) ?? '0',
      star3: parseString(json['3_star']) ?? '0',
      star4: parseString(json['4_star']) ?? '0',
      star5: parseString(json['5_star']) ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
    '1_star': star1,
    '2_star': star2,
    '3_star': star3,
    '4_star': star4,
    '5_star': star5,
  };
}

class Reviews {
  final int id;
  final int productId;
  final int rating;
  final String title;
  final String slug;
  final String comment;
  final List<String> reviewImages;
  final User user;
  final String createdAt;

  Reviews({
    int? id,
    int? productId,
    int? rating,
    String? title,
    String? slug,
    String? comment,
    List<String>? reviewImages,
    User? user,
    String? createdAt,
  })  : id = id ?? 0,
        productId = productId ?? 0,
        rating = rating ?? 0,
        title = title ?? '',
        slug = slug ?? '',
        comment = comment ?? '',
        reviewImages = reviewImages ?? const [],
        user = user ?? User(),
        createdAt = createdAt ?? '';

  factory Reviews.fromJson(Map<String, dynamic> json) {
    return Reviews(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      rating: parseInt(json['rating']) ?? 0,
      title: parseString(json['title']),
      slug: parseString(json['slug']),
      comment: parseString(json['comment']),
      reviewImages: _parseReviewImages(json['review_images']),
      user: json['user'] != null ? User.fromJson(json['user']) : User(),
      createdAt: parseString(json['created_at']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'rating': rating,
    'title': title,
    'slug': slug,
    'comment': comment,
    'review_images': reviewImages,
    'user': user.toJson(),
    'created_at': createdAt,
  };

  static List<String> _parseReviewImages(dynamic value) {
    if (value is! Iterable) return const [];
    return value.whereType<String>().where((s) => s.trim().isNotEmpty).toList();
  }
}

class User {
  final int id;
  final String name;

  User({
    int? id,
    String? name,
  })  : id = id ?? 0,
        name = name ?? '';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: parseInt(json['id']),
      name: parseString(json['name']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}