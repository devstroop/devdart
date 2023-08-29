import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaginationFeature<T> extends StatelessWidget {
  const PaginationFeature({
    Key? key,
    required this.pageSize,
    required this.currentPage,
    required this.itemBuilder,
    this.fetchAsync,
    this.fetchSync,
    this.separator,
    this.padding,
    this.onPageChanged,
    this.inBetweenMargin,
  }) : super(key: key);

  final int pageSize;
  final int currentPage;
  final Future<List<T>> Function(int pageSize, int currentPage)? fetchAsync;
  final List<T> Function(int pageSize, int currentPage)? fetchSync;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final EdgeInsets? inBetweenMargin;
  final Widget? separator;
  final EdgeInsets? padding;
  final Function(int)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (fetchAsync != null) {
          return buildListView(
            fetchAsync!(pageSize, currentPage),
          );
        } else if (fetchSync != null) {
          return buildListView(
            Future.value(fetchSync!(pageSize, currentPage)),
          );
        } else {
          return const Center(
              child: Text('⚠️ Warning: No data source provided!'));
        }
      },
    );
  }

  Widget buildListView(Future<List<T>> data) {
    return FutureBuilder<List<T>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              alignment: Alignment.center,
              child: const CupertinoActivityIndicator());
        }
        List<T> data = snapshot.data ?? [];
        return Column(
          children: [
            ...data
                .map(
                  (e) => Container(
                    margin: inBetweenMargin,
                    child: itemBuilder(
                      context,
                      e,
                      snapshot.data!.indexOf(e),
                    ),
                  ),
                )
                .toList(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (currentPage > 0)
                    IconButton(
                      onPressed: () => onPageChanged?.call(currentPage - 1),
                      icon: const Icon(Icons.arrow_back_ios),
                    )
                  else
                    const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                  Text('Page ${currentPage + 1}'),
                  if (!snapshot.hasError)
                    IconButton(
                      onPressed: () => onPageChanged?.call(currentPage + 1),
                      icon: const Icon(Icons.arrow_forward_ios),
                    )
                  else
                    const IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_forward_ios),
                    )
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
