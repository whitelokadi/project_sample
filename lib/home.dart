import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_sample/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? data;
  String searchText = '';
  List<dynamic> filteredProducts = [];
  List<dynamic> filteredcategory = [];
  List<dynamic> filteredupcomingLaptops = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var url = 'http://devapiv4.dealsdray.com/api/v2/user/home/withoutPrice';
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(response.body);
        }

        setState(() {
          data = json.decode(response.body);
          filteredProducts =
              data!['data']['products']; // Initialize filtered products
        });
      } else {
        EasyLoading.showError('Failed to load data');
        if (kDebugMode) {
          print('Failed to load data');
        }
      }
    } catch (e) {
      EasyLoading.showError('Failed to load data');
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _searchchanged(String value) {
    setState(() {
      searchText = value;
      _filterProducts();
    });
  }

  void _filterProducts() {
    if (searchText.isEmpty) {
      setState(() {
        filteredProducts = data?['data']['products'] ?? [];
      });
    } else {
      setState(() {
        filteredProducts = data?['data']['products']
            .where((product) =>
                product['label']
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                (product['SubLabel'] ?? product['Sublabel'] ?? '')
                    .toLowerCase()
                    .contains(searchText.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<dynamic> banners = data!['data']['banner_one'] ?? [];
    final List<dynamic> categories = data!['data']['category'] ?? [];
    final List<dynamic> featuredLaptops =
        data!['data']['featured_laptop'] ?? [];
    final List<dynamic> upcomingLaptops =
        data!['data']['upcoming_laptops'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40.0,
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              _searchchanged(value);
            },
            decoration: InputDecoration(
              hintText: 'Search here',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  // Optionally clear the search field
                  _searchController.clear();
                  _filterProducts();
                },
                icon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              size: 32.0,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banners
            if (banners.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: banners[index]['banner'],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ],
            // Categories
            if (categories.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Categories',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: categories[index]['icon'],
                          width: 80,
                          height: 80,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        Text(categories[index]['label']),
                      ],
                    );
                  },
                ),
              ),
            ],
            // Filtered Products
            if (filteredProducts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Products',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: filteredProducts[index]['icon'],
                            width: 100,
                            height: 100,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          Text(filteredProducts[index]['label']),
                          Text(filteredProducts[index]['SubLabel'] ??
                              filteredProducts[index]['Sublabel']),
                          Text(filteredProducts[index]['offer']),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            // Featured Laptops
            if (featuredLaptops.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Featured Laptops',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredLaptops.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: featuredLaptops[index]['icon'],
                            width: 100,
                            height: 100,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          CachedNetworkImage(
                            imageUrl: featuredLaptops[index]['brandIcon'],
                            width: 50,
                            height: 50,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                          Text(featuredLaptops[index]['label']),
                          Text('Price: ${featuredLaptops[index]['price']}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            // Upcoming Laptops
            if (upcomingLaptops.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Upcoming Laptops',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcomingLaptops.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: upcomingLaptops[index]['icon'],
                      width: 200,
                      height: 200,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavigationBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 130, 236, 236)),
              child: UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text('S'),
                ),
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 58, 211, 242)),
                accountName: Text("Sduharsan Ganesh"),
                accountEmail: Text('sudharsan@gmail.com'),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.blue,
                size: 15.0,
              ),
              title: const Text(
                "LogOut",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15.0,
                ),
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const LoginScreen();
                }));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.elliptical(12, 12),
          topRight: Radius.elliptical(12, 12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home),
              ),
              const Text('Home'),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.category),
              ),
              const Text('Categories'),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.local_offer_outlined),
              ),
              const Text('Deals'),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart),
              ),
              const Text('Cart'),
            ],
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person),
              ),
              const Text('Profile'),
            ],
          ),
        ],
      ),
    );
  }
}
