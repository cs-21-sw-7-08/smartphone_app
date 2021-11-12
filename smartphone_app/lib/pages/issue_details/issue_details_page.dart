import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/issue_details/issue_details_bloc.dart';
import 'package:smartphone_app/pages/issue_details/issue_details_events_states.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_header.dart';
import 'package:smartphone_app/widgets/custom_map_snippet.dart';
import 'package:smartphone_app/widgets/image_fullscreen_wrapper.dart';

// ignore: must_be_immutable
class IssueDetailsPage extends StatelessWidget {
  late IssueDetailsBloc bloc;
  late Issue issue;
  late MapType mapType;

  IssueDetailsPage({Key? key, required this.issue, required this.mapType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    IssueDetailsBloc bloc =
    IssueDetailsBloc(buildContext: context, issue: issue);

    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: FutureBuilder<bool>(
            future: bloc.getValues(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: custom_colors.black,
                    ),
                  ),
                );
              }
              return BlocProvider(
                  create: (_) => bloc,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(
                          child: Scaffold(
                            appBar: CustomAppBar(
                              title: AppLocalizations.of(context)!.details,
                              titleColor: Colors.white,
                              background: custom_colors.appBarBackground,
                              appBarLeftButton: AppBarLeftButton.back,
                              leftButtonPressed: () async =>
                              {Navigator.pop(context)},
                              button1Icon: bloc.state.isCreator!
                                  ? const Icon(Icons.edit_outlined,
                                  color: Colors.white)
                                  : const Icon(Icons.flag_outlined,
                                  color: Colors.white),
                              onButton1Pressed: () {},
                            ),
                            body: getContent(bloc),
                          ))));
            }));
  }

  Widget getContent(IssueDetailsBloc bloc) {
    return ClipRect(
        child: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      "assets/login_background.jpg",
                    ))),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.white.withOpacity(0.6),
                    child: BlocBuilder<IssueDetailsBloc, IssueDetailsState>(
                        builder: (context, state) {
                          return SingleChildScrollView(
                              child: Column(
                                children: [
                                  CustomHeader(
                                    title: AppLocalizations.of(context)!
                                        .location,
                                    background: custom_colors.greyGradient,
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                  ),
                                  getLocationSnippet(bloc, state),
                                  CustomHeader(
                                    title: AppLocalizations.of(context)!
                                        .category,
                                    background: custom_colors.greyGradient,
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                  ),
                                  getCategory(bloc, state),
                                  CustomHeader(
                                    title: AppLocalizations.of(context)!
                                        .description,
                                    background: custom_colors.greyGradient,
                                    margin: const EdgeInsets.all(0),
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 5, bottom: 5),
                                  ),
                                  getDescription(bloc, state)
                                ],
                              ));
                        })))));
  }

  Widget getLocationSnippet(IssueDetailsBloc bloc, IssueDetailsState state) {
    return GoogleMapSnippet(
      height: 200,
      margin: const EdgeInsets.all(10),
      mapType: state.mapType ?? MapType.normal,
      marker: state.marker,
    );
  }

  Widget getCategory(IssueDetailsBloc bloc, IssueDetailsState state) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CustomHeader(
            title: state.category ?? "",
            margin: const EdgeInsets.all(0),
          ),
          CustomHeader(
            title: state.subCategory ?? "",
            margin: const EdgeInsets.only(top: 10),
          )
        ],
      ),
    );
  }

  Widget getDescription(IssueDetailsBloc bloc, IssueDetailsState state) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (state.description != null && state.description != "")
            CustomHeader(
              title: state.description!,
              margin: const EdgeInsets.only(bottom: 15),
            ),
          GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 4,
            shrinkWrap: true,
            mainAxisSpacing: 4,
            children:
            List.generate((state.pictures ?? List.empty()).length, (index) {
              return AspectRatio(
                  aspectRatio: 1,
                  child: ImageFullScreenWrapper(child: state.pictures![index]));
            }),
          )
        ],
      ),
    );
  }
}
