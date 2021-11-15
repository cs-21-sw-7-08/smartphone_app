import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
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

import 'issue_bloc.dart';
import 'issue_events_states.dart';

typedef ChangesCallback = Function();

// ignore: must_be_immutable
class IssuePage extends StatelessWidget {
  late IssuePageBloc bloc;
  late Issue? issue;
  late MapType mapType;

  IssuePage({
    Key? key,
    this.issue,
    required this.mapType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IssuePageBloc bloc = IssuePageBloc(
      buildContext: context,
      mapType: mapType,
      issue: issue,
    );

    return WillPopScope(
        onWillPop: () async {
          bloc.add(
              ButtonPressed(issueButtonEvent: IssueButtonEvent.backPressed));
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
                                /*gradient: custom_colors.orangeYellowGradient,*/
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: ExactAssetImage(
                                      values.createIssueBackground,
                                    )),
                              ),
                              child: BlocBuilder<IssuePageBloc, IssuePageState>(
                                builder: (context, state) {
                                  return Scaffold(
                                    backgroundColor: Colors.transparent,
                                    appBar: CustomAppBar(
                                      title: _getTitle(context, state),
                                      titleColor: Colors.white,
                                      background:
                                          custom_colors.appBarBackground,
                                      appBarLeftButton: AppBarLeftButton.back,
                                      leftButtonPressed: () => bloc.add(
                                          ButtonPressed(
                                              issueButtonEvent: IssueButtonEvent
                                                  .backPressed)),
                                      onButton1Pressed: () {
                                        IssueButtonEvent? buttonEvent;
                                        switch (state.issuePageView!) {
                                          case IssuePageView.edit:
                                          case IssuePageView.create:
                                            buttonEvent =
                                                IssueButtonEvent.saveChanges;
                                            break;
                                          case IssuePageView.see:
                                            if (state.isCreator!) {
                                              buttonEvent =
                                                  IssueButtonEvent.editIssue;
                                            } else {
                                              buttonEvent =
                                                  IssueButtonEvent.reportIssue;
                                            }
                                            break;
                                        }
                                        bloc.add(ButtonPressed(
                                            issueButtonEvent: buttonEvent));
                                      },
                                      button1Icon: Icon(_getButton1Icon(state),
                                          color: Colors.white),
                                    ),
                                    body: _getContent(context, bloc, state),
                                  );
                                },
                              )))));
            }));
  }

  IconData _getButton1Icon(IssuePageState state) {
    switch (state.issuePageView!) {
      case IssuePageView.create:
        return Icons.send_outlined;
      case IssuePageView.edit:
        return Icons.check;
      case IssuePageView.see:
        if (state.isCreator!) {
          return Icons.edit_outlined;
        } else {
          return Icons.flag_outlined;
        }
    }
  }

  String _getTitle(BuildContext context, IssuePageState state) {
    switch (state.issuePageView!) {
      case IssuePageView.create:
        return AppLocalizations.of(context)!.create_issue;
      case IssuePageView.edit:
        return AppLocalizations.of(context)!.edit_issue;
      case IssuePageView.see:
        return AppLocalizations.of(context)!.details;
    }
  }

  Widget _getContent(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    return ClipRect(
        child: Container(
            constraints: const BoxConstraints.expand(),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  children: [
                                    if (state.issuePageView ==
                                        IssuePageView.see)
                                      Card(
                                          margin: const EdgeInsets.only(
                                              top: values.padding,
                                              left: values.padding,
                                              right: values.padding),
                                          child: Column(
                                            children: [
                                              _getHeader(
                                                  AppLocalizations.of(context)!
                                                      .status),
                                              _getIssueState(
                                                  context, bloc, state),
                                            ],
                                          )),
                                    Card(
                                        margin: const EdgeInsets.only(
                                            top: values.padding,
                                            left: values.padding,
                                            right: values.padding),
                                        child: Column(
                                          children: [
                                            _getHeader(
                                                AppLocalizations.of(context)!
                                                    .location),
                                            _getLocationSnippet(
                                                context, bloc, state),
                                          ],
                                        )),
                                    Card(
                                        margin: const EdgeInsets.only(
                                            top: values.padding,
                                            left: values.padding,
                                            right: values.padding),
                                        child: Column(
                                          children: [
                                            _getHeader(
                                                AppLocalizations.of(context)!
                                                    .category),
                                            _getCategory(context, bloc, state),
                                          ],
                                        )),
                                    Card(
                                        margin: const EdgeInsets.only(
                                            top: values.padding,
                                            left: values.padding,
                                            right: values.padding,
                                            bottom: values.padding),
                                        child: Column(
                                          children: [
                                            _getHeader(
                                                AppLocalizations.of(context)!
                                                    .description),
                                            _getDescription(
                                                context, bloc, state)
                                          ],
                                        )),
                                  ],
                                ))),
                        if (state.issuePageView == IssuePageView.see &&
                            !state.isCreator! &&
                            !state.hasVerified!)
                          // 'Verify issue' button
                          CustomButton(
                            onPressed: () => bloc.add(ButtonPressed(
                                issueButtonEvent:
                                    IssueButtonEvent.verifyIssue)),
                            text: AppLocalizations.of(context)!.verify_issue,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            margin: const EdgeInsets.all(values.padding),
                          )
                      ],
                    )))));
  }

  Widget _getHeader(String title) {
    return Column(
      children: [
        CustomHeader(
          title: title,
          fontWeight: FontWeight.bold,
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.only(
              left: values.padding,
              right: values.padding,
              top: values.padding,
              bottom: values.smallPadding),
        ),
        Container(
          height: 1,
          color: custom_colors.contentDivider,
          margin: const EdgeInsets.only(
              left: values.padding, right: values.padding),
        ),
      ],
    );
  }

  Widget _getIssueState(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    return Container(
      margin: const EdgeInsets.only(
          left: values.padding,
          right: values.padding,
          top: values.smallPadding,
          bottom: values.padding),
      child: CustomHeader(
        title: LocalizationHelper.getInstance()
            .getLocalizedIssueState(context, state.issueState),
        margin: const EdgeInsets.all(0),
      ),
    );
  }

  Widget _getLocationSnippet(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    return Container(
        margin: const EdgeInsets.only(
            left: values.padding,
            top: values.smallPadding,
            right: values.padding,
            bottom: values.padding),
        child: Column(
          children: [
            if (state.marker != null)
              GoogleMapSnippet(
                height: 200,
                margin: const EdgeInsets.only(bottom: values.padding),
                mapType: state.mapType ?? MapType.normal,
                marker: state.marker,
              ),
            if (state.marker != null)
              CustomHeader(
                title:
                    "${AppLocalizations.of(context)!.near} ${(state.address ?? "")}",
                margin: const EdgeInsets.only(bottom: values.padding),
              ),
            if (state.issuePageView == IssuePageView.create ||
                state.issuePageView == IssuePageView.edit)
              CustomButton(
                onPressed: () => bloc.add(ButtonPressed(
                    issueButtonEvent: IssueButtonEvent.selectLocation)),
                margin: const EdgeInsets.all(0),
                fontWeight: FontWeight.bold,
                text: state.category == null
                    ? AppLocalizations.of(context)!.select_location
                    : AppLocalizations.of(context)!.change_location,
              )
          ],
        ));
  }

  Widget _getCategory(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    return Container(
        margin: const EdgeInsets.only(
            left: values.padding,
            top: values.smallPadding,
            right: values.padding,
            bottom: values.padding),
        child: Column(
          children: [
            if (state.category != null && state.subCategory != null)
              Column(
                children: [
                  CustomHeader(
                    title: LocalizationHelper.getInstance()
                        .getLocalizedCategory(context, state.category),
                    margin: const EdgeInsets.all(0),
                  ),
                  CustomHeader(
                    title: LocalizationHelper.getInstance()
                        .getLocalizedSubCategory(context, state.subCategory),
                    margin: const EdgeInsets.only(top: values.padding),
                  )
                ],
              ),
            if (state.issuePageView == IssuePageView.create ||
                state.issuePageView == IssuePageView.edit)
              CustomButton(
                onPressed: () => bloc.add(ButtonPressed(
                    issueButtonEvent: IssueButtonEvent.selectCategory)),
                margin: EdgeInsets.only(
                    top: (state.category != null && state.subCategory != null)
                        ? values.padding
                        : values.smallPadding),
                fontWeight: FontWeight.bold,
                text: state.category == null
                    ? AppLocalizations.of(context)!.select_category
                    : AppLocalizations.of(context)!.change_category,
              )
          ],
        ));
  }

  Widget _getDescription(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    switch (state.issuePageView!) {
      case IssuePageView.create:
      case IssuePageView.edit:
        return _getCreateEditDescription(context, bloc, state);
      case IssuePageView.see:
        return _getSeeDescription(context, bloc, state);
    }
  }

  Widget _getCreateEditDescription(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    return Container(
      margin: const EdgeInsets.only(
          left: values.padding,
          right: values.padding,
          top: values.smallPadding,
          bottom: values.padding),
      child: Column(
        children: [
          CustomTextField(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(bottom: values.padding),
            text: state.description,
            initialValue: state.description,
            onChanged: (value) => bloc.add(TextChanged(
                createIssueTextChangedEvent: IssueTextChangedEvent.description,
                value: value)),
            maxLength: 255,
            height: 110,
            maxLines: null,
          ),
          GridView.count(
            crossAxisCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: values.padding,
            shrinkWrap: true,
            mainAxisSpacing: values.padding,
            children: List.generate(
                (state.pictures == null ? 0 : state.pictures!.length) + 1,
                (index) {
              if (index ==
                  (state.pictures == null ? 0 : state.pictures!.length)) {
                return AspectRatio(
                    aspectRatio: 1,
                    child: CustomButton(
                      height: null,
                      onPressed: () => bloc.add(ButtonPressed(
                          issueButtonEvent: IssueButtonEvent.selectPicture)),
                      icon: Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.black,
                        size: (MediaQuery.of(context).size.width / 5),
                      ),
                    ));
              } else {
                return AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        ImageFullScreenWrapper(child: state.pictures![index]),
                        Align(
                          child: CustomButton(
                              height: 50,
                              width: 50,
                              margin: const EdgeInsets.only(
                                  right: values.smallPadding,
                                  top: values.smallPadding),
                              imagePadding:
                                  const EdgeInsets.all(values.padding),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(25)),
                              icon:
                                  const Icon(Icons.clear, color: Colors.black),
                              onPressed: () => bloc.add(DeletePicture(
                                  picture: state.pictures![index]))),
                          alignment: Alignment.topRight,
                        ),
                      ],
                    ));
              }
            }),
          )
        ],
      ),
    );
  }

  Widget _getSeeDescription(
      BuildContext context, IssuePageBloc bloc, IssuePageState state) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
      child: Column(
        children: [
          if (state.description != null && state.description!.isNotEmpty)
            CustomHeader(
              title: state.description!,
              margin: const EdgeInsets.only(bottom: 0),
            ),
          if (state.pictures!.isNotEmpty)
            Container(
                margin: const EdgeInsets.only(top: 10),
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  mainAxisSpacing: 10,
                  children: List.generate(
                      (state.pictures ?? List.empty()).length, (index) {
                    return AspectRatio(
                        aspectRatio: 1,
                        child: ImageFullScreenWrapper(
                            child: state.pictures![index]));
                  }),
                ))
        ],
      ),
    );
  }
}