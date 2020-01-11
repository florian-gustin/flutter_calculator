import 'package:flutter/material.dart';
import 'package:flutter_calculator/models/my_number.dart';
import 'package:flutter_calculator/models/operations.dart';
import 'package:flutter_calculator/widgets/display.dart';
import 'package:flutter_calculator/widgets/key_pad.dart';
import 'constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Calculator(title: 'Calculator'),
    );
  }
}

class Calculator extends StatefulWidget {

  final String title;

  Calculator({@required this.title});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {

  MyNumber currentNumber;
  bool processingIsActive = false;
  List logs = <String>[];
  List<dynamic> sequences = [null, null, null];
  var index;


  void allClear(){
    setState(() {
      index = null;
      processingIsActive = false;
      sequences = [null, null, null];
    });

  }

  void clear(){
    if(sequences[0]!= null && sequences[1] == null){
      allClear();
    }else if(sequences[1] != null){
      setState(() {
        processingIsActive = false;
        sequences = [sequences[0], null, null];
        index = sequences[0];
      });
    }else if(sequences[2]!= null){
      allClear();
    }
  }

  resultOperation(){
    if(sequences[2]==null)
      return;

    num res;
    switch(sequences[1]){
      case 'divide' :
        res = Operations.divide(nbLeft: sequences[0].number, nbRight: sequences[2].number);
        break;
      case 'multiply':
        res = Operations.multiply(nbLeft: sequences[0].number, nbRight: sequences[2].number);
        break;
      case 'substract':
        res = Operations.substract(nbLeft: sequences[0].number, nbRight: sequences[2].number);
        break;
      case 'addition':
        res = Operations.addition(nbLeft: sequences[0].number, nbRight: sequences[2].number);
        break;
    }

    if(res!=null){
      setState(() {
        sequences = [MyNumber(numberStr: res.toString()), null, null];
        index = sequences[0];
      });
    }
  }

  addLeft(num nb){
    sequences[0] = nb.toString();
  }
  addOperation(String operation){
    sequences[1] = operation;
  }
  addRight(num nb){
    sequences[2] = nb.toString();
  }


  void getValuePressed(String string){

    switch(string){
      case 'AC':
        allClear();
        break;
      case 'C':
        clear();
        break;
      case '+/-':
        if(index == null){
          return;
        }else{
          if(index == sequences[0]){
            sequences[0] = MyNumber(numberStr: sequences[0].numberStr).posNeg();
          }else if(index == sequences[2]){
            sequences[2] = MyNumber(numberStr: sequences[0].numberStr).posNeg();
          }
        }
        break;
      case '%':
        if(index == null){
          return;
        }else{
          if(index == sequences[0]){
            num res = Operations.pourcentage(nb: sequences[0].number);
            sequences[0] = MyNumber(numberStr: res.toString());
          }else if(index == sequences[2]){
//            num res = Operations.pourcentage(nb: sequences[2].number);
//            sequences[2] = MyNumber(numberStr: res.toString());
          }
        }

        break;
      case '/':
        if(index == sequences[0]){
          setState(() {
            sequences[1] = 'divide';
          });
        }else if(index == sequences[2]){
          resultOperation();
          setState(() {
            sequences[1] = 'divide';
          });
        }
        break;
      case 'x':
        if(index == sequences[0]){
          setState(() {
            sequences[1] = 'multiply';
          });
        }else if(index == sequences[2]){
          resultOperation();
          setState(() {
            sequences[1] = 'multiply';
          });
        }
        break;
      case '-':
        if(index == sequences[0]){
          setState(() {
            sequences[1] = 'substract';
          });
        }else if(index == sequences[2]){
          resultOperation();
          setState(() {
            sequences[1] = 'substract';
          });
        }
        break;
      case '+':
        if(index == sequences[0]){
          setState(() {
            sequences[1] = 'addition';
          });
        }else if(index == sequences[2]){
          resultOperation();
          setState(() {
            sequences[1] = 'addition';
          });
        }
        break;
      case '=':
        resultOperation();
        break;
      case ',':
        if(sequences[0]!=null && sequences[1] == null){
          if(!sequences[0].modeDecimal){
            setState(() {
              index.toDecimal();
            });
          }
        }else if(sequences[0] == null && sequences[1] == null){
          setState(() {
            sequences[0] = MyNumber(numberStr: '0');
            index = sequences[0];
            index.toDecimal();
          });
        }else if(sequences[2]!=null && sequences[1] != null){
          if(!sequences[2].modeDecimal){
            setState(() {
              index.toDecimal();
            });
          }
        }else if(sequences[2] == null && sequences[1] != null){
          setState(() {
            sequences[2] = MyNumber(numberStr: '0');
            index = sequences[2];
            index.toDecimal();
          });
        }
        break;
      default: {
        processingIsActive = true;
        // si ya rien encore de tapé
        if(sequences[0] == null) {
          setState(() {
            sequences[0] = MyNumber(numberStr: string);
            index = sequences[0];
          });
          // si l index est 0
        }else if(sequences[0] == index && sequences[1] == null && sequences[2] == null){
          if(index.modeDecimal){
            setState(() {
              index.addToTheRightAsDecimals(string);
            });
          }else{
            setState(() {
              index.addToTheLeftAsInts(string);
            });
          }
        }else if(sequences[1] != null){
          print('--->');
          if(sequences[2] == null){
            setState(() {
              sequences[2] = MyNumber(numberStr: string);
              index = sequences[2];
            });
          }else if(index.modeDecimal){
            setState(() {
              index.addToTheRightAsDecimals(string);
            });
          }else{
            setState(() {
              index.addToTheLeftAsInts(string);
            });
          }

        }
      }
    }
    print('index : $index');
    print('seq 0 : ${sequences[0]}');
    print('seq 1 : ${sequences[1]}');
    print('seq 2 : ${sequences[2]}');
  }

  String applyIndex(){
    if(index == null){
      return '0';
    }else if(index == sequences[0]){
      return sequences[0].numberStr;
    }else if(index == sequences[1]){
      return sequences[0].numberStr;
    }else if(index == sequences[2]){
      return sequences[2].numberStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Display(currentNumber: applyIndex()),
          SizedBox(height: 20.0,),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for(int i = 0 ; i < 4; i++)
                      myKeyList[i] == 'AC'?
                        KeyPad(
                          onPressed: () => getValuePressed((processingIsActive? 'C' : 'AC')),
                          label: (processingIsActive? 'C' : 'AC'),
                          backgroundColor: Colors.orange,
                        )
                        :
                        KeyPad(
                          onPressed: () => getValuePressed(myKeyList[i]),
                          label: myKeyList[i],
                          backgroundColor: (myKeyList[i] != '/'? Colors.black87 : Colors.orange),
                        )
                  ],
                ),
                SizedBox(height: 5.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for(int i = 4 ; i < 8; i++)
                      KeyPad(
                        onPressed: () => getValuePressed(myKeyList[i]),
                        label: myKeyList[i],
                        backgroundColor: (myKeyList[i] != 'x'? Colors.blueAccent[200] : Colors.orange),
                      )
                  ],
                ),
                SizedBox(height: 5.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for(int i = 8 ; i < 12; i++)
                      KeyPad(
                        onPressed: () => getValuePressed(myKeyList[i]),
                        label: myKeyList[i],
                        backgroundColor: (myKeyList[i] != '-'? Colors.blueAccent[200] : Colors.orange),
                      )
                  ],
                ),
                SizedBox(height: 5.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for(int i = 12 ; i < 16; i++)
                      KeyPad(
                        onPressed: () => getValuePressed(myKeyList[i]),
                        label: myKeyList[i],
                        backgroundColor: (myKeyList[i] != '+'? Colors.blueAccent[200] : Colors.orange),
                      )
                  ],
                ),
                SizedBox(height: 5.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for(int i = 16 ; i < 20; i++)
                      myKeyList[i] == ''?
                        KeyPad(onPressed: (){}, label: '', backgroundColor: Colors.black87,)
                            :
                        KeyPad(
                          onPressed: () => getValuePressed(myKeyList[i]),
                          label: myKeyList[i],
                          backgroundColor: (myKeyList[i] != '='? Colors.blueAccent[200] : Colors.orange),
                        )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
