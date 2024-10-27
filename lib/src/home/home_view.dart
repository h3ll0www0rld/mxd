import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/api/nmbxd.dart';
import 'package:mxd/src/widgets/thread_card.dart';
import 'package:mxd/src/widgets/thread_card_model.dart';
import '../settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = '/';

  @override
  State<HomeView> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  List<ThreadCardModel> _threads = [];
  List<Map<String, dynamic>> _forums = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _selectedForumID = 4;

  @override
  void initState() {
    super.initState();
    _fetchForumList();
    _fetchThreads();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _fetchThreads();
      }
    });
  }

  Future<void> _fetchForumList() async {
    try {
      final forumData = await fetchForumList();
      setState(() {
        _forums = forumData;
      });
    } catch (e) {
      print('Error fetching forums: $e');
    }
  }

  Future<void> _fetchThreads() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rawData = await fetchForumByFID(_selectedForumID, _currentPage);
      final List<ThreadCardModel> newThreads = rawData
          .map<ThreadCardModel>((json) => ThreadCardModel.fromJson(json))
          .toList();

      setState(() {
        _threads.addAll(newThreads);
        _currentPage++;
        _hasMoreData = newThreads.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching threads: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshThreads(int fid) async {
    _threads.clear();
    _currentPage = 1;
    _hasMoreData = true;
    _selectedForumID = fid;
    await _fetchThreads();
  }

  void _onForumSelected(int fid) {
    _refreshThreads(fid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(findForumNameByFId(_selectedForumID)),
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
                return ThreadCard(threadCardModel: _threads[index],homeViewState: this,);
              } else if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox(); // 如果没有更多数据，返回空
              }
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                AppLocalizations.of(context)!.appTitle,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ..._forums.map((forum) {
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
            }).toList(),
          ],
        ),
      ),
    );
  }

  String findForumNameByFId(int fid) {
    for (var item in _forums) {
      for (var forum in item['forums']) {
        if (forum['id'] == fid.toString()) {
          return forum['name'];
        }
      }
    }
    return "Error";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}