import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/api/nmbxd.dart';
import 'package:mxd/src/provider/forum_provider.dart';
import 'package:mxd/src/widgets/thread_card.dart';
import 'package:mxd/src/widgets/thread_card_model.dart';
import 'package:provider/provider.dart';
import '../settings/settings_view.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchData().then((_) {
      _fetchThreads();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _fetchThreads();
      }
    });
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final forumFuture = fetchForumList();
      final timelineFuture = fetchTimeLineList();

      final results = await Future.wait([forumFuture, timelineFuture]);

      final forumData = results[0];
      final timelineData = results[1];

      final filteredForumData = forumData.map((category) {
        final filteredForums = (category['forums'] as List)
            .where((forum) => forum['id'] != '-1')
            .toList();

        return {
          ...category,
          'forums': filteredForums,
        };
      }).toList();

      final timelineForums = timelineData.map((timeline) {
        return {
          'id': timeline['id'].toString(),
          'name': timeline['display_name'],
          'msg': timeline['notice'] ?? '',
        };
      }).toList();

      filteredForumData.add({
        'id': '-1',
        'name': '时间线',
        'forums': timelineForums,
      });

      Provider.of<ForumProvider>(context, listen: false)
          .setForums(filteredForumData);
    } catch (e) {
      print('Error fetching forums or timeline: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchThreads() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List rawData;

      if (_selectedForumID >= 1 && _selectedForumID <= 3) {
        rawData = await fetchTimeLineByID(_selectedForumID, _currentPage);
      } else {
        rawData = await fetchForumByFID(_selectedForumID, _currentPage);
      }

      final List<ThreadCardModel> newThreads = rawData
          .map<ThreadCardModel>((json) => ThreadCardModel.fromJson(json))
          .toList();

      setState(() {
        _threads.addAll(newThreads);
        _currentPage++;
        _hasMoreData = newThreads.isNotEmpty;
      });
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _refreshThreads(int fid) async {
    _threads.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _selectedForumID = fid;
    await _fetchThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RefreshIndicator(
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
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                ...forumProvider.forums.map((forum) {
                  return ExpansionTile(
                    title: Text(forum['name']),
                    children: (forum['forums'] as List).map<Widget>((subForum) {
                      return ListTile(
                        title: Text(subForum['name']),
                        onTap: () {
                          setState(() {
                            _selectedForumID = int.parse(subForum['id']);
                            _refreshThreads(_selectedForumID); // 刷新线程
                          });
                          Navigator.pop(context); // 关闭Drawer
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
