// ignore: must_be_immutable
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_text_field.dart';

import 'custom_list_dialog_bloc.dart';
import 'custom_list_dialog_events_states.dart';

typedef ItemSelected = Function(List<dynamic>? newList);
typedef ItemUpdated = Function();
typedef ItemBuilder = Widget? Function(
    int index,
    dynamic item,
    List<dynamic> list,
    bool showSearchBar,
    ItemSelected itemSelected,
    ItemUpdated itemUpdated);
typedef SearchPredicate = bool Function(dynamic item, String searchString);
typedef TitleBuilder = String Function(dynamic item);
typedef ConfirmPressedCallBack = List<dynamic> Function(
    List<dynamic> currentRootList);

class SelectedItem {
  dynamic selectedItem;
  List<dynamic>? selectedItems;

  SelectedItem({required this.selectedItem, required this.selectedItems});
}

// ignore: must_be_immutable
class CustomListDialog extends StatefulWidget {
  late CustomListDialogBloc bloc;
  late List<dynamic> rootItems;
  late ItemBuilder itemBuilder;
  late SearchPredicate searchPredicate;
  late TitleBuilder titleBuilder;
  late ConfirmPressedCallBack? confirmPressedCallBack;
  bool showConfirmButton;

  CustomListDialog._(
      {Key? key,
      required this.rootItems,
      required this.itemBuilder,
      this.showConfirmButton = false,
      required this.titleBuilder,
      this.confirmPressedCallBack,
      required this.searchPredicate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomListDialogState();

  static Future<List<dynamic>?> show(BuildContext context,
      {required List<dynamic> items,
      required ItemBuilder itemBuilder,
      ConfirmPressedCallBack? confirmPressedCallBack,
      bool showConfirmButton = false,
      required TitleBuilder titleBuilder,
      required SearchPredicate searchPredicate}) async {
    return Future.delayed(Duration.zero, () async {
      // Show dialog
      var returnValue = await GeneralUtil.showPageAsDialog<List<dynamic>?>(
          context,
          CustomListDialog._(
              itemBuilder: itemBuilder,
              showConfirmButton: showConfirmButton,
              confirmPressedCallBack: confirmPressedCallBack,
              rootItems: items,
              titleBuilder: titleBuilder,
              searchPredicate: searchPredicate));
      if (returnValue == null) return null;
      return returnValue;
    });
  }
}

// ignore: must_be_immutable
class _CustomListDialogState extends State<CustomListDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  late Animation<double> sizeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(animationController);
    sizeAnimation =
        Tween<double>(begin: 0, end: 80).animate(animationController);
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomListDialogBloc bloc = CustomListDialogBloc(
        buildContext: context,
        confirmPressedCallBack: widget.confirmPressedCallBack,
        items: widget.rootItems,
        searchPredicate: widget.searchPredicate);

    return WillPopScope(
        onWillPop: () async {
          bloc.add(ButtonPressed(
              buttonEvent:
                  CustomListDialogButtonEvent.backPressed));
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
                        child: BlocBuilder<CustomListDialogBloc,
                            CustomListDialogState>(
                          builder: (context, state) {
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              appBar: CustomAppBar(
                                title: widget.titleBuilder(
                                    state.selectedItemTree!.isEmpty
                                        ? null
                                        : state.selectedItemTree!.last
                                            .selectedItem),
                                titleColor: Colors.white,
                                background: custom_colors.appBarBackground,
                                appBarLeftButton:
                                    state.selectedItemTree!.isEmpty
                                        ? AppBarLeftButton.close
                                        : AppBarLeftButton.back,
                                leftButtonPressed: () => bloc.add(ButtonPressed(
                                    buttonEvent:
                                        CustomListDialogButtonEvent
                                            .backPressed)),
                                button1Icon: Icon(
                                    !state.showSearchBar!
                                        ? Icons.search_outlined
                                        : Icons.search_off_outlined,
                                    color: Colors.white),
                                onButton1Pressed: () {
                                  bloc.add(ButtonPressed(
                                      buttonEvent:
                                          CustomListDialogButtonEvent
                                              .changeSearchBarVisibility));
                                  !bloc.state.showSearchBar!
                                      ? animationController.forward()
                                      : animationController.reverse();
                                },
                              ),
                              body: _getContent(context, bloc, state),
                            );
                          },
                        ))))));
  }

  Widget _getContent(BuildContext context, CustomListDialogBloc bloc,
      CustomListDialogState state) {
    return ClipRect(
        child: Container(
            constraints: const BoxConstraints.expand(),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: animationController,
                          builder: (context, _) {
                            return Opacity(
                                opacity: opacityAnimation.value,
                                child: Container(
                                  color: Colors.transparent,
                                  height: sizeAnimation.value < 80
                                      ? sizeAnimation.value
                                      : null,
                                  padding: const EdgeInsets.all(0),
                                  child: CustomTextField(
                                    margin:
                                        const EdgeInsets.all(values.padding),
                                    text: state.searchText,
                                    showClearButton: true,
                                    hint: AppLocalizations.of(context)!
                                        .search_hint,
                                    onChanged: (value) => bloc.add(TextChanged(
                                        textChangedEvent:
                                            CustomListDialogTextChangedEvent
                                                .searchText,
                                        value: value)),
                                  ),
                                ));
                          },
                        ),
                        _getList(context, bloc, state),
                        if (widget.showConfirmButton)
                          // 'Confirm' button
                          CustomButton(
                            onPressed: () => bloc.add(ButtonPressed(
                                buttonEvent:
                                    CustomListDialogButtonEvent.confirm)),
                            text: AppLocalizations.of(context)!.confirm,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            margin: const EdgeInsets.all(values.padding),
                          )
                      ],
                    )))));
  }

  Widget _getList(BuildContext context, CustomListDialogBloc bloc,
      CustomListDialogState state) {
    return Expanded(
        child: ListView.builder(
      itemCount: state.filteredItems!.length,
      itemBuilder: (context, index) {
        Widget? itemBuilderWidget = widget.itemBuilder(
            index,
            state.filteredItems![index],
            state.filteredItems!,
            state.showSearchBar!, (newList) {
          // Hide keyboard
          GeneralUtil.hideKeyboard();
          // Fire event
          bloc.add(ItemWasSelected(
              selectedItem: SelectedItem(
                  selectedItem: state.filteredItems![index],
                  selectedItems: newList)));
        }, () {
          // Hide keyboard
          GeneralUtil.hideKeyboard();
          // Fire event
          bloc.add(ItemWasUpdated());
        });
        if (itemBuilderWidget == null) {
          return Container(height: 50);
        }
        return itemBuilderWidget;
      },
    ));
  }
}
