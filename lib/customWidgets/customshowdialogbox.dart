import 'package:flutter/material.dart';

enum DialogState { success, warning, failure }

class DialogStateDetail {
  Color color;
  IconData icons;
  DialogStateDetail({required this.color, required this.icons});
}

Map<Enum, DialogStateDetail> dialogStateMap = {
  DialogState.success:
      DialogStateDetail(color: Colors.green, icons: Icons.done),
  DialogState.warning:
      DialogStateDetail(color: Colors.amber, icons: Icons.error_outline),
  DialogState.failure: DialogStateDetail(color: Colors.red, icons: Icons.close)
};

void showTheDialogBox(BuildContext context, DialogState en, String text,
    Function? dothen, List<String>? missingElements) {
  DialogStateDetail detail = dialogStateMap[en] ??
      DialogStateDetail(color: Colors.black, icons: Icons.error);
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            icon: Icon(
              detail.icons,
              size: 32,
            ),
            iconColor: detail.color,
            title: Text(text),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            content: en.index == 1
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...missingElements!.map((e) => ListTile(
                            leading: const Icon(Icons.fiber_manual_record,
                                size: 10, color: Colors.black),
                            title: Text(e),
                          ))
                    ],
                  )
                : null,
          )).then((value) => {dothen?.call()});
}
