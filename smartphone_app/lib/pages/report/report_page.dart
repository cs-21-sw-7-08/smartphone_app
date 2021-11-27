// ignore: must_be_immutable
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_label.dart';

import 'report_bloc.dart';
import 'report_events_states.dart';

// ignore: must_be_immutable
class ReportPage extends StatelessWidget {
  late ReportBloc bloc;

  ReportPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create bloc
    bloc = ReportBloc(context: context);

    return WillPopScope(
        onWillPop: () async {
          bloc.add(const ButtonPressed(buttonEvent: ReportButtonEvent.close));
          return false;
        },
        child: BlocProvider(
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
                        child: BlocBuilder<ReportBloc, ReportState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              appBar: CustomAppBar(
                                title: AppLocalizations.of(context)!.report,
                                titleColor: Colors.white,
                                background: custom_colors.appBarBackground,
                                appBarLeftButton: AppBarLeftButton.close,
                                leftButtonPressed: () => bloc.add(
                                    const ButtonPressed(
                                        buttonEvent: ReportButtonEvent.close)),
                              ),
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }

  Widget _getContent(BuildContext context, ReportBloc bloc, ReportState state) {
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
                                    Card(
                                        margin: const EdgeInsets.only(
                                            top: values.padding,
                                            left: values.padding,
                                            right: values.padding),
                                        child: Column(
                                          children: [
                                            CustomLabel(
                                                title: AppLocalizations.of(
                                                        context)!
                                                    .select_why_you_want_to_report_this_issue)
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
                                                    .report_category),
                                            _getReportCategory(
                                                context, bloc, state),
                                          ],
                                        )),
                                  ],
                                ))),
                        // 'Confirm' button
                        CustomButton(
                          onPressed: () => bloc.add(const ButtonPressed(
                              buttonEvent: ReportButtonEvent.confirm)),
                          text: AppLocalizations.of(context)!.confirm,
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

  Widget _getReportCategory(
      BuildContext context, ReportBloc bloc, ReportState state) {
    return Container(
        margin: const EdgeInsets.only(
            left: values.padding,
            top: values.padding,
            right: values.padding,
            bottom: values.padding),
        child: Column(
          children: [
            if (state.reportCategory != null)
              Column(
                children: [
                  CustomLabel(
                    title: LocalizationHelper.getInstance()
                        .getLocalizedReportCategory(
                            context, state.reportCategory),
                    margin: const EdgeInsets.all(0),
                  ),
                ],
              ),
            CustomButton(
              onPressed: () => bloc.add(const ButtonPressed(
                  buttonEvent: ReportButtonEvent.selectReportCategory)),
              margin: EdgeInsets.only(
                  top: (state.reportCategory != null) ? values.padding : 0),
              fontWeight: FontWeight.bold,
              text: state.reportCategory == null
                  ? AppLocalizations.of(context)!.select_category
                  : AppLocalizations.of(context)!.change_category,
            )
          ],
        ));
  }
}
