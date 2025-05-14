import 'package:csv/csv.dart';
import 'package:csv/csv_settings_autodetection.dart';
import 'package:flutter/material.dart';

class CompareBook extends StatefulWidget {
  const CompareBook({super.key});

  @override
  State<CompareBook> createState() => _CompareBookState();
}

class _CompareBookState extends State<CompareBook> {


  List<List<dynamic>> csvData = [];

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    try {
      // Get the path to the CSV file in the assets folder
      String data =  await DefaultAssetBundle.of(context).loadString('assets/Amazon_Books_Data.csv');

      var d = FirstOccurrenceSettingsDetector(eols: ['\r\n', '\n'],
          textDelimiters: ['"', "'"]);
      csvData = CsvToListConverter().convert(data, csvSettingsDetector: d, convertEmptyTo: null).where((row) {

        return row.any((element) => element != "");
      })
          .toList();
      // print("csvData == ${csvData}");
    } catch (e) {
      print("Error loading CSV data: $e");
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: csvData.isEmpty
              ? const CircularProgressIndicator()
              : ListView.builder(
            shrinkWrap: true,
            itemCount: csvData.length,
            itemBuilder: (_, index) {
              // Check if the row has a value at index 1
              if (csvData[index].length > 0 && csvData[index].length > 1 && csvData[index].length > 2 && csvData[index].length > 6 && index != 0) {
                return Card(

                  margin: const EdgeInsets.all(3),
                  color: Colors.white,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(csvData[index][0].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(csvData[index].length > 1 ?csvData[index][1].toString() : ""),
                        Text("Author : ${csvData[index].length > 2 ? csvData[index][2].toString() : ""}"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: Text("Edition : ${csvData[index].length > 6 ? csvData[index][6].toString() : ""}", overflow: TextOverflow.ellipsis,)),
                            TextButton(child : Text("Compare"), onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return   DetailComparasion(title: csvData[index][0].toString(), csvData: csvData,);
                              }));
                            },),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              } else {

                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}



class DetailComparasion extends StatelessWidget {
  DetailComparasion({required this.title ,required this.csvData,super.key});
  List<List<dynamic>> csvData;
  String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: csvData.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
          shrinkWrap: true,
          itemCount: csvData.length,

          itemBuilder: (_, index) {
            // Check if the row has a value at index 1
            if (csvData[index].length > 0 && csvData[index].length > 1 && csvData[index].length > 2 && csvData[index].length > 11 && csvData[index].length > 9 && csvData[index].length > 10 ) {
              if(csvData[index][0].toString().toLowerCase() == title.toString().toLowerCase() && title.isNotEmpty) {
                return Card(
                  margin: const EdgeInsets.all(3),
                  color: Colors.white,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(csvData[index][0].toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                        Text(csvData[index].length > 1 ?csvData[index][1].toString() : ""),
                        Text("Author : ${csvData[index].length > 2 ? csvData[index][2].toString() : ""}"),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Edition : ${ csvData[index].length > 6 ? csvData[index][6].toString() : ""}"),
                            Text("${ csvData[index].length > 11 ?csvData[index][11].toString() : ""}"),

                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                "Rating : ${ csvData[index].length > 9 ? csvData[index][9].toString() : ""}"),
                            Text("Review count : ${csvData[index].length > 10 ? csvData[index][10].toString() : ""}"),

                          ],
                        )
                      ],
                    ),
                  ),
                );
              }
              else{
                return Container();
              }
            } else {

              return Container();
            }
          },

        ),
      ),
    );
  }
}
