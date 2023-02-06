import 'package:flutter/material.dart';

class DrawerListTile extends StatelessWidget {
  final IconData icon;
  final String listText;
  final bool isSelected;
  Function? whenTapped;
  DrawerListTile({
    required this.icon,
    required this.listText,
    required this.isSelected,
    this.whenTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          "$listText",
          style: isSelected
              ? TextStyle(color: Theme.of(context).colorScheme.onPrimary)
              : null,
        ),
        onTap: () => whenTapped!(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        selected: isSelected,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.6),
      ),
    );
  }
}
