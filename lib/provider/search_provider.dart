import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/modal/search_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider with ChangeNotifier {
  List<String> history = []; // to store history
  // webView Controller to controller on the web
  InAppWebViewController? webViewController;

  // to store the can user go back/forward
  bool canGoBack = false;
  bool canGoForward = false;

  // search controller
  var txtSearch = TextEditingController();

  // is the url is loading or not
  bool isLoading = false;

  // setting the url is loaded or not
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

// https://in.search.yahoo.com/search?q=flutter
// https://duckduckgo.com/?t=h_&q=flutter&ia=web
// https://yandex.com/search/?text=flutter&lr=10555
// https://www.bing.com/search?q=flutter

  // Search engine options
  List<Map<String, String>> searchEngines = [
    {
      'name': 'Google',
      'url': 'https://www.google.com/search?q=',
      'logo':
          'https://www.pngplay.com/wp-content/uploads/13/Google-Logo-PNG-Photo-Image.png',
    },
    {
      'name': 'Yandex',
      'url': 'https://yandex.com/search/?text=',
      'logo': 'https://pngimg.com/d/yandex_PNG20.png',
    },
    {
      'name': 'Bing',
      'url': 'https://www.bing.com/search?q=',
      'logo':
          'https://www.logodesignlove.com/images/evolution/old-bing-logo-01.jpg',
    },
    {
      'name': 'DuckDuckGo',
      'url': 'https://duckduckgo.com/?q=',
      'logo':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQHsuwQaMWi8wu7v5yci7aVVg2nRLgRqco49w&s',
    },
    {
      'name': 'Yahoo',
      'url': 'https://search.yahoo.com/search?p=',
      'logo':
          'https://s.yimg.com/ny/api/res/1.2/vlvd6fw1UHI9T_3GaNPzDw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyMDA7aD02OTI-/https://s.yimg.com/os/creatr-uploaded-images/2019-09/a929b8f0-dd65-11e9-bffe-b90463fd5188',
    },
  ];

  // making list of object for code simplicity
  List<SearchModal> searchEngineList = [];

  void makeListOfObject() {
    for (int i = 0; i < searchEngines.length; i++) {
      SearchModal searchEngineModal = SearchModal.fromMap(searchEngines[i]);
      searchEngineList.add(searchEngineModal);
    }
  }

  String selectedEngineUrl = 'https://www.google.com/search?q=';

  // Set a new search engine
  void setSearchEngine(String url) {
    selectedEngineUrl = url;
    notifyListeners();
  }

  // Loading history from SharedPreferences
  Future<void> loadHistory() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    history = sharedPreferences.getStringList('history') ?? [];
    notifyListeners();
  }

  // Save a visited URL to history from SharedPreferences
  Future<void> addToHistory(String url) async {
    if (!history.contains(url)) {
      history.add(url);
    }
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList('history', history);
    notifyListeners();
  }

  // deleting history
  Future<void> deleteHistory(int index) async {
    history.removeAt(index);
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList('history', history);
    notifyListeners();
  }

  // Clear the entire history
  Future<void> clearHistory() async {
    history.clear();
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('history');
    notifyListeners();
  }

  // Check if back/forward navigation is possible
  Future<void> updateNavigationButtons() async {
    if (webViewController != null) {
      canGoBack = await webViewController!.canGoBack();
      canGoForward = await webViewController!.canGoForward();
      notifyListeners();
    }
  }

  // Navigate back
  Future<void> goBack() async {
    if (canGoBack) {
      await webViewController?.goBack();
      await updateNavigationButtons();
    }
  }

  // Navigate forward
  Future<void> goForward() async {
    if (canGoForward) {
      await webViewController?.goForward();
      await updateNavigationButtons();
    }
  }

  // adding url to controller when it goes from history
  void addUrlToController(String url) {
    txtSearch.text = url;
    notifyListeners();
  }

  searchEngineProvider() {
    makeListOfObject();
    loadHistory();
  }
}
