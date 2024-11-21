import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'أجرتي',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      locale: Locale('ar', 'SA'), // تعيين اللغة إلى العربية
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController fareController = TextEditingController();
  final List<TextEditingController> peopleControllers = [];
  final List<TextEditingController> paidControllers = [];
  final List<String> remainingAmounts = []; // لحفظ المبالغ المتبقية لكل مدخل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // محاذاة العنوان لليمين
          children: [
            Text(
              'أجرتي',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl, // تعيين الاتجاه من اليمين لليسار
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('أجرة السيارة'),
              Container(
                height: 50,
                child: TextField(
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                  controller: fareController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    //    labelText: 'أجرة السيارة لكل شخص',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // عرض المدخلات الديناميكية
              Expanded(
                child: ListView.builder(
                  itemCount: peopleControllers.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text('عدد الأشخاص ',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                              height: 50,
                              width: 50,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: peopleControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('المبلغ المدفوع',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Container(
                              height: 40,
                              width: 80,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: paidControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            calculateFare(
                                index); // حساب المبلغ المتبقي عند الضغط على الزر
                          },
                          child: Text(
                            'حساب الباقي',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          remainingAmounts[
                              index], // عرض المبلغ المتبقي لكل مدخل
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 2,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              removeEntry(
                                  index); // إزالة المدخل المحدد باستخدام index
                            },
                            icon: Icon(Icons.remove),
                            tooltip: 'إزالة مدخل',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // عرض مجموع الأشخاص والمبالغ المتبقية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'عدد الأشخاص: ${getTotalPeople()}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'مجموع الباقي: ${getTotalRemaining().toStringAsFixed(2)} جنيه',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: addEntry,
                  icon: Icon(Icons.add),
                  tooltip: 'أضف مدخل جديد',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لحساب الأجرة المتبقية لكل مدخل
  void calculateFare(int index) {
    double fare = double.tryParse(fareController.text) ?? 0;
    int people = int.tryParse(peopleControllers[index].text) ?? 0;
    double paid = double.tryParse(paidControllers[index].text) ?? 0;

    if (fare > 0 && people > 0) {
      double totalFare = fare * people;
      double remainingAmount = paid - totalFare;

      // إذا كانت الأجرة المدفوعة أقل من الأجرة المستحقة، نعرض تحذيرًا
      if (paid < totalFare) {
        _showWarningDialog();
      }

      setState(() {
        remainingAmounts[index] =
            'الباقي: ${remainingAmount.toStringAsFixed(2)} جنيه';
      });
    } else {
      setState(() {
        remainingAmounts[index] = 'من فضلك تأكد من إدخال القيم بشكل صحيح.';
      });
    }
  }

  // دالة لعرض رسالة تحذير
  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تحذير'),
          content: Text('! الأجرة المدفوعة أقل من الأجرة المستحقة'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // إغلاق التحذير عند الضغط على "موافق"
              },
              child: Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  // دالة لإضافة مدخلات جديدة
  void addEntry() {
    setState(() {
      peopleControllers.add(TextEditingController());
      paidControllers.add(TextEditingController());
      remainingAmounts.add(''); // إضافة قيمة فارغة للمبالغ المتبقية
    });
  }

  // دالة لحذف مدخلات جديدة
  void removeEntry(int index) {
    setState(() {
      peopleControllers.removeAt(index);
      paidControllers.removeAt(index);
      remainingAmounts.removeAt(index); // إزالة المدخلات بشكل صحيح
    });
  }

  // دالة لحساب مجموع الأشخاص والمبلغ المتبقي
  double getTotalPeople() {
    int totalPeople = 0;
    for (var controller in peopleControllers) {
      totalPeople += int.tryParse(controller.text) ?? 0;
    }
    return totalPeople.toDouble();
  }

  // دالة لحساب مجموع المبالغ المتبقية
  double getTotalRemaining() {
    double totalRemaining = 0;
    for (int i = 0; i < remainingAmounts.length; i++) {
      double remaining = double.tryParse(remainingAmounts[i]
              .replaceAll('الباقي: ', '')
              .replaceAll(' جنيه', '')) ??
          0;
      totalRemaining += remaining;
    }
    return totalRemaining;
  }
}
