
///
class Person {
  ///
  String name;
  ///
  String avatarURL;

  ///
  Person.fromMap(Map<String, dynamic> json) {
    this.name = json["name"] as String;
    if (json["avatars"] != null){
      this.avatarURL = json["avatars"]["medium"] as String;
    }

  }
}
///
class Actor extends Person {
  ///
  Actor.fromMap(Map<String, dynamic> json): super.fromMap(json);
}
///
class Director extends Person {
  ///
  Director.fromMap(Map<String, dynamic> json): super.fromMap(json);
}


/// 电影item
class MovieItem {
  /// 排名
  int rank;
  String imageURL;
  String title;
  String playDate;
  double rating;
  List<String> genres;
  List<Actor> casts;
  Director director;
  String originalTitle;

  MovieItem.fromMap(Map<String, dynamic> json) {
    this.rank = json['rank'] as int;

    Map<String,dynamic> subject = json['subject'] as Map<String,dynamic>;

    this.imageURL = subject["images"]["medium"] as String;
    this.title = subject["title"] as String;
    this.playDate = subject["year"] as String;
    this.rating = subject["rating"]["average"] as double;
    this.genres = subject["genres"].cast<String>()  as List<String>;
    this.casts = (subject["casts"] as List<dynamic>).map((item) {
      return Actor.fromMap(item as Map<String,dynamic>);
    }).toList();
    this.director = Director.fromMap(subject["directors"][0]as Map<String,dynamic>);
    this.originalTitle = subject["original_title"] as String;
  }

  @override
  String toString() {
    return 'MovieItem{rank: $rank, imageURL: $imageURL, title: $title, playDate: $playDate, rating: $rating, genres: $genres, casts: $casts, director: $director, originalTitle: $originalTitle}';
  }
}