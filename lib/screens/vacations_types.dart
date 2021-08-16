import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kayan_hr/components/loading.dart';
import 'package:kayan_hr/models/vacation_model.dart';

class VacationsTypes extends StatefulWidget {
  const VacationsTypes({Key? key}) : super(key: key);
  static const String id = 'show_vacations';

  @override
  _VacationsTypesState createState() => _VacationsTypesState();
}

class _VacationsTypesState extends State<VacationsTypes> {
  List<DataRow> vacationsRows = [];

  void updateUI() async {
    final vacationsTypes = await VacationModel.getVacationsTypes();
    vacationsTypes.forEach((vac) {
      setState(() {
        vacationsRows.add(
          DataRow(
            cells: <DataCell>[
              DataCell(Text(vac.data()['id'].toString())),
              DataCell(Text(vac.data()['type'])),
              DataCell(Text(vac.data()['no_of_days'] == '' ? '--' : vac.data()['no_of_days'].toString())),
            ],
          ),
        );
      });
    });
  }

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('vacations_types_title')),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        color: Colors.white,
        child: vacationsRows.isEmpty
            ? loading()
            : DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      tr('vacation_type'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      tr('vacation_no_of_days'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                rows: vacationsRows,
              ),
      ),
    );
  }
}
