import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/provider/search_provider.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var providerTrue = Provider.of<SearchProvider>(context, listen: true);
    var providerFalse = Provider.of<SearchProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'History',
        ),
        actions: [
          IconButton(
            onPressed: () {
              providerTrue.clearHistory();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: providerTrue.history.length,
        itemBuilder: (context, index) {
          final url = providerTrue.history[index];
          return ListTile(
            title: Text(url),
            onTap: () {
              providerTrue.webViewController!.loadUrl(
                urlRequest: URLRequest(
                  url: WebUri(url),
                ),
              );
              providerFalse.addUrlToController(url);
              Navigator.pop(context);
            },
            trailing:
                Consumer<SearchProvider>(builder: (context, value, child) {
              return IconButton(
                onPressed: () {
                  value.deleteHistory(index);
                },
                icon: const Icon(
                  Icons.delete_outlined,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
