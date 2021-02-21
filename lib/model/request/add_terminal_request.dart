import 'package:flutter/cupertino.dart';

/// @author DoggieX
/// @create 2021/2/9 10:47
/// @mail coldpuppy@163.com

class AddTerminalRequest {
  int sid;
  String terminal;

  AddTerminalRequest({this.sid, @required this.terminal});

  Map<String, dynamic> toMap() => {'sid': sid, 'terminal': terminal};
}