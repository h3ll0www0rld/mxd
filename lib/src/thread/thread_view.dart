import 'package:flutter/material.dart';

import 'package:mxd/src/api/nmbxd.dart';
import 'package:mxd/src/provider/forum_provider.dart';
import 'package:mxd/src/widgets/reply_card.dart';
import 'package:mxd/src/widgets/reply_card_model.dart';
import 'package:provider/provider.dart';

class ThreadView extends StatefulWidget {
  final int threadID;

  const ThreadView({super.key, required this.threadID});

  static const routeName = '/thread';

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final ScrollController _scrollController = ScrollController();

  List<ReplyCardModel> _replies = [];
  ReplyCardModel? _mainReply;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? forumName;

  String? po_hash;

  @override
  void initState() {
    super.initState();

    _fetchReplies();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _fetchReplies();
      }
    });
  }

  Future<void> _fetchReplies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await fetchThreadRepliesByID(widget.threadID, _currentPage);
      if (_mainReply == null) {
        _mainReply = ReplyCardModel.fromJson(data);
        po_hash = _mainReply!.user_hash;

        setState(() {
          print(_mainReply!.id);
          forumName = Provider.of<ForumProvider>(context, listen: false)
              .findForumNameByFId(_mainReply!.id); // 假设你有 forumId 字段
        });
      }

      final replies = (data['Replies'] as List)
          .map((json) => ReplyCardModel.fromJson(json))
          .toList();
      if (!(replies.length == 1 && replies[0].id == 9999999)) {
        setState(() {
          _replies.addAll(replies);
          _currentPage++;
          if (replies.isEmpty) {
            _hasMoreData = false;
          }
        });
      }
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

  Future<void> _refreshReplies() async {
    _replies.clear();
    _mainReply = null;
    _currentPage = 1;
    _hasMoreData = true;
    await _fetchReplies();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount =
        _replies.length + (_mainReply != null ? 1 : 0) + (_isLoading ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: _mainReply == null
            ? CircularProgressIndicator()
            : forumName == null
                ? CircularProgressIndicator() // 如果 forumName 还未加载，显示加载指示器
                : Text("NO.${widget.threadID} $forumName"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReplies,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            try {
              if (index == 0 && _mainReply != null) {
                return ReplyCard(
                  replyCardModel: _mainReply!,
                  po_hash: po_hash,
                );
              } else if (index < _replies.length + 1) {
                return ReplyCard(
                    replyCardModel: _replies[index - 1], po_hash: po_hash);
              } else if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox();
              }
            } catch (e) {
              print("Error in ListView: $e");
              return SizedBox();
            }
          },
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
