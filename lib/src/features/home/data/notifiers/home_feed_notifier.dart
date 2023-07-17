import 'package:flutter_ebook_app/src/features/common/data/models/category_feed.dart';
import 'package:flutter_ebook_app/src/features/home/data/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_feed_notifier.g.dart';

typedef HomeFeedData = ({CategoryFeed popularFeed, CategoryFeed recentFeed});

@riverpod
class HomeFeedNotifier extends _$HomeFeedNotifier {
  HomeFeedNotifier() : super();

  @override
  Future<HomeFeedData> build() async {
    state = const AsyncValue.loading();
    return await _fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _fetch());
  }

  Future<HomeFeedData> _fetch() async {
    HomeRepository _homeRepository = ref.read(homeRepositoryProvider);
    final popularFeedSuccessOrFailure =
        await _homeRepository.getPopularHomeFeed();
    final recentFeedSuccessOrFailure =
        await _homeRepository.getRecentHomeFeed();
    CategoryFeed? popularFeed = popularFeedSuccessOrFailure.feed;
    CategoryFeed? recentFeed = recentFeedSuccessOrFailure.feed;
    if (popularFeed == null) {
      throw (popularFeedSuccessOrFailure.failure!.description);
    }

    if (recentFeed == null) {
      throw (recentFeedSuccessOrFailure.failure!.description);
    }
    return (popularFeed: popularFeed, recentFeed: recentFeed);
  }
}
