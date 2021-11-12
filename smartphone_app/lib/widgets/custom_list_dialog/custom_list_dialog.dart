// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/widgets/custom_list_dialog/custom_list_dialog_bloc.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_text_field.dart';

import '../custom_app_bar.dart';
import 'custom_list_dialog_events_states.dart';

typedef ItemSelected = Function(List<dynamic>? newList);
typedef ItemBuilder = Widget Function(dynamic item, ItemSelected itemSelected);
typedef SearchPredicate = bool Function(dynamic item, String searchString);

class SelectedItem {
  dynamic selectedItem;
  List<dynamic> selectedItems;

  SelectedItem({required this.selectedItem, required this.selectedItems});
}

class CustomListDialog extends StatefulWidget {
  late CustomListDialogBloc bloc;
  late List<dynamic> rootItems;
  late ItemBuilder itemBuilder;
  late SearchPredicate searchPredicate;

  CustomListDialog._(
      {Key? key,
      required this.itemBuilder,
      required this.rootItems,
      required this.searchPredicate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomListDialogState();

  static Future<bool> show(BuildContext context,
      {required List<dynamic> items,
      required ItemBuilder itemBuilder,
      required SearchPredicate searchPredicate}) async {
    return Future.delayed(Duration.zero, () async {
      // Show dialog
      bool? returnValue = await GeneralUtil.showPageAsDialog<bool>(
          context,
          CustomListDialog._(
              itemBuilder: itemBuilder,
              rootItems: items,
              searchPredicate: searchPredicate));
      if (returnValue == null) return false;
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
    CustomListDialogBloc bloc =
        CustomListDialogBloc(buildContext: context, items: widget.rootItems);

    return WillPopScope(
        onWillPop: () async {
          bloc.add(ButtonPressed(
              customListDialogButtonEvent:
                  CustomListDialogButtonEvent.backPressed));
          return false;
        },
        child: BlocProvider(
            create: (_) => bloc,
            child: Container(
                color: custom_colors.appSafeAreaColor,
                child: SafeArea(child:
                    BlocBuilder<CustomListDialogBloc, CustomListDialogState>(
                  builder: (context, state) {
                    return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: CustomAppBar(
                        title: AppLocalizations.of(context)!.details,
                        titleColor: Colors.white,
                        background: custom_colors.appBarBackground,
                        appBarLeftButton: AppBarLeftButton.back,
                        leftButtonPressed: () => bloc.add(ButtonPressed(
                            customListDialogButtonEvent:
                                CustomListDialogButtonEvent.backPressed)),
                        button1Icon: Icon(
                            !state.showSearchBar!
                                ? Icons.search_outlined
                                : Icons.search_off_outlined,
                            color: Colors.white),
                        onButton1Pressed: () {
                          bloc.add(ButtonPressed(
                              customListDialogButtonEvent:
                                  CustomListDialogButtonEvent
                                      .changeSearchBarVisibility));
                          !bloc.state.showSearchBar!
                              ? animationController.forward()
                              : animationController.reverse();
                        },
                      ),
                      body: getContent(context, bloc, state),
                    );
                  },
                )))));
  }

  Widget getContent(BuildContext context, CustomListDialogBloc bloc,
      CustomListDialogState state) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: animationController,
          builder: (context, _) {
            return Opacity(
                opacity: opacityAnimation.value,
                child: Container(
                  color: Colors.white,
                  height: sizeAnimation.value < 80 ? sizeAnimation.value : null,
                  padding: const EdgeInsets.all(0),
                  child: CustomTextField(
                    margin: const EdgeInsets.all(10),
                    text: state.searchText,
                    hint: "Search...",
                    onChanged: (value) => bloc.add(TextChanged(
                        customListDialogTextChangedEvent:
                            CustomListDialogTextChangedEvent.searchText,
                        value: value)),
                  ),
                ));
          },
        ),
        getList(context, bloc, state)
      ],
    );
  }

  Widget getList(BuildContext context, CustomListDialogBloc bloc,
      CustomListDialogState state) {
    return Expanded(
        child: ListView.separated(
      itemCount: state.filteredItems!.length,
      itemBuilder: (context, index) {
        return widget.itemBuilder(state.filteredItems![index], (newList) {
          GeneralUtil.hideKeyboard();
          if (newList == null) {
            Navigator.of(context).pop(true);
          } else {
            bloc.add(ItemWasSelected(
                selectedItem: SelectedItem(
                    selectedItem: state.filteredItems![index],
                    selectedItems: newList)));
          }
        });
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 1,
          thickness: 1,
          color: Colors.black,
        );
      },
    ));
  }
}
