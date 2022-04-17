import 'package:e305/client/data/client.dart';
import 'package:e305/client/models/comment.dart';
import 'package:e305/client/models/post.dart';
import 'package:e305/interface/data/controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommentController extends DataController<Comment>
    with RefreshableDataMixin {
  final Post post;
  @override
  final RefreshController refreshController;

  CommentController({required this.post, RefreshController? refreshController})
      : refreshController = refreshController ?? RefreshController();

  @override
  Future<List<Comment>> provide(int page) => client.comments(
        post.id,
        page.toString(),
      );
}
