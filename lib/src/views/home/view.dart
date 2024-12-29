import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/provider/forum_list.dart';
import 'package:mxd/src/views/home/service.dart';
import 'package:mxd/src/views/home/widgets/thread_card.dart';
import 'package:mxd/src/models/thread_card.dart';
import 'package:provider/provider.dart';
import '../settings/view.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  static const routeName = '/';

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  final List<ThreadCardModel> _threads = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _selectedForumID = 1;
  bool _errorLoadingThreads = false;
  String? _errorMessage;

  final HomeService _homeService = HomeService();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initializeData() async {
    await _getForumList();
    await _getThreads();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMoreData) {
      _getThreads();
    }
  }

  Future<void> _getForumList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final forumData = await _homeService.getForumList(context);

      Provider.of<ForumProvider>(context, listen: false).setForums(forumData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching forums: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getThreads() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorLoadingThreads = false;
    });

    try {
      final data = await _homeService.getThreads(
          _selectedForumID, _currentPage, context);

      setState(() {
        _threads.addAll(data);
        _currentPage++;
        _hasMoreData = data.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _errorLoadingThreads = true;
        _errorMessage = 'Error fetching threads: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshThreads(int fid) async {
    setState(() {
      _threads.clear();
      _currentPage = 1;
      _hasMoreData = true;
      _selectedForumID = fid;
    });
    await _getThreads();
  }

  Future<void> _retryGetThreads() async {
    setState(() {
      _errorLoadingThreads = false;
    });
    await _getThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
            if (forumProvider.isLoading) {
              return Text(AppLocalizations.of(context)!.loading);
            }
            return Text(forumProvider.findForumNameByFId(_selectedForumID));
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, SettingsView.routeName);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _errorLoadingThreads
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    Text(
                      _errorMessage ?? 'An error occurred.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryGetThreads,
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshThreads(_selectedForumID),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _threads.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _threads.length) {
                      return ThreadCard(threadCardModel: _threads[index]);
                    } else if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
      ),
      drawer: Consumer<ForumProvider>(
        builder: (context, forumProvider, child) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge!.fontSize),
                  ),
                ),
                ...forumProvider.forums.map((forum) {
                  return ExpansionTile(
                    title: Text(forum['name']),
                    children: (forum['forums'] as List).map<Widget>((subForum) {
                      return ListTile(
                        title: Text(
                          subForum['name'],
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .fontSize,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedForumID = int.parse(subForum['id']);
                            _refreshThreads(_selectedForumID);
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
