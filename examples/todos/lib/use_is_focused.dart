// TextField などが選択されているかどうかの判定に使う。編集モード or テキストモードの切り替え
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

bool useIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);

  useEffect(
    () {
      void listener() {
        isFocused.value = node.hasFocus;
      }

      node.addListener(listener);
      return () => node.removeListener(listener);
    },
    [node],
  );

  return isFocused.value;
}
