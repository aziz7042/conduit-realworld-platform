class ApiConstant {
  //  Github : https://github.com/gothinkster

  //  official website https://www.realworld.how/

  // static const WEBSITE_OF_THIS_APP = "https://demo.realworld.io/#/";

  /*#1*/ static const BASE_URL = "http://localhost:8081";
  /*#2*/ static const SUB_URL = "";

  /*#3*/ static const LOGIN = BASE_URL + SUB_URL + "/users/login";
  /*#4*/ static const REGISTER = BASE_URL + SUB_URL + "/users";
  /*#5*/ static const PROFILE = BASE_URL + SUB_URL + "/profiles";
  /*#6*/ static const ALL_ARTICLES = BASE_URL + SUB_URL + "/articles";
  /*#7*/ static const YOUR_FEED = BASE_URL + SUB_URL + "/articles/feed";
  /*#8*/ static const ADD_ARTICLE = BASE_URL + SUB_URL + "/articles";
  /*#9*/ static const BASE_COMMENT_URL = BASE_URL + SUB_URL + "/articles";
  /*#10*/ static const END_COMMENT_URL = "/comments";
  /*#11*/ static const MY_ARTICLES = BASE_URL + SUB_URL + "/articles?author=";
  /*#12*/ static const MY_FAVORITE_ARTICLES =
      BASE_URL + SUB_URL + "/articles?favorited=";
  /*#13*/ static const UPDATE_ARTICLE = BASE_URL + SUB_URL + "/articles";
  /*#14*/ static const GET_ARTICLE = BASE_URL + SUB_URL + "/articles";
  /*#15*/ static const UPDATE_USER = BASE_URL + SUB_URL + "/user";
  /*#16*/ static const USER_PROFILE = BASE_URL + SUB_URL + "/user";
  /*#17*/ static const LIKE_ARTICLE = BASE_URL + SUB_URL + "/articles/";
  /*#18*/ static const FOLLOW_USER = BASE_URL + SUB_URL + "/profiles/";
  /*#19*/ static const ALL_POPULAR_TAGS = BASE_URL + SUB_URL + "/tags";
  /*#20*/ static const ARTICLE_BY_TAG = BASE_URL + SUB_URL + "/articles?tag=";
  /*#21*/ static const SEARCH_QUERY = BASE_URL + SUB_URL + "/search?query=";

  //-----------------------------
  /*#22*/ static const String UPLOAD_ARTICLE_IMAGE = BASE_URL +
      "/articles"; // Basis-URL für das Hochladen von Bildern zu einem bestimmten Artikel (z. B. http://localhost:8081/articles/{slug}/images)
  //-----------------------------

  static const TOKEN =
      "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiaWdnb29zZTE4MyIsIm5iZiI6MTcxNTc4NzYyNCwiZXhwIjoxNzE1NzkxMjI0LCJpc3MiOiJ0aGVjbGllbnRpZCIsImF1ZCI6Imh0dHBzOi8vQUFBU19QTEFURk9STS9pZHAvWU9VUl9URU5BTlQvYXV0aG4vdG9rZW4ifQ.sbAL4D2aHD02NeLZPorTvhllA4lkulAMUpchM6j6nanes7ISTevjcEawJt3c8R2arEivN0-hnq69U4Osyxq410_g8FYoUwhBMkcIu50_8gUDYIY56MB3IVBkcbQ5_JTgBZY_xjIFtIfbkCm0nr8_LFob8ErGlc5cdPFWpEWnwbUSFIBI7CQMSNCBjzitv2FLY0aWXid6R4GMW6MZy7n1m9jCnrFnuJr_k0oyoC7ceRYuHkiZgxcbuqOsqDjl3md1E8bcBCMgu1SUxqf9R_SzgNqOpbkpJ3Xwfo4kHKtZpiK7AQO_GXc5Pyozj06oqE3gfYsjJ0iBwx0Dwm1uAup19A";
}

const String NO_INTERNET =
    "Conduit app is not responding to server. Check your internet connection or try again later.";
