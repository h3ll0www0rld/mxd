// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:mxd/src/provider/forum_list.dart';
import 'package:mxd/src/views/thread/service.dart';
import 'package:mxd/src/views/thread/widgets/reply_card.dart';
import 'package:mxd/src/models/reply_card.dart';
import 'package:provider/provider.dart';

class ThreadView extends StatefulWidget {
  final int threadID;
  final int forumID;

  const ThreadView({super.key, required this.threadID, required this.forumID});

  static const routeName = '/thread';

  @override
  State<ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  final ScrollController _scrollController = ScrollController();

  final List<ReplyCardModel> _replies = [];
  ReplyCardModel? _mainReply;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  bool _errorLoadingThreads = false;

  String? forumName;
  String? _errorMessage;
  String? po_hash;

  final ThreadService _threadService = ThreadService();
  @override
  void initState() {
    super.initState();
    _initializeData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _getReplies();
      }
    });
  }

  Future<void> _initializeData() async {
    await _getReplies();
  }

  Future<void> _getReplies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorLoadingThreads = false;
    });

    try {
      final data = await _threadService.getThreadReplies(
          id: widget.threadID, page: _currentPage);
      final replies = _threadService.parseReplies(data);

      setState(() {
        if (_currentPage == 1) {
          _mainReply = _threadService.parseMainReply(data);
          po_hash = _mainReply!.user_hash;
        }

        _replies.addAll(replies);
        _currentPage++;
        _hasMoreData = replies.isNotEmpty;
        if (replies.length == 1 && replies[0].id == 9999999) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      setState(() {
        _errorLoadingThreads = true;
        _errorMessage = 'Error fetching Replies: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshReplies() async {
    setState(() {
      _replies.clear();
      _mainReply = null;
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _getReplies();
  }

  Future<void> _retryGetReplies() async {
    setState(() {
      _errorLoadingThreads = false;
    });
    await _getReplies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ForumProvider>(
          builder: (context, forumProvider, child) {
            if (forumProvider.isLoading) {
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              );
            }
            return Text(
                "NO.${widget.threadID} ${forumProvider.findForumNameByFId(widget.forumID)}");
          },
        ),
      ),
      body: _errorLoadingThreads
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage ?? 'An error occurred.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryGetReplies,
                    child: const Text('重试'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshReplies,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _replies.length +
                    (_mainReply != null ? 1 : 0) +
                    (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 && _mainReply != null) {
                    return ReplyCard(
                      replyCardModel: _mainReply!,
                      po_hash: po_hash,
                    );
                  }

                  final replyIndex = index - (_mainReply != null ? 1 : 0);
                  if (replyIndex >= 0 && replyIndex < _replies.length) {
                    return ReplyCard(
                      replyCardModel: _replies[replyIndex],
                      po_hash: po_hash,
                    );
                  }

                  if (_isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return const SizedBox();
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
