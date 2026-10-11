import 'dart:convert';
import 'package:conduit/config/constant.dart';
import 'package:conduit/config/hive_store.dart';
import 'package:conduit/model/all_article_model.dart';
import 'package:conduit/model/comment_model.dart';
import 'package:conduit/model/new_article_model.dart';
import 'package:conduit/model/profile_model.dart';
import 'package:conduit/model/user_model.dart';
import 'package:conduit/services/user_client.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

abstract class AllArticlesRepo {
  Future<List<AllArticlesModel>> getAllArticlesData({int offset, int limit});
  Future<List<AllArticlesModel>> getYourFeedData({int offset, int limit});
  Future<List<AllArticlesModel>> getMyArticles(int offset, int limit);
  Future<bool> deleteArticle(String slug);
  Future<List<AllArticlesModel>> getMyFavoriteArticles(int offset, int limit);
  Future<dynamic> addNewArticle(ArticleModel newArticleModel);
  Future<dynamic> updateArticle(ArticleModel newArticleModel, String slug);
  Future<String> addComment(AddCommentModel addCommentModel, String slug);
  Future<List<ArticleModel>> getArticle(String slug);
  Future<List<CommentModel>> getComment(String slug);
  Future<int> deleteComment(int commentId, String slug);
  Future<List<ProfileModel>> getProfileData();
  Future<dynamic> updateProfile(ProfileModel profileModel);
  Future<dynamic> changePassword(ProfileModel profileModel);
  Future<dynamic> fetchAllTags();
  Future<dynamic> fetchSearchTags(String title);
  Future<dynamic> likeArticle(String slug);
  Future<dynamic> removeLikeArticle(String slug);
  Future<dynamic> followUser(String username);
  Future<dynamic> unFollowUser(String username);
  Future<dynamic> fetchSearchKWs(String title, int offset, int limit);
  Future<String?> uploadImage(String slug, String filePath);
}

class AllArticlesImpl extends AllArticlesRepo {
  @override
  Future<List<AllArticlesModel>> getAllArticlesData(
      {int? offset, int? limit}) async {
    String url = ApiConstant.ALL_ARTICLES + "?offset=$offset&limit=$limit";
    http.Response response = await UserClient.instance.doGet(url);
    Map<String, dynamic> jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonData["articles"];
      return List.from((data).map((e) => AllArticlesModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<AllArticlesModel>> getYourFeedData(
      {int? offset, int? limit}) async {
    String url = ApiConstant.YOUR_FEED + "?offset=$offset&limit=$limit";
    http.Response response = await UserClient.instance.doGet(url);
    Map<String, dynamic> jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonData["articles"];
      return List.from((data).map((e) => AllArticlesModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<AllArticlesModel>> getMyArticles(int offset, int limit) async {
    Box<UserAccessData>? detailModel = await hiveStore.isExistUserAccessData();
    String url = ApiConstant.MY_ARTICLES +
        "${detailModel?.values.first.userName}" +
        "&offset=$offset&limit=$limit";
    http.Response response = await UserClient.instance.doGet(url);
    Map<String, dynamic> jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonData["articles"];
      return List.from((data).map((e) => AllArticlesModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<AllArticlesModel>> getMyFavoriteArticles(
      int offset, int limit) async {
    Box<UserAccessData>? detailModel = await hiveStore.isExistUserAccessData();
    String url = ApiConstant.MY_FAVORITE_ARTICLES +
        "${detailModel?.values.first.userName}" +
        "&offset=$offset&limit=$limit";
    http.Response response = await UserClient.instance.doGet(url);
    Map<String, dynamic> jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonData["articles"];
      return List.from((data).map((e) => AllArticlesModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  Future addNewArticle(ArticleModel newArticleModel) async {
    String url = ApiConstant.ADD_ARTICLE;
    Map<String, dynamic> body = newArticleModel.toJson();
    http.Response response = await UserClient.instance.doPostArticle(url, body);
    return response.statusCode == 201
        ? response.reasonPhrase
        : throw Exception();
  }

  //Backend-Kommunikation, Daten schicken oder holen
  @override
  //--1/4------------------------------------------------
  // Ruft die vollständigen Artikeldaten (inklusive Markdown-Inhalt) von einem bestimmten Artikel aus dem Backend ab.
  Future<List<ArticleModel>> getArticle(String slug) async {
    String url = ApiConstant.GET_ARTICLE +
        "/$slug"; // Baut die vollständige URL zusammen, um den gewünschten Artikel anhand seines Slugs abzurufen
    http.Response response = await UserClient.instance.doGet(
        url); // Sendet einen GET-Request an das Backend, um die Artikeldaten abzurufen
    if (response.statusCode == 200) {
      //wenn Server mit Erfolg geantwortet hat
      return [
        ArticleModel.fromJson(json.decode(response.body))
      ]; // Wandelt die JSON-Antwort in ein Artikelobjekt um und gibt es als Liste zurück
    } else {
      throw Exception(); // Bei Fehler (z. B. Artikel nicht gefunden) wird eine Exception ausgelöst
    }
  }
  //--------------------------------------------------

  @override
  //--2/4------------------------------------------------
  // Aktualisiert die Daten eines bestehenden Artikels im Backend, inklusive Titel, Beschreibung, Inhalt (Markdown) und Tags.
  Future updateArticle(ArticleModel newArticleModel, String slug) async {
    String url = ApiConstant.UPDATE_ARTICLE +
        "/$slug"; // Baut die URL zusammen, um den spezifischen Artikel anhand seines Slugs zu aktualisieren
    Map<String, dynamic> body = newArticleModel
        .toJson(); // Wandelt das übergebene Artikelobjekt in ein JSON-Format um, um es an das Backend zu schicken
    http.Response response = await UserClient.instance.doUpdateArticle(url,
        body); // Sendet die aktualisierten Artikeldaten als PUT-Request an das Backend
    return response.statusCode == 200
        ? "Success"
        : throw Exception(); // Gibt "Success" zurück, wenn das Backend den Artikel erfolgreich gespeichert hat, sonst wird eine Exception geworfen
  }
  //--------------------------------------------------

  @override
  Future<String> addComment(
      AddCommentModel addCommentModel, String slug) async {
    String url =
        ApiConstant.BASE_COMMENT_URL + "/$slug" + ApiConstant.END_COMMENT_URL;
    http.Response response =
        await UserClient.instance.doPostComment(url, addCommentModel.toJson());
    return response.statusCode == 200 ? "Success" : throw Exception();
  }

  @override
  Future<List<CommentModel>> getComment(String slug) async {
    String url =
        ApiConstant.BASE_COMMENT_URL + "/$slug" + ApiConstant.END_COMMENT_URL;
    http.Response response = await UserClient.instance.doGet(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)["comments"];
      return List<CommentModel>.from(data.map((e) => CommentModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  Future<bool> deleteArticle(String slug) async {
    String url = ApiConstant.BASE_COMMENT_URL + "/$slug";
    http.Response response = await UserClient.instance.doDelete(url);
    return response.statusCode == 204 || response.statusCode == 200;
  }

  @override
  Future<int> deleteComment(int commentId, String slug) async {
    String url = ApiConstant.BASE_COMMENT_URL +
        "/$slug" +
        ApiConstant.END_COMMENT_URL +
        "/$commentId";
    http.Response response = await UserClient.instance.doDelete(url);
    return response.statusCode == 200 ? 1 : throw Exception();
  }

  @override
  Future<List<ProfileModel>> getProfileData() async {
    String url = ApiConstant.USER_PROFILE;
    http.Response response = await UserClient.instance.doGet(url);
    if (response.statusCode == 200) {
      return [ProfileModel.fromJson(json.decode(response.body))];
    } else {
      throw Exception();
    }
  }

  @override
  Future updateProfile(ProfileModel profileModel) async {
    String url = ApiConstant.UPDATE_USER;
    Map<String, dynamic> body = profileModel.toJson();
    http.Response response =
        await UserClient.instance.doUpdateProfile(url, body);
    return response.statusCode == 200 ? "Success" : throw Exception();
  }

  @override
  Future changePassword(ProfileModel profileModel) async {
    String url = ApiConstant.UPDATE_USER;
    Map<String, dynamic> body = profileModel.toJson();
    http.Response response =
        await UserClient.instance.doChangePassword(url, body);
    return response.statusCode == 200;
  }

  @override
  Future fetchAllTags() async {
    String url = ApiConstant.ALL_POPULAR_TAGS;
    http.Response response = await UserClient.instance.doGet(url);
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body)["tags"]);
    } else {
      throw Exception();
    }
  }

  @override
  Future fetchSearchTags(String title) async {
    String url = ApiConstant.ARTICLE_BY_TAG + title;
    http.Response response = await UserClient.instance.doGet(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)["articles"];
      return List<AllArticlesModel>.from(
          data.map((e) => AllArticlesModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  Future likeArticle(String slug) async {
    Box<UserAccessData>? detailModel = await hiveStore.isExistUserAccessData();
    String url = ApiConstant.LIKE_ARTICLE + "$slug/favorite";
    http.Response response = await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Authorization": "Token ${detailModel!.values.first.token}"
    });
    return response.statusCode == 200;
  }

  @override
  Future removeLikeArticle(String slug) async {
    String url = ApiConstant.LIKE_ARTICLE + "$slug/favorite";
    http.Response response = await UserClient.instance.doDelete(url);
    return response.statusCode == 200;
  }

  @override
  Future followUser(String username) async {
    Box<UserAccessData>? detailModel = await hiveStore.isExistUserAccessData();
    String url = ApiConstant.FOLLOW_USER + "$username/follow";
    http.Response response = await http.post(Uri.parse(url), headers: {
      "content-type": "application/json",
      "Authorization": "Token ${detailModel!.values.first.token}"
    });
    return response.statusCode == 200;
  }

  @override
  Future unFollowUser(String username) async {
    String url = ApiConstant.FOLLOW_USER + "$username/follow";
    http.Response response = await UserClient.instance.doDelete(url);
    return response.statusCode == 200;
  }

  @override
  Future fetchSearchKWs(String title, int? offset, int? limit) async {
    String url =
        ApiConstant.SEARCH_QUERY + title + "&offset=$offset&limit=$limit";
    http.Response response = await UserClient.instance.doGet(url);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)["articles"];
      return List<AllArticlesModel>.from(
          data.map((e) => AllArticlesModel.fromJson(e)));
    } else {
      throw Exception();
    }
  }

  @override
  //--3/4--------------------------------------------------------
  // Lädt ein einzelnes Bild für einen bestehenden Artikel hoch und gibt die Bild-URL zurück.
  Future<String?> uploadImage(String slug, String filePath) async {
    final file = await http.MultipartFile.fromPath('file',
        filePath); // Erstellt die Bild-Datei als MultipartFile aus dem lokalen Dateipfad
    final imageUrls = await uploadArticleImages(slug, [
      file
    ]); // Ruft die Methode auf, die den eigentlichen Upload durchführt und gibt eine Liste der Bild-URLs zurück
    return imageUrls.isNotEmpty
        ? imageUrls.first
        : null; // Gibt die erste Bild-URL zurück, falls mindestens ein Bild erfolgreich hochgeladen wurde, sonst null
  }
  //----------------------------------------------------------

  //--4/4--------------------------------------------------------
  // Führt den eigentlichen Upload-Prozess für eine oder mehrere Bilddateien zum Artikel durch und liefert die Liste der Bild-URLs vom Backend.
  Future<List<String>> uploadArticleImages(
      String slug, List<http.MultipartFile> files) async {
    final uri = Uri.parse(ApiConstant.UPLOAD_ARTICLE_IMAGE +
        "/$slug/images"); // Baut die vollständige URL zum Artikel-Bild-Upload-Endpunkt zusammen
    Box<UserAccessData>? detailModel = await hiveStore
        .isExistUserAccessData(); // Holt die gespeicherten Benutzerdaten aus Hive (insbesondere den Authentifizierungs-Token)
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] =
          'Token ${detailModel!.values.first.token}' // Fügt den Token zum Request-Header hinzu, um sich am Backend zu authentifizieren
      ..files.addAll(
          files); // Hängt die übergebenen Bilddateien an die HTTP-Anfrage an
    final response = await request
        .send(); // Sendet die vollständige Anfrage mit Header und Dateien an das Backend
    if (response.statusCode == 200) {
      // beim erfolgreichen Upload
      final responseBody = await response.stream
          .bytesToString(); // Liest den Antwort-Body als String aus dem zurückgegebenen Stream
      return List<String>.from(json.decode(responseBody)[
          'uploaded']); // Wandelt den JSON-String in ein Objekt um und extrahiert die Liste der hochgeladenen Bild-URLs
    } else {
      throw Exception(); // Falls ein anderer Statuscode zurückkommt, wird eine allgemeine Exception ausgelöst
    }
  }
  //----------------------------------------------------------
}
