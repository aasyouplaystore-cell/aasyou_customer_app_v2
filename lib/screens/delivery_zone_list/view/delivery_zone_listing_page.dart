import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aasyou/utils/widgets/custom_circular_progress_indicator.dart';
import 'package:aasyou/utils/widgets/custom_scaffold/custom_scaffold.dart';
import 'package:aasyou/utils/widgets/empty_states_page.dart';
import 'package:aasyou/utils/widgets/custom_refresh_indicator.dart';
import 'package:aasyou/utils/widgets/custom_textfield.dart';

import '../bloc/delivery_zone/delivery_zone_bloc.dart';
import '../widgets/delivery_zone_card.dart';

class DeliveryZoneListingPage extends StatefulWidget {
  const DeliveryZoneListingPage({super.key});

  @override
  State<DeliveryZoneListingPage> createState() =>
      _DeliveryZoneListingPageState();
}

class _DeliveryZoneListingPageState extends State<DeliveryZoneListingPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late DeliveryZoneBloc _bloc;
  Timer? _debounceTimer;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = context.read<DeliveryZoneBloc>();
    _bloc.add(FetchDeliveryZones(perPage: 15, searchQuery: ''));
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final searchQuery = _searchController.text.trim();

      if (_currentSearchQuery != searchQuery) {
        _currentSearchQuery = searchQuery;
        _performSearch(searchQuery);
      }
    });
  }

  void _performSearch(String searchQuery) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _bloc.add(FetchDeliveryZones(perPage: 15, searchQuery: searchQuery));
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _currentSearchQuery = '';
    });
    FocusScope.of(context).unfocus();
    _performSearch('');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _bloc.state is DeliveryZoneLoaded) {
      final state = _bloc.state as DeliveryZoneLoaded;
      if (!state.hasReachedMax) {
        _bloc.add(LoadMoreDeliveryZones(
          perPage: 15,
          searchQuery: _currentSearchQuery,
        ));
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        showViewCart: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text(
            'Delivery Zones',
            // AppLocalizations.of(context)?.deliveryZones ?? 'Delivery Zones', // Assuming translation not added yet
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.tertiary,
                fontSize: 16.sp),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _buildSearchBar()),
        ),
        body: CustomRefreshIndicator(
          onRefresh: () async {
            _bloc.add(FetchDeliveryZones(
              perPage: 15,
              searchQuery: _currentSearchQuery,
            ));
          },
          child: BlocBuilder<DeliveryZoneBloc, DeliveryZoneState>(
              builder: (context, state) {
            if (state is DeliveryZoneInitial || state is DeliveryZoneLoading) {
              return const CustomCircularProgressIndicator();
            }

            if (state is DeliveryZoneFailed) {
              return NoStorePage(
                onRetry: () {
                  _bloc.add(FetchDeliveryZones(
                    searchQuery: _currentSearchQuery,
                  ));
                },
              );
            }

            if (state is DeliveryZoneLoaded) {
              final deliveryZones = state.deliveryZoneData;

              if (deliveryZones.isEmpty) {
                return NoStorePage(
                  onRetry: _clearSearch,
                );
              }

              return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  controller: _scrollController,
                  itemCount:
                      deliveryZones.length + (state.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index >= deliveryZones.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CustomCircularProgressIndicator(),
                      );
                    }

                    return DeliveryZoneCard(
                      zone: deliveryZones[index],
                    );
                  });
            }

            return const SizedBox.shrink();
          }),
        ));
  }

  Widget _buildSearchBar() {
    return Container(
      height: 45,
      margin:
          const EdgeInsetsGeometry.directional(end: 12, start: 12, bottom: 12),
      child: ValueListenableBuilder(
        valueListenable: _searchController,
        builder: (context, TextEditingValue value, __) {
          return CustomTextFormField(
            controller: _searchController,
            hintText: 'Search Delivery Zone',
            prefixIcon: Icons.search,
            suffixIcon: value.text.isNotEmpty ? Icons.close : null,
            onSuffixIconTap: () {
              if (_searchController.text.isNotEmpty) {
                _clearSearch();
              }
            },
            onChanged: (value) {
              _onSearchChanged();
            },
            onFieldSubmitted: (value) {
              _debounceTimer?.cancel();
              _currentSearchQuery = value.trim();
              _performSearch(_currentSearchQuery);
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }
}
