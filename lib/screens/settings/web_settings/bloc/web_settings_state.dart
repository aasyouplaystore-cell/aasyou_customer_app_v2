import 'package:equatable/equatable.dart';
import 'package:aasyou/screens/settings/web_settings/model/web_settings_model.dart';

abstract class WebSettingsState extends Equatable {
  const WebSettingsState();

  /// Default settings used until the fetch resolves. All flags resolve to
  /// `true` via [WebSettings.isEnabled].
  WebSettings get settings => WebSettings();

  @override
  List<Object?> get props => [];
}

class WebSettingsInitial extends WebSettingsState {}

class WebSettingsLoading extends WebSettingsState {}

class WebSettingsLoaded extends WebSettingsState {
  const WebSettingsLoaded({required this.data});

  final WebSettings data;

  @override
  WebSettings get settings => data;

  @override
  List<Object?> get props => [
        data.homeTopRatedSection,
        data.homeFeaturedProductsSection,
        data.homeFeaturedSection,
        data.homeShopByCategorySection,
        data.homeFeaturedBrandsSection,
      ];
}

class WebSettingsFailed extends WebSettingsState {
  const WebSettingsFailed({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
