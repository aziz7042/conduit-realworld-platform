import 'package:conduit/main.dart';
import 'package:conduit/utils/AppColors.dart';
import 'package:conduit/utils/functions.dart';
import 'package:conduit/utils/image_string.dart';
import 'package:conduit/utils/message.dart';
import 'package:conduit/widget/all_article_widget.dart';
import 'package:conduit/widget/no_internet.dart';
import 'package:conduit/utils/theme_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../bloc/search_bloc/search_bloc.dart';
import '../../bloc/search_bloc/search_event.dart';
import '../../bloc/search_bloc/search_state.dart';

class SearchScreen extends StatefulWidget {
  static const searchUrl = '/search';
  SearchScreen({Key? key, required this.title}) : super(key: key);
  String? title;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late ScrollController _scrollController;
  late SearchBloc searchBloc;
  bool isNoInternet = false;
  bool isEdited = false;
  int? length;

  @override
  void initState() {
    super.initState();
    searchBloc = context.read<SearchBloc>();
    searchBloc.add(FetchSearchKWsEvent(title: widget.title!));
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
        searchBloc.add(FetchSearchMoreKWsEvent(title: widget.title!, length: await length));
      }
    });
  }



  @override
  void dispose() {
    _scrollController.dispose();
    searchBloc.close();
    super.dispose();
  }

  onRefreshAll() {
    setState(() {
      isNoInternet = false;
    });
    searchBloc.add(FetchSearchKWsEvent(title: widget.title!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        searchBloc.close(); // Close the bloc before navigating back
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            icon: SvgPicture.asset(
              ic_back_arrow_icon,
              color: AppColors.white,
            ),
          ),
          title: Text(
            widget.title!,
            style: TextStyle(
              fontFamily: ConduitFontFamily.robotoRegular,
            ),
          ),
          centerTitle: false,
        ),
        body: ThemeContainer(
          child: isNoInternet
              ? NoInternet(
                  onClickRetry: onRefreshAll,
                )
              : SafeArea(
                child: ScrollConfiguration(
                behavior: NoGlow(),
                child: RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: () {
                    return Future.delayed(Duration(seconds: 1), () {
                      onRefreshAll();
                    });
                  },
                child: SingleChildScrollView(
                  controller: _scrollController,
                    child: BlocConsumer<SearchBloc, SearchState>(
                      listener: (context, state) {
                        if (state is SearchNoInternetState) {
                          // CToast.instance.showError(context, NO_INTERNET);
                          setState(() {
                            isNoInternet = true;
                          });
                        }
                      },
                      builder: (context, state) {
                        if (state is SearchNoKWState) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/icons/empty_search.png",
                                  height: 80,
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  "No data found",
                                  style: TextStyle(
                                    color: AppColors.black,
                                    fontFamily: ConduitFontFamily.robotoBold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                        if (state is SearchKWLoadingState) {
                          return Center(
                            child: CToast.instance.showLoader(),
                          );
                        }
                        if (state is SearchKWErrorState) {
                          print(state.msg.toString());
                        }
                        if (state is SearchKWLoadedState) {
                          return ScrollConfiguration(
                            behavior: NoGlow(),
                            child: RefreshIndicator(
                              color: AppColors.primaryColor,
                              onRefresh: () {
                                return Future.delayed(Duration(seconds: 1), () {
                                  onRefreshAll();
                                });
                              },
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: ListView.separated(
                                    primary: false,
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        state.myFavoriteArticleslist.length,
                                    itemBuilder: (context, index) {
                                      if (index <
                                      state
                                          .myFavoriteArticleslist.length) {
                                        length = state
                                            .myFavoriteArticleslist.length;
                                      }
                                      return AllAirtistWidget(
                                        onRefresh: () {
                                          onRefreshAll();
                                          setState(() {
                                            isEdited = true;
                                          });
                                        },
                                        articlesModel:
                                            state.myFavoriteArticleslist[index],
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(height: 10);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
