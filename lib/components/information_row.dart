import 'dart:math';

import 'package:flutter/material.dart';

class RockInfoRow {
  static Widget makeRow(String left, dynamic right) {
    if (right is List){
      int randomIndex = Random().nextInt(100) % (right as List).length;
      right = right[randomIndex];
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(
            left,
            style: const TextStyle(color: Colors.white38),
            maxLines: 1000,
            overflow: TextOverflow.ellipsis,
          )),
          Expanded(
              child: Text(
            right,
            style: const TextStyle(color: Colors.white),
            maxLines: 1000,
            overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }
}
