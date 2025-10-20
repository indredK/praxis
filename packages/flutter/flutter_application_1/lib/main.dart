import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 该部件是应用程序的根部件。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 这是应用程序的主题配置。
        //
        // 试一试：使用 "flutter run" 运行应用。你会看到紫色工具栏。
        // 不退出应用，将下面的 colorScheme 中的 seedColor 改为 Colors.green，
        // 然后执行“热重载”（保存变更或在支持的 IDE 按热重载按钮，
        // 或在命令行按 "r"）。
        //
        // 注意：计数器不会重置为 0；热重载不会丢失应用状态。
        // 如需重置状态，请使用热重启（hot restart）。
        //
        // 这同样适用于代码的大多数改动：大多数代码更改都可以通过热重载验证。
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 这是应用的首页组件。它是有状态的（Stateful），
  // 也就是说它拥有一个 State 对象（见下方），其中的字段会影响界面显示。

  // 该类用于描述状态的配置。它持有父级（这里是 App 组件）传入的值
  //（本例是 title），这些值会被 State 的 build 方法使用。
  // 在 Widget 子类中，字段通常声明为 "final"。

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 调用 setState 告知 Flutter 框架：该 State 有变化，
      // 从而触发重新执行下方的 build 方法，以便界面反映最新值。
      // 如果不调用 setState() 就修改 _counter，build 将不会再次执行，
      // 界面也就不会更新。
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 每次调用 setState（例如上面的 _incrementCounter）时，都会重新执行本方法。
    //
    // Flutter 对重新执行 build 进行了优化，因而可以只通过重建需要更新的部分，
    // 而无需逐个修改部件实例。
    return Scaffold(
      appBar: AppBar(
        // 试一试：把这里的颜色改为特定颜色（比如 Colors.amber），
        // 然后执行热重载，观察 AppBar 颜色变化而其他颜色保持不变。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 这里使用 MyHomePage（由 App.build 创建）中的 title 来设置 AppBar 标题。
        title: Text(widget.title),
      ),
      body: Center(
        // Center 是布局部件，它接收单个子部件并将其居中显示。
        child: Column(
          // Column 也是布局部件。它接收一组子部件并按垂直方向排列。
          // 默认情况下，它会在水平方向适配子部件宽度，并尽量在垂直方向填满父级高度。
          //
          // Column 提供多种属性来控制自身尺寸和子部件的摆放方式。
          // 这里我们通过 mainAxisAlignment 在主轴（垂直方向）让子部件居中。
          //
          // 试一试：开启“调试绘制”（IDE 中选择“Toggle Debug Paint”，
          // 或在控制台按 "p"）来查看每个部件的线框。
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // 末尾的逗号可以让代码格式化后的结构更清晰。
    );
  }
}
