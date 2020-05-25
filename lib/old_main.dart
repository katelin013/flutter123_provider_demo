import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 註冊寫好的 MyChangeNotifier
      providers: [ChangeNotifierProvider.value(value: MyCountChangeNotifier())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Consumer<MyCountChangeNotifier>(builder: (context, counter, _) {
              return Text('${counter.count}');
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // 使用 Provider.of，並且將 listen 設定為 false(若沒設定，預設為 true)，
          // 則不會再次調用 Widget 重新構建（ build ）畫面 ，更省效能。
          Provider.of<MyCountChangeNotifier>(context, listen: false)
              .increment();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyCountChangeNotifier with ChangeNotifier {
  // 設定一個整數私有變數 _count的欄位，初值為零
  int _count = 0;
  //可以透過 Consumer 來獲得當下 count 值
  int get count => _count;
  //當點擊右下角＋ 浮動按鈕，會呼叫此方法
  //此方法會將 _count 累加 1，並叫 notifyListeners
  increment() {
    _count++;
    notifyListeners();
  }
}
