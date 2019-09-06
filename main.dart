import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:toast/toast.dart';
import 'dart:convert';
import 'MyHelper.dart';
import 'json.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:session2_2/Movies.dart';

main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyMovie(),
    routes: {
      '/second screen': (context) => MySecondScreen(),
      '/fav':(context) =>FavScreen()
    },
  ));
}

class FavScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favourites"),
      ),
      body: GridView.count(childAspectRatio:13/15,crossAxisCount: 2,
        children: List.generate( favourites.length,(index){
          return Card(
              child: Column(children: <Widget>[
                tileBuilder(Icons.title, "Title", favourites[index].title),
                tileBuilder(Icons.poll, "Popularity", "${favourites[index].popularity}"),
                tileBuilder(Icons.date_range, "Release Date", favourites[index].releaseDate),

              ]));
        }),
      ),
    );
  }
}
List<Movies> favourites = List();


List<bool> colors = [];

class MyMovie extends StatefulWidget {
  @override
  _MyMovieState createState() => _MyMovieState();
}

class _MyMovieState extends State<MyMovie> {
  var movies;
  List res;
  var helper = MyHelper();
  fetchMovies() async {
    var response;
while(response==null) {
  try {
    response = await get(
        "https://api.themoviedb.org/3/movie/popular?api_key=d032214048c9ca94d788dcf68434f385");
  }catch(e){
    debugPrint(e.toString());
  }
}
    var parsedJson = jsonDecode(response.body);
    movies = Autogenerated.fromJson(parsedJson);
    setState(() {
      res = movies.results;
    });
  }

  @override
  void initState() {
    setState(() {
      select();
    });
    for (int i = 0; i < 20; ++i) {
      colors.add(false);
    }
    fetchMovies();
    super.initState();
    for (int i = 0; i < 20; ++i) {
      getData("$i").then((value) {
        setState(() {
          colors[i] = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: Icon(Icons.camera),
        actions: <Widget>[
          InkWell(child: Icon(Icons.star),onTap:()=>Navigator.pushNamed(context,'/fav') ,)
        ],
        title: Text(
          "MoviesLand",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body:
      movies == null?
      Container()
          : GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 12 / 16,
              children: List.generate(res.length, (index) {
                return Stack(
                  children: <Widget>[
                    Card(
                        child: InkWell(
                            onTap: () async {
                              MoviesData mv = MoviesData();
                              mv.title = res[index].originalTitle;
                              mv.overview = res[index].overview;
                              mv.popularity = res[index].popularity;
                              mv.releaseDate = res[index].releaseDate;
                              mv.id = res[index].id;

                              var response = await get(
                                  "http://api.themoviedb.org/3/movie/${mv.id}/trailers?api_key=d032214048c9ca94d788dcf68434f385");
                              Map parsedJson = jsonDecode(response.body);
                              mv.trailerId = parsedJson["youtube"][0]["source"];

                              Navigator.pushNamed(
                                  context, MySecondScreen().secondScreenRoute,
                                  arguments: mv);
                            },
                            child: Image.network(
                                "http://image.tmdb.org/t/p/w500${movies.results[index].posterPath}",
                                fit: BoxFit.fill,
                                width: 200,
                                height: 300))),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 220, 0, 0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (colors[index] == true) {
                              colors[index] = false;
                              deleteMovie(index);
                              select();
                              Toast.show("Removed From Favourites", context);

                            } else {
                              colors[index] = true;
                              insertMovie(res[index],index);
                              select();
                              Toast.show("Added To Favourites", context);
                            }
                            saveData(index);
                          });
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.favorite_border),
                          backgroundColor: colors[index] == true
                              ? Colors.yellowAccent
                              : Colors.white,
                        ),
                      ),
                    )
                  ],
                );
              }),
            ),
    );
  }

    saveData(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("$index", colors[index]);
  }

  Future<bool> getData(String boolNum) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var bool = pref.getBool(boolNum);
    return bool;
  }

  void insertMovie(Results res, int index) async {
    var n = Movies(
        index, res.title, res.popularity, res.overview, res.releaseDate);
    await helper.insertIntoTable(n);
  }

  Future select() async {

    favourites = await helper.getMovies();
  }

  void deleteMovie(int id) async {
    await helper.deleteUser(id);
  }
}

class MySecondScreen extends StatelessWidget {
  final secondScreenRoute = "/second screen";
  @override
  Widget build(BuildContext context) {
    MoviesData x = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text("Trailer"),
        ),
        body: ListView(
          children: <Widget>[
            YoutubePlayer(
              context: context,
              source: "${x.trailerId}",
              quality: YoutubeQuality.LOWEST,
              // callbackController is (optional).
              // use it to control player on your own.
            ),
            Card(
                child: Column(children: <Widget>[
              tileBuilder(Icons.title, "Title", x.title),
              tileBuilder(Icons.poll, "Popularity", "${x.popularity}"),
              tileBuilder(Icons.date_range, "Release Date", x.releaseDate),
              tileBuilder(Icons.info, "OverView", x.overview),
              Padding(
                padding: EdgeInsets.all(12),
              )
            ])),

            ///
          ],
        ));
  }
}

class MoviesData {
  String trailerId;
  int id;
  String title;
  double popularity;
  String backdropPath;
  String overview;
  String releaseDate;
}

Widget tileBuilder(IconData icon, String title, String subTitle) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subTitle),
  );
}
