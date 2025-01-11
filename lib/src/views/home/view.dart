import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/core/widgets/error_with_retry.dart';
import 'package:mxd/src/provider/forum.dart';
import 'package:mxd/src/views/home/service.dart';
import 'package:mxd/src/views/home/widgets/thread_card.dart';
import 'package:mxd/src/models/thread_card.dart';
import 'package:mxd/src/views/settings/view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/';

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  final List<ThreadCardModel> _threads = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  // 默认首页为综合线
  String _selectedForumID = 'timeline_1';
  String? _errorMessage;
  List<dynamic> _categoryForumList = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels > 0) {
      if (!_isLoading && _hasMoreData) {
        _getThreads();
      }
    }
  }

  Future<void> _initializeData() async {
    _getCategoryForumList();
  }

  // 初始化版面数据
  Future<void> _getCategoryForumList() async {
    setState(() => _isLoading = true);
    try {
      final categoryForumList =
          await HomeService().getCategoryForumList(context);

      setState(() {
        _categoryForumList = categoryForumList;
        _isLoading = false;
      });

      if (_threads.isEmpty && categoryForumList.isNotEmpty) {
        await _refreshThreads(_selectedForumID);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _getThreads() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rawData = await HomeService()
          .getThreads(_selectedForumID, _currentPage, context);

      setState(() {
        _threads.addAll(rawData);
        _currentPage++;
        _hasMoreData = rawData.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshThreads(dynamic fid) async {
    setState(() {
      _threads.clear();
      _currentPage = 1;
      _hasMoreData = true;
      _selectedForumID = fid;
    });
    await _getThreads();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 800;

        return isLargeScreen
            ? Scaffold(
                body: Row(
                  children: [
                    // 左侧 Drawer
                    SizedBox(
                      width: 250,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          DrawerHeader(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary),
                            child: Text(
                              AppLocalizations.of(context)!.appTitle,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          ..._categoryForumList.map((forum) {
                            return ExpansionTile(
                              tilePadding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              childrenPadding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              title: Text(forum['name']),
                              children: (forum['forums'] as List)
                                  .map<Widget>((subForum) {
                                return ListTile(
                                  title: Text(subForum['name']),
                                  onTap: () {
                                    _refreshThreads(subForum['id']);
                                  },
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                    ),
                    // 右侧 AppBar + 内容
                    Expanded(
                      child: Column(
                        children: [
                          AppBar(
                            title: Consumer<ForumProvider>(
                              builder: (context, forumProvider, child) {
                                return Text(forumProvider.isLoading
                                    ? AppLocalizations.of(context)!.loading
                                    : forumProvider.findForumNameByFId(
                                        _selectedForumID, context));
                              },
                            ),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.settings),
                                onPressed: () => Navigator.pushNamed(
                                    context, SettingsView.routeName),
                              ),
                            ],
                          ),
                          Expanded(
                            child: _isLoading && _threads.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : RefreshIndicator(
                                    onRefresh: () =>
                                        _refreshThreads(_selectedForumID),
                                    child: _errorMessage != null
                                        ? Center(
                                            child: ErrorWithRetryWidget(
                                                error: _errorMessage ??
                                                    AppLocalizations.of(
                                                            context)!
                                                        .unknownError,
                                                retry: _getThreads),
                                          )
                                        : ListView.builder(
                                            controller: _scrollController,
                                            itemCount: _threads.length +
                                                (_hasMoreData ? 1 : 0),
                                            itemBuilder: (context, index) {
                                              if (index < _threads.length) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12.0),
                                                  child: ThreadCard(
                                                      threadCardModel:
                                                          _threads[index]),
                                                );
                                              } else {
                                                return const Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                            },
                                          ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  title: Consumer<ForumProvider>(
                    builder: (context, forumProvider, child) {
                      return Text(forumProvider.isLoading
                          ? AppLocalizations.of(context)!.loading
                          : forumProvider.findForumNameByFId(
                              _selectedForumID, context));
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () =>
                          Navigator.pushNamed(context, SettingsView.routeName),
                    ),
                  ],
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary),
                        child: Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      ..._categoryForumList.map((forum) {
                        return ExpansionTile(
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                          childrenPadding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                          title: Text(forum['name']),
                          children:
                              (forum['forums'] as List).map<Widget>((subForum) {
                            return ListTile(
                              title: Text(subForum['name']),
                              onTap: () {
                                Navigator.pop(context);
                                _refreshThreads(subForum['id']);
                              },
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
                body: _isLoading && _threads.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => _refreshThreads(_selectedForumID),
                        child: _errorMessage != null
                            ? Center(
                                child: ErrorWithRetryWidget(
                                    error: _errorMessage ??
                                        AppLocalizations.of(context)!
                                            .unknownError,
                                    retry: _getThreads),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    _threads.length + (_hasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < _threads.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: ThreadCard(
                                          threadCardModel: _threads[index]),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                      ),
              );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
