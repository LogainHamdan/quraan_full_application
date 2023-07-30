import 'package:flutter/material.dart';
import 'package:quraan_full_application/network.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Network network = Network();
  int pageNumber = 1;
  List<dynamic> ayahs = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;

  void getData() async {
    Map<String, dynamic> pageData = await network.fetchData(pageNumber);
    setState(() {
      ayahs = pageData['data']['ayahs'];
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void searchAyah(String search) {
    setState(() {
      if (search.isNotEmpty) {
        isSearching = true;
        ayahs = ayahs.where((ayah) {
          return ayah['text'].toString().toLowerCase().contains(search
              .toLowerCase()); //the filtering process depending on the search bar text, and update the list ayahs
        }).toList();
      } else {
        isSearching = false;
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0x4DFFD83B),
        title: Center(
          child: isSearching
              ? TextField(
                  controller: _searchController,
                  onChanged: searchAyah,
                  decoration: const InputDecoration(
                    hintText: 'Search Ayah...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                )
              : const Text(
                  'Quran App',
                  style: TextStyle(
                      color: Color(0x6F000000),
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
        ),
        actions: [
          isSearching
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    searchAyah('');
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0x6F000000),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = true;
                    });
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Color(0x6F000000),
                    size: 35,
                  ),
                ),
        ],
      ),
      body: SafeArea(
        child: isSearching
            ? ListView.builder(
                itemCount: ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = ayahs[index];
                  return ListTile(
                    title: Text(ayah['text']),
                    subtitle: Text('${ayah['numberInSurah']}'),
                    onTap: () {
                      // Navigate to the page containing the selected ayah
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AyahPage(ayah),
                        ),
                      );
                    },
                  );
                },
              )
            : PageView.builder(
                itemBuilder: (context, index) {
                  pageNumber = index + 1;
                  getData();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (int i = 0; i < ayahs.length; i++) ...{
                            TextSpan(text: '${ayahs[i]['text']}'),
                            WidgetSpan(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('images/Ayah.png'),
                                  ),
                                ),
                                child: Text(
                                  '${ayahs[i]['numberInSurah']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                          }
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AyahPage extends StatelessWidget {
  final dynamic ayah;

  AyahPage(this.ayah);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${ayah['text']}'),
      ),
      body: Center(
        child: Text(
          '${ayah['text']}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
