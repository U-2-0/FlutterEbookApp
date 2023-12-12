import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreenSmall extends StatefulWidget {
  const SettingsScreenSmall({Key? key}) : super(key: key);

  @override
  State<SettingsScreenSmall> createState() => _SettingsScreenSmallState();
}

class _SettingsScreenSmallState extends State<SettingsScreenSmall> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    items = [
      {
        'icon': Feather.heart,
        'title': 'Favorites',
        'function': () => _pushPage(const FavoritesRoute()),
      },
      {
        'icon': Feather.download,
        'title': 'Downloads',
        'function': () => _pushPage(const DownloadsRoute()),
      },
      {
        'icon': Feather.moon,
        'title': 'Dark Mode',
        'function': null,
      },
      {
        'icon': Feather.info,
        'title': 'About',
        'function': () => showAbout(),
      },
      {
        'icon': Feather.file_text,
        'title': 'Open Source Licenses',
        'function': () => _pushPage(const LicensesRoute()),
      },
      {
        'icon': Feather.bookmark,
        'title': 'Bookmark',
        'function': () => toggleBookmark(),
      },
    ];

    filteredItems = List.from(items);

    _scrollController.addListener(() {
      setState(() {
        _progress = _scrollController.position.pixels /
            _scrollController.position.maxScrollExtent;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _DataSearch(filteredItems),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!context.isSmallScreen) const SizedBox(height: 30),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shrinkWrap: true,
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredItems.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  onTap: filteredItems[index]['function'] as Function(),
                  leading: Icon(filteredItems[index]['icon'] as IconData),
                  title: Text(
                    filteredItems[index]['title'] as String,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1, // Customize the font style
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pushPage(PageRouteInfo route) {
    if (context.isLargeScreen) {
      context.router.replace(route);
    } else {
      context.router.push(route);
    }
  }

  Future<void> showAbout() async {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('About'),
          content: const Text(
            'OpenLeaf is a Simple ebook app by JideGuru using Flutter',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  color: context.theme.colorScheme.secondary,
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void toggleBookmark() {
    // Implement your bookmarking logic here
    // You can store the bookmarked state in a state management solution like Riverpod
    // Or in a database to persist the bookmark state
  }
}

class _DataSearch extends SearchDelegate<String> {
  final List<Map<String, dynamic>> data;

  _DataSearch(this.data);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement your search results here
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement your search suggestions here
    final suggestionList = query.isEmpty
        ? data
        : data
            .where((item) =>
                item['title'].toString().toLowerCase().contains(query))
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(
          suggestionList[index]['title'].toString(),
          style:
              Theme.of(context).textTheme.bodyText1, // Customize the font style
        ),
        onTap: () {
          // You can implement a specific action when an item is tapped
          close(context, null);
        },
      ),
    );
  }
}

class _ThemeSwitch extends ConsumerWidget {
  final IconData icon;
  final String title;

  const _ThemeSwitch({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeProvider);
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: themeProvider.isDarkMode,
      onChanged: (isDarkMode) {
        ref.read(themeProvider.notifier).toggleDarkMode();
      },
    );
  }
}
