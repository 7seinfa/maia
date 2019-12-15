import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/scheduler.dart' show timeDilation;



String api = "https://api.maia-app.co/api/";

void main(){
  timeDilation=2.0;
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        primaryIconTheme: IconThemeData(
          color: Colors.blue
        ),
        primaryTextTheme: TextTheme(
          title: TextStyle(color: Colors.blue),
          subhead: TextStyle(color: Colors.grey),
          headline: TextStyle(color: Colors.grey, fontSize: 18)
        ),
      ),
      home: LogIn(),
    );
  }
}

class LogIn extends StatefulWidget {
  LogIn({Key key}) : super(key: key);
  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController idController = new TextEditingController(); 
  void initState(){
    idController.text="49FSA92";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MAIA", textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Doctor Login", style: Theme.of(context).primaryTextTheme.subhead,),
          Padding(
            padding: EdgeInsets.only(left: 60, right: 60, top: 15),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                controller: idController,
                textAlign: TextAlign.center,
                decoration: InputDecoration.collapsed(
                  hintText: "Please enter your doctor ID",
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: InkWell(
              onTap: (){

                Navigator.of(context).push(_createRoute(PatientList(idController.text)));
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(
                    colors: [Colors.blue[600], Colors.blue[800]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  )
                ),
                child: Text("Login", style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ),
          )
          
        ],
      )
    );
  }
}

class PatientList extends StatefulWidget {
  final String id;
  PatientList(this.id, {Key key}) : super(key: key);

  @override
  _PatientListState createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  List<Patient> patients = [];
  @override
  void initState(){
    print(widget.id);
    recieveData();
    super.initState();
  }

  Future<String> recieveData() async{
    var client = new http.Client();

    try {
      var uriResponse = await client.get(api+"patients/", headers: {'Authorization': widget.id});
    List<dynamic> patientList = jsonDecode(uriResponse.body);
      for (int i = 0; i<patientList.length;i++){
        Patient patientObject = Patient.fromJSON(patientList[i]);
        patients.add(patientObject);
      }
    } finally {
      client.close();
    }
    setState(() {
      
    });
    return "hi";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Patients", textAlign: TextAlign.center,),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              Navigator.of(context).push(_createRoute(AddPatient(widget.id)));
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (BuildContext context, int index){
          return Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5),
            child: InkWell(
              onTap: () => {
                Navigator.of(context).push(_createRoute(PatientInfo(widget.id, patients[index])))
              },
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.grey[200])
                ),
                child: Column(
                  children: <Widget>[
                    Text(patients[index].firstName + " " + patients[index].lastName + "\n(" + patients[index].id + ")", style: TextStyle(fontSize: 16),textAlign: TextAlign.center,),
                  ],
                ),
              ),
            ),
          );
        }
      )
    );
  }
}

class AddPatient extends StatefulWidget {
  final String id;
  AddPatient(this.id, {Key key}) : super(key: key);

  @override
  _AddPatientState createState() => _AddPatientState();
}

class _AddPatientState extends State<AddPatient> {
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _dateOfBirthController = new TextEditingController();
  @override
  void initState(){
    super.initState();
  }

  Future<String> submitData() async{
    Patient newPatient = new Patient(_firstNameController.text, _lastNameController.text, _dateOfBirthController.text, [],[{"ID": widget.id}]);

    var newObject = json.encode(newPatient.toJSON());
    var map = new Map<String, dynamic>();
    map['patient'] = newObject;

    var client = new http.Client();
    try {
      var uriResponse = await client.post(api+"patients/", headers: {'Authorization': widget.id, "content-Type": "application/x-www-form-urlencoded"}, body: map);
    } finally {
      client.close();
    }
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(_createRoute(PatientList(widget.id)), ModalRoute.withName("/"));
    });
    return "true";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a Patient", textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Last Name:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 25),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                controller: _lastNameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter last name",
                ),
              ),
            ),
          ),
          Text("First Name:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 25),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _firstNameController,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter first name"
                ),
              ),
            ),
          ),
          Text("Date of birth:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _dateOfBirthController,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter in format: DD Month YYYY"
                ),
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: ()async{
                await submitData();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(
                    colors: [Colors.blue[600], Colors.blue[800]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  )
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ),
          )
        ],
      )
    );
  }
}

class PatientInfo extends StatefulWidget {
  final String id;
  final Patient patient;
  PatientInfo(this.id, this.patient, {Key key}) : super(key: key);

  @override
  _PatientInfoState createState() => _PatientInfoState();
}

class _PatientInfoState extends State<PatientInfo> {
  Patient patient;
  @override
  void initState(){
    patient = widget.patient;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Info", textAlign: TextAlign.center,),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              Navigator.of(context).push(_createRoute(AddVisits(widget.id, patient)));
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.of(context).push(_createRoute(EditPatient(widget.id, widget.patient)));
            },
          )
        ],
      ),
      body: patient.history.length>0?ListView.builder(
        itemCount: patient.history.length,
        itemBuilder: (BuildContext context, int index){
          return Column(
            children: <Widget>[
              index==0?Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Patient Info", style: Theme.of(context).primaryTextTheme.headline),
                    ),
                    
                    Container(
                      width: MediaQuery.of(context).size.width*0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey[200])
                      ),
                      child: Padding(
                        child: Column(
                          children: <Widget>[
                            Text(patient.firstName + " " + patient.lastName+"\nDate of Birth: " + patient.dateOfBirth+"\nAge: " + (((DateTime.now().difference(DateTime.parse(patient.dateOfBirth.split(" ")[2]+"-"+monthInt(patient.dateOfBirth.split(" ")[1])+"-"+patient.dateOfBirth.split(" ")[0])).inDays)/365).round().toString()), style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                          ],
                        ),
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                      ),
                      
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Past Visits", style: Theme.of(context).primaryTextTheme.headline),
                    ),
                  ]
                ),
              )
              :Container(),
              InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey[200])
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(patient.history[index].date+"\nDoctor: " + patient.history[index].doctor+"\nSymptoms: " + patient.history[index].symptoms.toString()+"\nFirst Diagnosis: " + patient.history[index].firstDiagnosis+"\nFinal Diagnosis: " + patient.history[index].finalDiagnosis, style: TextStyle(fontSize: 16), textAlign: TextAlign.center)
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                ),
              )
            ],
          );
        }
      ):Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("Patient Info", style: Theme.of(context).primaryTextTheme.headline),
                ),
                
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.grey[200])
                  ),
                  child: Padding(
                    child: Column(
                      children: <Widget>[
                        Text(patient.firstName + " " + patient.lastName+"\nDate of Birth: " + patient.dateOfBirth+"\nAge: " + (((DateTime.now().difference(DateTime.parse(patient.dateOfBirth.split(" ")[2]+"-"+monthInt(patient.dateOfBirth.split(" ")[1])+"-"+patient.dateOfBirth.split(" ")[0])).inDays)/365).round().toString()), style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                      ],
                    ),
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                )
              ]
            )
          )
        ]
      )  
    );
  }
}

class EditPatient extends StatefulWidget {
  final String id;
  final Patient patient;
  EditPatient(this.id, this.patient, {Key key}) : super(key: key);

  @override
  _EditPatientState createState() => _EditPatientState();
}

class _EditPatientState extends State<EditPatient> {
  TextEditingController _lastNameController = new TextEditingController();
  TextEditingController _firstNameController = new TextEditingController();
  TextEditingController _dateOfBirthController = new TextEditingController();
  @override
  void initState(){
    _lastNameController.text=widget.patient.lastName;
    _firstNameController.text=widget.patient.firstName;
    _dateOfBirthController.text=widget.patient.dateOfBirth;
    super.initState();
  }

  Future<String> submitData() async{
    Patient newPatient = new Patient(_firstNameController.text, _lastNameController.text, _dateOfBirthController.text, widget.patient.history,[{"ID": widget.id}], id: widget.patient.id);
    print(newPatient.id);
    var newObject = json.encode(newPatient.toJSON());
    var map = new Map<String, dynamic>();
    map['patient'] = newObject;

    var client = new http.Client();
    try {
      var uriResponse = await client.put(api+"patients/"+newPatient.id, headers: {'Authorization': widget.id, "content-Type": "application/x-www-form-urlencoded"}, body: map);
    } finally {
      client.close();
    }
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(_createRoute(PatientList(widget.id)), ModalRoute.withName("/"));
      Navigator.of(context).push(_createRoute(PatientInfo(widget.id, newPatient)));
    });
    return "true";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit a Patient", textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Last Name:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 25),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                controller: _lastNameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter last name",
                ),
              ),
            ),
          ),
          Text("First Name:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 25),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _firstNameController,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter first name"
                ),
              ),
            ),
          ),
          Text("Date of birth:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _dateOfBirthController,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter in format: DD Month YYYY"
                ),
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: ()async{
                await submitData();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(
                    colors: [Colors.blue[600], Colors.blue[800]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  )
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ),
          )
        ],
      )
    );
  }
}


class AddVisits extends StatefulWidget {
  final String id;
  final Patient patient;
  AddVisits(this.id, this.patient, {Key key}) : super(key: key);

  @override
  _AddVisitsState createState() => _AddVisitsState();
}

class _AddVisitsState extends State<AddVisits> {
  TextEditingController _symptomsController = new TextEditingController();
  TextEditingController _firstDiagnosisController = new TextEditingController();
  TextEditingController _finalDiagnosisController = new TextEditingController();
  @override
  void initState(){
    super.initState();
  }

  Future<String> submitData() async{
    DateTime curDate = DateTime.now();
    String curDateString = month(curDate.month) + " " + curDate.day.toString() + ", " + curDate.year.toString();
    List<String> symptoms = _symptomsController.text.split(",");
    Visits newVisit = new Visits(date: curDateString, doctor: widget.id, symptoms: symptoms, firstDiagnosis: _firstDiagnosisController.text, finalDiagnosis: _finalDiagnosisController.text);
    List<Visits> newVisitList = widget.patient.history + [newVisit];
    Patient newPatient = new Patient(widget.patient.firstName, widget.patient.lastName, widget.patient.dateOfBirth, newVisitList, widget.patient.doctors, id: widget.patient.id);

    var newObject = json.encode(newPatient.toJSON());
    var map = new Map<String, dynamic>();
    map['patient'] = newObject;

    var client = new http.Client();
    try {
      var uriResponse = await client.put(api+"patients/"+widget.patient.id+"/", headers: {'Authorization': widget.id, "content-Type": "application/x-www-form-urlencoded"}, body: map);
    } finally {
      client.close();
    }
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(_createRoute(PatientList(widget.id)), ModalRoute.withName("/"));
      Navigator.of(context).push(_createRoute(PatientInfo(widget.id, newPatient)));
    });
    return "true";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a Visit", textAlign: TextAlign.center,),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Symptoms:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 25),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                controller: _symptomsController,
                textAlign: TextAlign.center,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter symptomes seperated by commas (,)",
                ),
              ),
            ),
          ),
          Text("First Diagnosis:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 5, bottom: 25),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _firstDiagnosisController,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter first diagnosis"
                ),
              ),
            ),
          ),
          Text("Final Diagnosis:", style: Theme.of(context).primaryTextTheme.headline),
          Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: TextField(
                textAlign: TextAlign.center,
                controller: _finalDiagnosisController,
                decoration: InputDecoration.collapsed(
                  hintText: "Enter final diagnosis"
                ),
              ),
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: InkWell(
              onTap: ()async{
                await submitData();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  gradient: LinearGradient(
                    colors: [Colors.blue[600], Colors.blue[800]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  )
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
            ),
          )
        ],
      )
    );
  }
}

Route _createRoute(var a) {
  return PageRouteBuilder(
    pageBuilder: (context, ani, ani2) => a,
    transitionsBuilder: (context, ani, ani2, child) {
      var begin = Offset(0.0, 1);
      var end = Offset.zero;
      var curve = Curves.easeIn;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: ani.drive(tween),
        child: child,
      );
    },
  );
}

class Patient{
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String id;
  final List<Visits> history;
  final List doctors;
  Patient(this.firstName,this.lastName,this.dateOfBirth,this.history,this.doctors, {this.id});

  Patient.fromJSON(Map<dynamic, dynamic> json):
    firstName=json["FirstName"],
    lastName=json["LastName"],
    dateOfBirth=json["DateOfBirth"],
    id=json["ID"],
    doctors=json["Doctors"],
    history=Visits().fromJSON(json["History"]);

  Map toJSON(){
    List<Map> visits = [];
    for(int i = 0; i<history.length; i++){
      visits.add({
        "Date": history[i].date,
        "Doctor": history[i].doctor,
        "Symptoms": history[i].symptoms,
        "FirstDiagnosis": history[i].firstDiagnosis,
        "FinalDiagnosis": history[i].finalDiagnosis,
      });
    }
    return {
      "FirstName": firstName,
      "LastName": lastName,
      "DateOfBirth": dateOfBirth,
      "History": visits,
      "Doctors": doctors
    };
  }
}

class Visits{
  final String date;
  final String doctor;
  final List<dynamic> symptoms;
  final String firstDiagnosis;
  final String finalDiagnosis;
  Visits({this.date, this.doctor, this.symptoms, this.firstDiagnosis, this.finalDiagnosis});

  List<Visits> fromJSON(List<dynamic> json){
    List<Visits> vList = [];
    for(int i = 0; i<json.length; i++){
      Visits v = new Visits(date: json[i]["Date"], doctor: json[i]["Doctor"], symptoms: json[i]["Symptoms"], firstDiagnosis: json[i]["FirstDiagnosis"], finalDiagnosis: json[i]["FinalDiagnosis"]);
      vList.add(v);
    }
    return vList;
  }
}

String month(int i){
  String m;
  switch(i){
    case 1: {m="January";}break;
    case 2: {m="February";}break;
    case 3: {m="March";}break;
    case 4: {m="April";}break;
    case 5: {m="May";}break;
    case 6: {m="June";}break;
    case 7: {m="July";}break;
    case 8: {m="August";}break;
    case 9: {m="September";}break;
    case 10: {m="October";}break;
    case 11: {m="November";}break;
    case 12: {m="December";}break;
  }
  return m;
}

String monthInt(String i){
  String m;
  switch(i){
    case "January": {m="01";}break;
    case "February": {m="02";}break;
    case "March": {m="03";}break;
    case "April": {m="04";}break;
    case "May": {m="05";}break;
    case "June": {m="06";}break;
    case "July": {m="07";}break;
    case "August": {m="08";}break;
    case "September": {m="09";}break;
    case "October": {m="10";}break;
    case "November": {m="11";}break;
    case "December": {m="12";}break;
  }
  return m;
}