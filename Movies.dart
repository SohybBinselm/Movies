class Movies {
  int id;
  String title;
  double popularity;
  String overview;
  String releaseDate;


  Movies(this.id,this.title,this.popularity,this.overview,this.releaseDate);

  Movies.ConvertFromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    popularity = map['popularity'];
    overview = map['overview'];
    releaseDate = map['releasedate'];
  }

  Map<String, dynamic> ConvertToMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['title'] = title;
    map['popularity'] = popularity;
    map['overview'] = overview;
    map['releasedate'] = releaseDate;
    return map;
  }

  @override
  String toString() {
    return 'Movie{title: $title}';
  }
}
