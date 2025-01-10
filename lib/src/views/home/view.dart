import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/provider/forum_list.dart';
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
  dynamic _selectedForumID = 'timeline_1';
  String? _errorMessage;
  List<dynamic> _forumList = [];

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
    await _getForumList();
  }

  Future<void> _getForumList() async {
    setState(() => _isLoading = true);
    try {
      final forumList = await HomeService().getForumList(context);
      setState(() {
        _forumList = forumList;
        _isLoading = false;
      });

      if (_threads.isEmpty && forumList.isNotEmpty) {
        await _refreshThreads(_selectedForumID);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching forums.';
      });
    }
  }

  Future<void> _getThreads() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final rawData = await (_selectedForumID.startsWith('timeline_')
          ? HomeService().getThreads(
              int.parse(_selectedForumID.replaceFirst('timeline_', '')),
              _currentPage,
              context,
            )
          : HomeService().getThreads(
              int.parse(_selectedForumID.toString()),
              _currentPage,
              context,
            ));

      setState(() {
        _threads.addAll(rawData);
        _currentPage++;
        _hasMoreData = rawData.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching threads.';
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
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
            return Text(forumProvider.isLoading
                ? AppLocalizations.of(context)?.loading ?? 'Loading'
                : forumProvider.findForumNameByFId(_selectedForumID));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsView.routeName),
          )
        ],
      ),
      body: _isLoading && _threads.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshThreads(_selectedForumID),
              child: _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 50),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _getThreads,
                            child: Text(
                                AppLocalizations.of(context)?.retry ?? 'Retry'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _threads.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _threads.length) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: ThreadCard(threadCardModel: _threads[index]),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
            ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                AppLocalizations.of(context)?.appTitle ?? 'App Title',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ..._forumList.map((forum) {
              return ExpansionTile(
                title: Text(forum['name']),
                children: (forum['forums'] as List).map<Widget>((subForum) {
                  return ListTile(
                    title: Text(subForum['name']),
                    onTap: () {
                      _refreshThreads(subForum['id']);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
