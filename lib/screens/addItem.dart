import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:triosys_invoice/custom_widgets/customWidgets.dart';
import 'package:triosys_invoice/models/headerinfo.dart';
import 'package:triosys_invoice/models/itemInfo.dart';
import 'package:triosys_invoice/utilits/pdfCreator.dart';

class AddItem extends StatefulWidget {
  final HeaderInfo headerInfo;

  AddItem({this.headerInfo});

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final _formKey = GlobalKey<FormState>();
  int qty = 1;
  bool isPerfect = false;
  bool isPaid = false;
  TextEditingController _descController, _amountController;
  // List<Widget> children = [];
  List<ItemInfo> items = [];

  @override
  void initState() {
    _descController = TextEditingController();
    _amountController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: isPerfect
            ? () async {
                PDFCreator pdfCreator = PDFCreator(
                  headerInfo: widget.headerInfo,
                  itemInfo: items,
                  isPaid: isPaid,
                );
                pdfCreator.createPDF();
                String filePath = await pdfCreator.savePDF();
                setState(() {
                  clearText();
                });
                OpenFile.open("$filePath/${widget.headerInfo.invoiceNo}.pdf");
              }
            : null,
        child: Icon(Icons.save),
      ),
      appBar: AppBar(
        title: Text("Add Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: BuildLabelText(label: "Description"),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _descController,
                      validator: (val) {
                        if (val.isEmpty) {
                          return "need to fill";
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: BuildLabelText(label: "Amount"),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      validator: (val) {
                        if (val.isEmpty) {
                          return "need to fill";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // flex: 2,
                    child: BuildLabelText(label: "Qty"),
                  ),
                  Expanded(
                    // flex: 3,
                    child: Container(
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                qty++;
                              });
                            },
                          ),
                          Text(
                            "$qty",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (qty > 0) {
                                  qty--;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      validationItem();
                      print(isPaid);
                    });
                  },
                  child: Text("Add"),
                ),
              ),
              Divider(
                thickness: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BuildLabelText(label: "Paid"),
                  Checkbox(
                    value: isPaid,
                    onChanged: (val) {
                      setState(() {
                        isPaid = val;
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    List<Widget> itemWidgets = items
                        .map((e) => ListTile(
                              title: Text(e.desc),
                              subtitle: Text(e.amount),
                              trailing: Text("${e.qty}"),
                            ))
                        .toList();
                    return Row(
                      children: [
                        Expanded(child: itemWidgets[index]),
                        IconButton(
                          padding: EdgeInsets.all(0.0),
                          color: Colors.red,
                          splashRadius: 20,
                          iconSize: 20.0,
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              items.remove(items[index]);
                            });
                          },
                        ),
                      ],
                    );
                  },
                  itemCount: items.length,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  clearText() {
    _descController.clear();
    _amountController.clear();
    this.qty = 1;
    items.clear();
  }

  validationItem() {
    if (_formKey.currentState.validate()) {
      String desc = _descController.text;
      String amount = _amountController.text;
      int qty = this.qty;
      ItemInfo itemInfo = ItemInfo(
        desc: desc,
        amount: amount,
        qty: qty,
      );
      items.add(itemInfo);
      if (items.isNotEmpty) {
        setState(() {
          isPerfect = true;
        });
      }
      _descController.clear();
      _amountController.clear();
      this.qty = 1;
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
