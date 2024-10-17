import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/provider/search_provider.dart';
import 'package:provider/provider.dart';

import 'history_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    var providerTrue = Provider.of<SearchProvider>(context);
    var providerFalse = Provider.of<SearchProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            providerTrue.txtSearch.clear();
            providerTrue.webViewController!.loadUrl(
              urlRequest: URLRequest(
                url: WebUri(providerTrue.selectedEngineUrl),
              ),
            );
          },
          child: const Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
        ),
        // title: const Text('Search Engine'),
        actions: [
          PopupMenuButton<Map<String, String>>(
            color: Colors.white,
            onSelected: (Map<String, String> engine) {
              providerTrue.setSearchEngine(
                  engine['url']!); // Update the search engine URL
              providerTrue.webViewController!.loadUrl(
                urlRequest: URLRequest(
                  url: WebUri(engine['url']!),
                ),
              );
            },
            itemBuilder: (BuildContext context) {
              return providerTrue.searchEngines.map((engine) {
                return PopupMenuItem<Map<String, String>>(
                  value: engine,
                  child: Row(
                    children: [
                      Image.network(
                        engine['logo']!,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 8),
                      Text(engine['name']!),
                    ],
                  ),
                );
              }).toList();
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ), // Icon for the button
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Consumer<SearchProvider>(
                builder: (context, value, child) {
                  return TextField(
                    style: TextStyle(color: Colors.white),
                    controller: value.txtSearch,
                    cursorColor: Colors.white,
                    onSubmitted: (value) {
                      final searchUrl = providerTrue.selectedEngineUrl + value;
                      providerTrue.webViewController?.loadUrl(
                        urlRequest: URLRequest(
                          url: WebUri(searchUrl),
                        ),
                      );
                      providerFalse.addToHistory(searchUrl);
                      providerFalse.updateNavigationButtons();
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      labelText: 'Search',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (providerTrue.isLoading)
            const Center(
              child: LinearProgressIndicator(),
            ),
          Expanded(
            child: Consumer<SearchProvider>(builder: (context, value, child) {
              return InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri(value.selectedEngineUrl),
                ),
                onWebViewCreated: (controller) {
                  value.webViewController = controller;
                },
                onLoadStop: (controller, url) async {
                  if (url != null) {
                    value.setLoader(false);
                    await value.updateNavigationButtons();
                  }
                },
                onLoadStart: (controller, url) {
                  value.addToHistory(url.toString());
                  providerFalse.setLoader(true);
                },
              );
            }),
          ),
          _buildNavigationControls(providerTrue, providerFalse),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(
      SearchProvider providerTrue, SearchProvider providerFalse) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: providerTrue.canGoBack ? providerFalse.goBack : null,
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed:
                providerTrue.canGoForward ? providerFalse.goForward : null,
          ),
          IconButton(
            onPressed: () {
              providerTrue.webViewController!.reload();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
