---

# Flutter123 關於 Provider

在 Flutter 的世界中，所有的東西都是一個 Widget，而 Widget 會繼續包著 Widget ，下圖是使用 Android Studio 新建立的一個專案，一開始的預設程式碼以及畫面。
[Medium](https://medium.com/@katelin013/flutter123-%E9%97%9C%E6%96%BC-provider-14e4ec66f402)
---

### 在預設的這個專案中，使用的是 State 這個方式去更新 Widget 狀態
```
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
// 增加 Count 數
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      。。。
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, // 點擊後呼叫_incrementCounter()
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

這裡更新的方式是因為在_incrementCount() 中有一個 setState() 的方法，這方法是告訴 Widget 更新，在這專案 MyomePage 設定的是 Statefulwidget，裡面是建立了一個 _MyHomePageState() 來監聽狀態的改變。
在 Flutter 的世界中，當你更新了頂層的 Widget ，下方所有的 Widget 都會重繪，所以以這個範例來說，在 MyHomePage 下面的所有 Widget 都會重新產生一次。
Scaffold,Center,Column,Text,Text,AppBar,FloatingActoinButton都會重新繪製當一個畫面東西越來越多的時候，要更新很頂部的某個 Widget 就會造成 Lag 或者浪費手機資源，明明我們只是要更新某個 Text 的文字而已，那該怎麼辦呢？

# Provider
2019 Google I/O 大會，官方在Google I/O'19 主題演講上正式介紹了由社區作者Remi Rousselet 與Flutter Team 共同編寫的Provider成為官方推薦的狀態管理方式之一。
關於 Provider 主要要先知道的幾個概念 :
ChangeNotifier : 主要是用來註冊一個觀察者, 會透過 notifyListeners 來通知狀態改變
ChangeNotifierProvider : 用在向其他子節點, 提供 ChangeNotifier 的實例
Comsumer : 當狀態發生改變時, 可以將資料透過 Consumer 來接收更改對應資料 ( 將 Consumer 放在 widget 較低的位置上, 不然會重繪底下所有 widget )

### Step 1. 建立一個 ChangeNotifier
```
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
```
### Step 2. 註冊 MyCountChangeNotifier
```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 註冊寫好的 MyChangeNotifier
      providers: [ChangeNotifierProvider.value(value:
                  MyCountChangeNotifier())],
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
```

### Step 3. 使用它吧 !
```
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
            // 將會需要變更資料的 Widget 用 Consumer 包起來
            Consumer<MyCountChangeNotifier>(builder: (context,
                counter, _) {
              return Text('${counter.count}');
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // 使用 Provider.of，並且將 listen 設定為 false(若沒設定，預設為
             true)，
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
```

在 floatingActionButton 中使用 Provider.of的方式呼叫了 MyCountChangeNotifier 中的 increment的方法，執行 increment 方法後呼叫 notifyListeners 方法， Consumer 就會監聽到資料的改變，此時就能過過 Consumer 中的 builder 的第二個參數 value 的回傳，得到 MyCountChangeNotifier 內部的變數資料，用 Provider 的方法就可以避免整個畫面重繪，只針對我們想要變更的 Widget 做重繪的動作了。
