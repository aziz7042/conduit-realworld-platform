import 'package:conduit/model/all_article_model.dart';
import 'package:conduit/model/all_tags_model.dart';
import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {}

// all tags

class SearchInitialState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchLoadingState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchNoInternetState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchNoKWState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchErrorState extends SearchState {
  String msg;
  SearchErrorState({required this.msg});
  @override
  List<Object?> get props => [msg];
}

// search tag

class SearchKWLoadingState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchKWLoadedState extends SearchState {
  List<AllArticlesModel> myFavoriteArticleslist;
  bool hasReachedMax;

  SearchKWLoadedState(
      {this.hasReachedMax = true, required this.myFavoriteArticleslist});
  @override
  List<Object?> get props => [this.myFavoriteArticleslist, hasReachedMax];
}

class SearchKWNoInternetState extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchNoSearchtate extends SearchState {
  @override
  List<Object?> get props => [];
}

class SearchKWSuccessState extends SearchState {
  List<AllArticlesModel> myFavoriteArticleslist;
  bool? hasReachedMax;
  SearchKWSuccessState(
      {required this.myFavoriteArticleslist, this.hasReachedMax});
  @override
  List<Object?> get props => [myFavoriteArticleslist, hasReachedMax];
}

class SearchKWErrorState extends SearchState {
  String msg;
  SearchKWErrorState({required this.msg});
  @override
  List<Object?> get props => [msg];
}
