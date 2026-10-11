import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable { }

class FetchSearchKWsEvent extends SearchEvent {
  String title;
  FetchSearchKWsEvent({required this.title});
  @override
  List<Object?> get props => [title];
}

class FetchSearchMoreKWsEvent extends SearchEvent {
  String title;
  int? length;
  FetchSearchMoreKWsEvent({required this.title, required this.length});
  @override
  List<Object?> get props => [title, length];
}
