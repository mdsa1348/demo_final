import 'package:demo/ThemeSwitch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BMICalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      home: BMICalculator(),
    );
  }
}

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  double height = 150.0;
  double weight = 60.0;
  double bmi = 0.0;
  String result = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('BMI Calculator'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900] // Dark theme background color
                : Colors.blue, // Light theme background color
          ),
          body: Container(
            color: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[900]
                : Colors.white,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Height',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${height.toInt()}',
                                style: TextStyle(
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' cm',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                ' (${(height / 30.48).floor()}\' ${(height % 30.48 / 2.54).round()}")',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: height,
                            min: 120.0,
                            max: 220.0,
                            onChanged: (double value) {
                              setState(() {
                                height = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScaleButton(
                                onTap: () {
                                  setState(() {
                                    if (weight > 30.0) {
                                      weight -= 1.0;
                                    }
                                  });
                                },
                                icon: Icons.remove,
                              ),
                              SizedBox(width: 16.0),
                              ScaleWidget(
                                weight: weight,
                                onChange: (double newWeight) {
                                  setState(() {
                                    weight = newWeight;
                                  });
                                },
                              ),
                              SizedBox(width: 16.0),
                              ScaleButton(
                                onTap: () {
                                  setState(() {
                                    weight += 1.0;
                                  });
                                },
                                icon: Icons.add,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    calculateBMI();
                  },
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFEB1555),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: 80.0,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'CALCULATE BMI',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: getBMIColor(),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  height: 80.0,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your BMI: ${bmi.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        getBMICategory(),
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color getBMIColor() {
    if (bmi < 18.5) {
      return const Color.fromARGB(255, 228, 216, 114);
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return Colors.green;
    } else if (bmi >= 25.0 && bmi < 29.9) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String getBMICategory() {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal';
    } else if (bmi >= 25.0 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  void calculateBMI() {
    double heightInMeters = height / 100.0;
    double bmiResult = weight / (heightInMeters * heightInMeters);

    setState(() {
      bmi = bmiResult;
    });
  }
}

class ScaleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const ScaleButton({required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF4C4F5E),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ScaleWidget extends StatefulWidget {
  final double weight;
  final ValueChanged<double> onChange;

  const ScaleWidget({
    Key? key,
    required this.weight,
    required this.onChange,
  }) : super(key: key);

  @override
  _ScaleWidgetState createState() => _ScaleWidgetState();
}

class _ScaleWidgetState extends State<ScaleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Weight',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
          Text(
            '${widget.weight.toInt()} kg',
            style: TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Slider(
            value: widget.weight,
            min: 30.0,
            max: 150.0,
            onChanged: (double value) {
              widget.onChange(value);
            },
          ),
        ],
      ),
    );
  }
}
