// 起始位置：<qrS:${字符串总长度}|${每页长度}>
List<String> splitStrings(String msg, int len) {
  if (msg.length > len) {
    List<String> list = [];
    print(">>> ${msg.length}");

    int i = 0;
    int j = 1;
    while (i < msg.length) {
      int strLen = i + len;
      if (strLen > msg.length) {
        strLen = msg.length;
      }
      String newMsg = "";
      if (i == 0) {
        strLen -= 10;
        newMsg = "<qrS:${msg.length}|$len>";
      } else if (i + len >= msg.length) {
        newMsg = "<qrE:$j>";
      } else {
        newMsg = "<qrI:$j>";
      }
      newMsg += msg.substring(i, strLen);
      list.add(newMsg);
      print(">>> $i $strLen => $newMsg");
      i = strLen;
      j++;
    }
    return list;
  }
  return [msg];
}

// 根据每个字符串的开头排序字符串数组
List<String> sortList(List<String> list) {
  List<String> newList = [];
  // for (var i = 0; i < list.length; i++) {
  //   newList.add("");
  // }
  for (var v in list) {
    print(">>> v: $v");
    if (v.isEmpty) {
      continue;
    }
    //判断字符串是否以<qrS:xx>开头,并返回xx字符串
    String str = v.substring(5, v.indexOf(">"));
    print(">>> str $str");
    if (str.contains("|")) {
      if (newList.isEmpty) {
        newList.add(v);
      } else {
        newList[0] = v;
      }
      continue;
    }
    print(">>> 1111");
    int ii = int.parse(str);
    print(">>> 222");
    int i = ii - 1;
    print(">>> 333 $newList");
    if (ii >= newList.length) {
      var maxJ = ii - newList.length;
      print(">>> 333222 $maxJ");
      for (var j = 0; j < maxJ; j++) {
        newList.add("");
        print(">>> <<<");
      }
    }
    print(">>> 444 $newList <=> $i <=> $v");
    newList[i] = v;
    print(">>> 555");
  }
  print(">>> ====== >>> $newList");
  return newList;
}

// 根据起始位置和总长度，拼接字符串
// string list example:
// ["<qrI:2>n ws://127.0.0.1:12503/KK", "<qrE:3>G8e6yqptU=/ws", "<qrS:63|25>Debug service l"] to "Debug service listening on ws://127.0.0.1:12503/KKG8e6yqptU=/ws"
List<String> joinStrings(List<String> list) {
  int maxLen = 0;
  int len = 0;
  String msg = "";
  List<String> newList = [];
  for (var v in list) {
    newList.add(v);
  }
  for (var i = 0; i < newList.length; i++) {
    String v = newList[i];
    if (v == "") {
      return ["[Error]String Empty", ""];
    }
    String str = v.substring(5, v.indexOf(">"));
    if (str.contains("|")) {
      List temp = str.split("|");
      try {
        maxLen = int.parse(temp[0]);
        len = int.parse(temp[1]);
        print(">>> maxLen:$maxLen len:$len >>>>> $temp");
      } catch (e) {
        print(">>> $e");
        return ["[Error]String Start", ""];
      }
      newList[i] = v.substring(v.indexOf(">") + 1);
      if (newList[i].length != len - 10) {
        return ["[Error]item $i Length", ""];
      }
      continue;
    }
    newList[i] = v.substring(v.indexOf(">") + 1);
    if (newList[i].length > len) {
      print(">>> ${newList[i]} len:${newList[i].length} => $len");
      return ["[Error]item $i Length", ""];
    }
  }
  print(">>> $newList");
  msg = newList.join("");
  if (msg.length != maxLen) {
    return ["[Error]String Length", ""];
  }
  return ["", msg];
}

// 先判断是否存在，不存在再添加，并排序
List<String> addList(List<String> list, String str) {
  if (str == "") {
    return list;
  }
  if (!str.contains("<qr")) {
    return list;
  }
  bool isExist = false;
  List<String> newList = list;
  for (var v in newList) {
    if (v == str) {
      isExist = true;
      break;
    }
  }
  if (isExist) {
    newList = sortList(newList);
    return newList;
  }
  newList.add(str);
  newList = sortList(newList);
  return newList;
}
