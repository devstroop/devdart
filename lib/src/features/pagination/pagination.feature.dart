import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaginationFeature<T> extends StatefulWidget {
  const PaginationFeature({
    Key? key,
    required this.pageSize,
    required this.currentPage,
    required this.itemBuilder,
    this.fetchAsync,
    this.fetchSync,
    // this.footer,
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
  State<PaginationFeature<T>> createState() => PaginationFeatureState<T>();
}

class PaginationFeatureState<T> extends State<PaginationFeature<T>> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (widget.fetchAsync != null) {
          return buildListView(
            widget.fetchAsync!(widget.pageSize, widget.currentPage),
          );
        } else if (widget.fetchSync != null) {
          return buildListView(
            Future.value(
                widget.fetchSync!(widget.pageSize, widget.currentPage)),
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
        return const LinearProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }
        if (snapshot.hasData) {
          // column with footer widget, contains next page button, prev page button, and page number, footer widget must be inside column
          return Column(
            children: [
              ...snapshot.data!
                  .map(
                    (e) => Container(
                      margin: widget.inBetweenMargin,
                      child: widget.itemBuilder(
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
                    IconButton(
                      onPressed: () => setState(() =>
                          widget.onPageChanged?.call(widget.currentPage - 1)),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Text('Page ${widget.currentPage + 1}'),
                    IconButton(
                      onPressed: () => setState(() {
                        widget.onPageChanged?.call(widget.currentPage + 1);
                      }),
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              )
            ],
          );
          // return widget.separatorBuilder != null
          //     ? ListView.separated(
          //         controller: widget.controller,
          //         padding: widget.padding,
          //         itemCount: snapshot.data!.length,
          //         itemBuilder: (context, index) =>
          //             widget.itemBuilder(context, snapshot.data![index], index),
          //         separatorBuilder: widget.separatorBuilder!,
          //       )
          //     : ListView.builder(
          //         controller: widget.controller,
          //         padding: widget.padding,
          //         itemCount: snapshot.data!.length,
          //         itemBuilder: (context, index) =>
          //             widget.itemBuilder(context, snapshot.data![index], index),
          //       );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Future<void> refresh() async {
    setState(() {});
  }
}
