import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:triosys_invoice/custom_widgets/customWidgets.dart';
import 'package:triosys_invoice/models/headerinfo.dart';
import 'package:triosys_invoice/screens/addItem.dart';

class CreateNewPDF extends StatefulWidget {
  CreateNewPDF({Key key}) : super(key: key);

  @override
  _CreateNewPDFState createState() => _CreateNewPDFState();
}

class _CreateNewPDFState extends State<CreateNewPDF> {
  final _formKey = GlobalKey<FormState>();
  String paymentMethod = "Cash";
  DateTime selectedDate = DateTime.now();
  String formateDate;
  TextEditingController _dateController,
      _invoiceNoController,
      _nameController,
      _addressController,
      _contactController;

  @override
  void initState() {
    _dateController = TextEditingController();
    _invoiceNoController = TextEditingController();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _dateController.text = DateFormat("d/MMM/yyy").format(selectedDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    formateDate = DateFormat("_MMM_d").format(selectedDate);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.navigate_next_sharp),
        onPressed: checkValidation,
      ),
      appBar: AppBar(
        title: Text("Create New Invoice"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: BuildLabelText(label: "Invoice No."),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _invoiceNoController,
                      validator: (val) {
                        if (val.isEmpty) {
                          return "need to fill";
                        }
                        return null;
                      },
                      autofocus: false,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        suffix: Text("$formateDate"),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: BuildLabelText(label: "Payment Method"),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButton(
                      value: paymentMethod,
                      items: [
                        DropdownMenuItem(
                          child: Text("Cash"),
                          value: "Cash",
                        ),
                        DropdownMenuItem(
                          child: Text("Bank Transfer"),
                          value: "Bank Transfer",
                        ),
                      ],
                      onChanged: (String val) {
                        setState(() {
                          paymentMethod = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: BuildLabelText(label: "Date"),
                  ),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectDate(context);
                        });
                      },
                      child: TextFormField(
                        enabled: false,
                        controller: _dateController,
                      ),
                    ),
                  )
                ],
              ),
              Divider(),
              Center(
                  child: Text(
                "Customer Info",
                style: Theme.of(context).textTheme.headline5,
              )),
              buildCustomerInfoField(
                "Name.",
                controller: _nameController,
                validator: (val) {
                  if (val.isEmpty) {
                    return "need to fill";
                  }
                  return null;
                },
              ),
              buildCustomerInfoField(
                "Address.",
                controller: _addressController,
                maxLines: 2,
              ),
              buildCustomerInfoField(
                "Contact.",
                controller: _contactController,
                validator: (val) {
                  if (val.isEmpty) {
                    return "need to fill";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  checkValidation() {
    if (_formKey.currentState.validate()) {
      String invoiceNo = _invoiceNoController.text + formateDate;
      String payment = paymentMethod;
      String date = _dateController.text;
      String name = _nameController.text;
      String address = "";
      if (_addressController.text != null) {
        address = _addressController.text;
      }
      String contact = _contactController.text;

      HeaderInfo headerInfo = HeaderInfo(
        invoiceNo: invoiceNo,
        payment: payment,
        date: date,
        customerName: name,
        customerAddress: address,
        customerContact: contact,
      );
      clearText();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddItem(
            headerInfo: headerInfo,
          ),
        ),
      );
    }
  }

  clearText() {
    _invoiceNoController.clear();
    _dateController.clear();
    _nameController.clear();
    _addressController.clear();
    _contactController.clear();
  }

  Row buildCustomerInfoField(String label,
      {TextEditingController controller,
      int maxLines,
      Function(String) validator}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: BuildLabelText(label: label),
        ),
        Expanded(
          flex: 2,
          child: TextFormField(
            autocorrect: false,
            controller: controller,
            validator: validator,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }

  Future _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat("d/MMM/yyy").format(selectedDate);
      });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _invoiceNoController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
