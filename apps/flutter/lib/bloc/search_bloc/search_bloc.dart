import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:conduit/bloc/search_bloc/search_event.dart';
import 'package:conduit/bloc/search_bloc/search_state.dart';
import 'package:conduit/model/all_article_model.dart';
import 'package:conduit/repository/all_article_repo.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  AllArticlesRepo repo;
  int offset = 0;
  final int limit = 10;
  SearchBloc({required this.repo}) : super(SearchInitialState()) {
    on<FetchSearchKWsEvent>(_onFetchSearchKW);
    on<FetchSearchMoreKWsEvent>(_onFetchSearchKW);
  }

  void _onFetchSearchKW(
      SearchEvent event, Emitter<SearchState> emit) async {
    try {
        if (event is FetchSearchMoreKWsEvent) {
          print(" The Length is ${event.length!.toInt()}");
          offset = event.length!.toInt();
        }
        else {
          offset = 0;
        }
        if( offset==0 ){
          emit(SearchKWLoadingState());
        }

        List<AllArticlesModel> data = await repo.fetchSearchKWs(
            event.props[0]!.toString(), offset, limit);
        if (state.props.length+data.length == 0) {
          emit(SearchNoKWState());
        } else {
          bool hasReachedMax = data.length < 10;

          if (event is FetchSearchMoreKWsEvent) {
            final currentState = state;
            if (currentState is SearchKWLoadedState) {
              data = [...currentState.myFavoriteArticleslist, ...data];
            }
          }
          emit(
            SearchKWLoadedState(
                myFavoriteArticleslist: data, hasReachedMax: hasReachedMax),
          );
        }
    } on SocketException {
      emit(SearchKWNoInternetState());
    } catch (e) {
      print(e.toString());
      emit(SearchKWErrorState(msg: e.toString()));
    }
  }
}
