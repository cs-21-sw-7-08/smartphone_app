// ignore: must_be_immutable, use_key_in_widget_constructors
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/objects/category_filter_item.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_bloc.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_events_states.dart';
import 'package:smartphone_app/utilities/wasp_util.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

// ignore: must_be_immutable
class IssuesOverviewFilterPage extends StatelessWidget {
  late IssuesOverviewFilterBloc bloc;
  IssuesOverviewFilter filter;

  IssuesOverviewFilterPage({Key? key, required this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IssuesOverviewFilterBloc bloc =
        IssuesOverviewFilterBloc(buildContext: context, filter: filter);

    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(null);
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

              /// Main content shown on the this page
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
                              child: BlocBuilder<IssuesOverviewFilterBloc,
                                  IssuesOverviewFilterState>(
                                builder: (context, state) {
                                  return Scaffold(
                                    backgroundColor: Colors.transparent,
                                    appBar: CustomAppBar(
                                      title:
                                          AppLocalizations.of(context)!.filter,
                                      titleColor: Colors.white,
                                      background:
                                          custom_colors.appBarBackground,
                                      appBarLeftButton: AppBarLeftButton.close,
                                      leftButtonPressed: () => bloc.add(
                                          ButtonPressed(
                                              issuesOverviewFilterButtonEvent:
                                                  IssuesOverviewFilterButtonEvent
                                                      .closePressed)),
                                      button1Icon: const Icon(
                                        Icons.refresh_outlined,
                                        color: Colors.white,
                                      ),
                                      onButton1Pressed: () => bloc.add(
                                          ButtonPressed(
                                              issuesOverviewFilterButtonEvent:
                                                  IssuesOverviewFilterButtonEvent
                                                      .resetAll)),
                                    ),
                                    body: _getContent(context, bloc, state),
                                  );
                                },
                              )))));
            }));
  }

  Widget _getContent(BuildContext context, IssuesOverviewFilterBloc bloc,
      IssuesOverviewFilterState state) {
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _getCard(null,
                                        AppLocalizations.of(context)!.general, [
                                      _getOnlyOwnIssues(context, bloc, state)
                                    ]),
                                    _getCard(
                                        () => bloc.add(ButtonPressed(
                                            issuesOverviewFilterButtonEvent:
                                                IssuesOverviewFilterButtonEvent
                                                    .resetIssueStates)),
                                        AppLocalizations.of(context)!.status,
                                        [_getIssueState(context, bloc, state)]),
                                    _getCard(
                                        () => bloc.add(ButtonPressed(
                                            issuesOverviewFilterButtonEvent:
                                                IssuesOverviewFilterButtonEvent
                                                    .resetCategories)),
                                        AppLocalizations.of(context)!.category,
                                        [_getCategory(context, bloc, state)]),
                                    if (state.categories!.isNotEmpty)
                                      _getCard(
                                          () => bloc.add(ButtonPressed(
                                              issuesOverviewFilterButtonEvent:
                                                  IssuesOverviewFilterButtonEvent
                                                      .resetSubCategories)),
                                          AppLocalizations.of(context)!.subcategory,
                                          [
                                            _getSubCategory(
                                                context, bloc, state)
                                          ]),
                                    _getCard(
                                        () => bloc.add(ButtonPressed(
                                            issuesOverviewFilterButtonEvent:
                                                IssuesOverviewFilterButtonEvent
                                                    .resetMunicipalities)),
                                        AppLocalizations.of(context)!
                                            .municipality,
                                        [
                                          _getMunicipality(context, bloc, state)
                                        ]),
                                  ],
                                ))),
                        // 'Apply' button
                        CustomButton(
                          onPressed: () => bloc.add(ButtonPressed(
                              issuesOverviewFilterButtonEvent:
                                  IssuesOverviewFilterButtonEvent.applyFilter)),
                          text: AppLocalizations.of(context)!.apply,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          margin: const EdgeInsets.all(values.padding),
                        )
                      ],
                    )))));
  }

  Widget _getCard(
      VoidCallback? resetPressed, String title, List<Widget> widgets,
      {bool isBottom = false}) {
    List<Widget> defaultWidgets = [
      _getHeader(title),
    ];
    defaultWidgets.addAll(widgets);

    return Stack(
      children: [
        Card(
            margin: EdgeInsets.only(
                top: values.padding,
                bottom: isBottom ? values.padding : 0,
                left: values.padding,
                right: values.padding),
            child: Column(
              children: defaultWidgets,
            )),
        if (resetPressed != null)
          Align(
              alignment: Alignment.topRight,
              child: CustomButton(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.only(
                      right: values.smallPadding, top: values.smallPadding),
                  imagePadding: const EdgeInsets.all(10),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  icon: const Icon(Icons.refresh_outlined, color: Colors.black),
                  onPressed: resetPressed)),
      ],
    );
  }

  Widget _getHeader(String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomLabel(
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

  Widget _getOnlyOwnIssues(BuildContext context, IssuesOverviewFilterBloc bloc,
      IssuesOverviewFilterState state) {
    return Container(
        margin: const EdgeInsets.all(values.padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: CustomLabel(
              title: AppLocalizations.of(context)!.only_own_issues,
              margin: const EdgeInsets.all(0),
            )),
            CustomButton(
                height: 50,
                width: 50,
                showBorder: false,
                margin: const EdgeInsets.all(0),
                imagePadding: const EdgeInsets.only(left: 5),
                borderRadius: const BorderRadius.all(Radius.circular(0)),
                pressedBackground: null,
                defaultBackground: null,
                icon: state.isOnlyShowingOwnIssues!
                    ? const Icon(
                        Icons.check_box_outlined,
                        color: Colors.black,
                        size: 50,
                      )
                    : const Icon(Icons.check_box_outline_blank_outlined,
                        color: Colors.black, size: 50),
                onPressed: () => bloc.add(ButtonPressed(
                    issuesOverviewFilterButtonEvent:
                        IssuesOverviewFilterButtonEvent.onlyShowYourOwnIssues)))
          ],
        ));
  }

  Widget _getIssueState(BuildContext context, IssuesOverviewFilterBloc bloc,
      IssuesOverviewFilterState state) {
    return Container(
      margin: const EdgeInsets.all(values.padding),
      height: 120,
      child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: state.issueStates!.length,
          itemBuilder: (context, index) {
            IssueStateFilterItem issueStateFilterItem =
                state.issueStates![index];
            return Container(
                margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 5,
                    right: index == state.issueStates!.length - 1 ? 0 : 5),
                child: CustomListTile(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  widget: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              gradient: issueStateFilterItem.isSelected
                                  ? custom_colors
                                      .orangeYellowTransparentGradient
                                  : null),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: values.padding * 2),
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: WASPUtil.getIssueStateColor(
                                      issueStateFilterItem.issueState),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                  child: CustomLabel(
                                      fontSize: 16,
                                      alignmentGeometry: Alignment.topCenter,
                                      margin: const EdgeInsets.all(0),
                                      padding: const EdgeInsets.only(top: 15),
                                      title: LocalizationHelper.getInstance()
                                          .getLocalizedIssueState(context,
                                              issueStateFilterItem.issueState)))
                            ],
                          ))),
                  onPressed: () => bloc.add(IssueStatePressed(
                      index: index,
                      issueStateFilterItem: issueStateFilterItem)),
                ));
          }),
    );
  }

  Widget _getCategory(BuildContext context, IssuesOverviewFilterBloc bloc,
      IssuesOverviewFilterState state) {
    return Container(
      margin: const EdgeInsets.all(values.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 'Select categories' button
          CustomButton(
            onPressed: () => bloc.add(ButtonPressed(
                issuesOverviewFilterButtonEvent:
                    IssuesOverviewFilterButtonEvent.selectCategories)),
            text: AppLocalizations.of(context)!.select_categories,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          if (state.categories!.isNotEmpty)
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.categories!.length,
                itemBuilder: (context, index) {
                  CategoryFilterItem categoryFilterItem =
                      state.categories![index];
                  return Card(
                      color: custom_colors.grey1,
                      margin: const EdgeInsets.only(top: values.padding),
                      child: Container(
                        margin: const EdgeInsets.all(values.padding),
                        color: Colors.transparent,
                        child: IntrinsicHeight(
                            child: Row(
                          children: [
                            Expanded(
                              child: CustomLabel(
                                  textAlign: TextAlign.left,
                                  alignmentGeometry: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(0),
                                  title: LocalizationHelper.getInstance()
                                      .getLocalizedCategory(
                                          context, categoryFilterItem.category),
                                  margin: const EdgeInsets.only(
                                      right: values.padding)),
                            ),
                            CustomButton(
                                height: 40,
                                width: 40,
                                defaultBackground:
                                    custom_colors.transparentGradient,
                                pressedBackground: custom_colors.greyGradient2,
                                margin: const EdgeInsets.all(0),
                                imagePadding: const EdgeInsets.all(5),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(25)),
                                icon: const Icon(Icons.clear,
                                    color: Colors.black),
                                onPressed: () => bloc.add(CategoryPressed(
                                    index: index,
                                    categoryFilterItem: categoryFilterItem)))
                          ],
                        )),
                      ));
                })
        ],
      ),
    );
  }

  Widget _getSubCategory(BuildContext context, IssuesOverviewFilterBloc bloc,
      IssuesOverviewFilterState state) {
    List<Widget> listViewChildren = List.empty(growable: true);
    if (state.subCategories!.isNotEmpty) {
      for (var item in state.categories!) {
        List<SubCategoryFilterItem> subCategoryFilterItems = state
            .subCategories!
            .where((element) => element.category == item.category)
            .toList();
        if (subCategoryFilterItems.isEmpty) continue;

        List<Widget> cardChildren = List.empty(growable: true);
        // Add category header
        cardChildren.add(Container(
          margin: const EdgeInsets.all(0),
          decoration: const BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(values.borderRadius)),
            color: Colors.transparent,
          ),
          child: IntrinsicHeight(
              child: Row(
            children: [
              Expanded(
                  child: CustomLabel(
                textAlign: TextAlign.left,
                alignmentGeometry: Alignment.centerLeft,
                fontWeight: FontWeight.bold,
                title: LocalizationHelper.getInstance()
                    .getLocalizedCategory(context, item.category),
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.only(
                    right: values.padding, bottom: values.padding),
              )),
              CustomButton(
                  height: 40,
                  width: 40,
                  defaultBackground: custom_colors.transparentGradient,
                  pressedBackground: custom_colors.greyGradient2,
                  margin: const EdgeInsets.only(bottom: values.padding),
                  imagePadding: const EdgeInsets.all(5),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () => bloc.add(
                      CategoryInSubCategoryPressed(categoryFilterItem: item)))
            ],
          )),
        ));
        cardChildren.add(Container(
            height: 1,
            color: custom_colors.contentDivider,
            margin: const EdgeInsets.only(left: 0, right: 0)));

        for (var subCategoryFilterItem in subCategoryFilterItems) {
          cardChildren.add(
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: IntrinsicHeight(
                  child: Row(
                children: [
                  Expanded(
                      child: CustomLabel(
                    textAlign: TextAlign.left,
                    alignmentGeometry: Alignment.centerLeft,
                    title: LocalizationHelper.getInstance()
                        .getLocalizedSubCategory(
                            context, subCategoryFilterItem.subCategory),
                    margin: const EdgeInsets.only(
                        right: values.padding, top: values.padding),
                  )),
                  CustomButton(
                      height: 40,
                      width: 40,
                      defaultBackground: custom_colors.transparentGradient,
                      pressedBackground: custom_colors.greyGradient2,
                      margin: const EdgeInsets.only(top: values.padding),
                      imagePadding: const EdgeInsets.all(5),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      icon: const Icon(Icons.clear, color: Colors.black),
                      onPressed: () => bloc.add(SubCategoryPressed(
                          subCategoryFilterItem: subCategoryFilterItem)))
                ],
              )),
            ),
          );
        }

        listViewChildren.add(Card(
          color: custom_colors.grey1,
          margin: const EdgeInsets.only(top: values.padding),
          child: Container(
              margin: const EdgeInsets.all(values.padding),
              child: Column(
                children: cardChildren,
              )),
        ));
      }
    }

    return Container(
      margin: const EdgeInsets.all(values.padding),
      child: Column(
        children: [
          // 'Select subcategories' button
          CustomButton(
            onPressed: () => bloc.add(ButtonPressed(
                issuesOverviewFilterButtonEvent:
                    IssuesOverviewFilterButtonEvent.selectSubCategories)),
            text: AppLocalizations.of(context)!.select_subcategories,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          if (state.subCategories!.isNotEmpty)
            ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: listViewChildren)
        ],
      ),
    );
  }

  Widget _getMunicipality(BuildContext context, IssuesOverviewFilterBloc bloc,
      IssuesOverviewFilterState state) {
    return Container(
      margin: const EdgeInsets.all(values.padding),
      child: Column(
        children: [
          // 'Select municipalities' button
          CustomButton(
            onPressed: () => bloc.add(ButtonPressed(
                issuesOverviewFilterButtonEvent:
                    IssuesOverviewFilterButtonEvent.selectMunicipalities)),
            text: AppLocalizations.of(context)!.select_municipalities,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          if (state.municipalities!.isNotEmpty)
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.municipalities!.length,
                itemBuilder: (context, index) {
                  MunicipalityFilterItem municipalityFilterItem =
                      state.municipalities![index];
                  return Card(
                      color: custom_colors.grey1,
                      margin: const EdgeInsets.only(top: values.padding),
                      child: Container(
                        margin: const EdgeInsets.all(values.padding),
                        color: Colors.transparent,
                        child: IntrinsicHeight(
                            child: Row(
                          children: [
                            Expanded(
                                child: CustomLabel(
                              title: municipalityFilterItem.municipality.name!,
                              margin:
                                  const EdgeInsets.only(right: values.padding),
                            )),
                            CustomButton(
                                height: 40,
                                width: 40,
                                defaultBackground:
                                    custom_colors.transparentGradient,
                                pressedBackground: custom_colors.greyGradient2,
                                margin: const EdgeInsets.all(0),
                                imagePadding: const EdgeInsets.all(5),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(25)),
                                icon: const Icon(Icons.clear,
                                    color: Colors.black),
                                onPressed: () => bloc.add(MunicipalityPressed(
                                    municipalityFilterItem:
                                        municipalityFilterItem)))
                          ],
                        )),
                      ));
                })
        ],
      ),
    );
  }
}
/*

 */
