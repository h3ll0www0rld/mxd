import 'package:flutter/material.dart';

import 'package:mxd/src/api/nmbxd.dart';
import 'package:mxd/src/widgets/reply_card.dart';
import 'package:mxd/src/widgets/reply_card_model.dart';

class ThreadView extends StatefulWidget {
  final int threadID;
  final String forumName;

  const ThreadView(
      {super.key,
      required this.threadID,
      required this.forumName});

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
      }

      final replies = (data['Replies'] as List)
          .map((json) => ReplyCardModel.fromJson(json))
          .toList();
      if (!(replies.length == 1 && replies[0].id == 9999999)) {
        setState(() {
          _replies.addAll(replies); // 仅在条件不满足时更新回复列表
          _currentPage++; // 更新当前页
          if (replies.isEmpty) {
            _hasMoreData = false; // 如果没有新数据，设置为false
          }
        });
      }
    } catch (e) {
      // 处理错误
      print('Error fetching replies: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        title: Text("NO.${widget.threadID} ${widget.forumName}"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReplies,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: itemCount, // 增加一个位置用于加载指示器
          itemBuilder: (context, index) {
            try {
              if (index == 0 && _mainReply != null) {
                return ReplyCard(
                  replyCardModel: _mainReply!,
                  po_hash: po_hash,
                ); // 显示主回复
              } else if (index < _replies.length + 1) {
                return ReplyCard(
                    replyCardModel: _replies[index - 1],
                    po_hash: po_hash); // 显示回复列表
              } else if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox(); // 如果没有更多数据，返回空
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
