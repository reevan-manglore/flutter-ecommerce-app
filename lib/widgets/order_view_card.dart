import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order_item.dart';

class OrderViewCard extends StatefulWidget {
  final OrderItem item;
  OrderViewCard(this.item);

  @override
  State<OrderViewCard> createState() => _OrderViewCardState();
}

class _OrderViewCardState extends State<OrderViewCard> {
  bool _expanded = false;
  void _toogleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height:
          _expanded ? min(widget.item.products.length * 20.0 + 130, 400) : 100,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text("\$ ${widget.item.amount}"),
              subtitle: Text(
                DateFormat('dd-MMMM-yy hh:mm').format(widget.item.dateTime),
              ),
              trailing: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: _toogleExpanded,
            ),
            AnimatedContainer(
              height: _expanded
                  ? min(widget.item.products.length * 20.0 + 60, 300)
                  : 0,
              duration: Duration(milliseconds: 500),
              child: Container(
                margin: EdgeInsets.all(10),
                // height: min(widget.item.products.length * 20.0 + 60, 140),
                child: ListView.builder(
                  itemBuilder: (ctx, idx) {
                    final item = widget.item.products[idx];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade700),
                          ),
                          Text(
                            "\$${item.price} * ${item.quantity}",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: widget.item.products.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
