import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/pages/create_issue/create_issue_events_states.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_header.dart';
import 'package:smartphone_app/widgets/custom_map_snippet.dart';
import 'package:smartphone_app/widgets/custom_text_field.dart';
import 'package:smartphone_app/widgets/image_fullscreen_wrapper.dart';
import 'package:smartphone_app/values/values.dart' as values;

import 'create_issue_bloc.dart';

// ignore: must_be_immutable
class CreateIssuePage extends StatelessWidget {
  late CreateIssueBloc bloc;
  late Issue? issue;
  late MapType mapType;

  CreateIssuePage({Key? key, this.issue, required this.mapType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CreateIssueBloc bloc =
        CreateIssueBloc(buildContext: context, mapType: mapType, issue: issue);

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
                          child: Container(
                              constraints: const BoxConstraints.expand(),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: ExactAssetImage(
                                      values.createIssueBackground,
                                    )),
                              ),
                              child: Scaffold(
                                backgroundColor: Colors.transparent,
                                appBar: CustomAppBar(
                                  title: AppLocalizations.of(context)!.details,
                                  titleColor: Colors.white,
                                  background: custom_colors.appBarBackground,
                                  appBarLeftButton: AppBarLeftButton.back,
                                  leftButtonPressed: () =>
                                      Navigator.pop(context),
                                  onButton1Pressed: () {},
                                  button1Icon: Icon(
                                      bloc.state.createIssuePageView! ==
                                              CreateIssuePageView.create
                                          ? Icons.send_outlined
                                          : Icons.check,
                                      color: Colors.white),
                                ),
                                body: getContent(bloc),
                              )))));
            }));
  }

  Widget getContent(CreateIssueBloc bloc) {
    return ClipRect(
        child: Container(
            constraints: const BoxConstraints.expand(),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.white.withOpacity(0.6),
                    child: BlocBuilder<CreateIssueBloc, CreateIssueState>(
                        builder: (context, state) {
                      return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: [
                              CustomHeader(
                                title: AppLocalizations.of(context)!.location,
                                background: custom_colors.greyGradient,
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                              ),
                              getLocationSnippet(context, bloc, state),
                              CustomHeader(
                                title: AppLocalizations.of(context)!.category,
                                background: custom_colors.greyGradient,
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                              ),
                              getCategory(context, bloc, state),
                              CustomHeader(
                                title:
                                    AppLocalizations.of(context)!.description,
                                background: custom_colors.greyGradient,
                                margin: const EdgeInsets.all(0),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                              ),
                              getDescription(context, bloc, state)
                            ],
                          ));
                    })))));
  }

  Widget getLocationSnippet(
      BuildContext context, CreateIssueBloc bloc, CreateIssueState state) {
    return Column(
      children: [
        if (state.marker != null)
          GoogleMapSnippet(
            height: 200,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            mapType: state.mapType ?? MapType.normal,
            marker: state.marker,
          ),
        if (state.marker != null)
          CustomHeader(
            title:
                "${AppLocalizations.of(context)!.near} ${(state.address ?? "")}",
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          ),
        CustomButton(
          onPressed: () => bloc.add(ButtonPressed(
              createIssueButtonEvent: CreateIssueButtonEvent.selectLocation)),
          margin: const EdgeInsets.all(10),
          showBorder: true,
          text: state.category == null
              ? AppLocalizations.of(context)!.select_location
              : AppLocalizations.of(context)!.change_location,
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
        )
      ],
    );
  }

  Widget getCategory(
      BuildContext context, CreateIssueBloc bloc, CreateIssueState state) {
    return Column(
      children: [
        if (state.category != null && state.subCategory != null)
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                CustomHeader(
                  title: LocalizationHelper.getInstance()
                      .getLocalizedCategory(context, state.category),
                  margin: const EdgeInsets.all(0),
                ),
                CustomHeader(
                  title: LocalizationHelper.getInstance()
                      .getLocalizedSubCategory(context, state.subCategory),
                  margin: const EdgeInsets.only(top: 10),
                )
              ],
            ),
          ),
        CustomButton(
          onPressed: () => bloc.add(ButtonPressed(
              createIssueButtonEvent: CreateIssueButtonEvent.selectCategory)),
          margin: const EdgeInsets.all(10),
          showBorder: true,
          text: state.category == null
              ? AppLocalizations.of(context)!.select_category
              : AppLocalizations.of(context)!.change_category,
          pressedBackground: custom_colors.greyGradient,
          defaultBackground: custom_colors.whiteGradient,
        )
      ],
    );
  }

  Widget getDescription(
      BuildContext context, CreateIssueBloc bloc, CreateIssueState state) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CustomTextField(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: 10),
            text: state.description,
            initialValue: state.description,
            onChanged: (value) => bloc.add(TextChanged(
                createIssueTextChangedEvent:
                    CreateIssueTextChangedEvent.description,
                value: value)),
            maxLength: 255,
            height: 110,
            maxLines: null,
          ),
          GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            children: List.generate(
                (state.pictures == null ? 0 : state.pictures!.length) +
                    ((state.pictures == null || state.pictures!.length < 3)
                        ? 1
                        : 0), (index) {
              if (index ==
                  (state.pictures == null ? 0 : state.pictures!.length)) {
                return AspectRatio(
                    aspectRatio: 1,
                    child: CustomButton(
                      defaultBackground: custom_colors.whiteGradient,
                      pressedBackground: custom_colors.greyGradient,
                      height: null,
                      showBorder: true,
                      onPressed: () {},
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.black,
                        size: (MediaQuery.of(context).size.width / 4),
                      ),
                    ));
              } else {
                // TODO: Add option for deleting picture
                return AspectRatio(
                    aspectRatio: 1,
                    child:
                        ImageFullScreenWrapper(child: state.pictures![index]));
              }
            }),
          )
        ],
      ),
    );
  }
}
