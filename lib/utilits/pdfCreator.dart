import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:triosys_invoice/models/headerinfo.dart';
import 'package:triosys_invoice/models/itemInfo.dart';

class PDFCreator {
  final HeaderInfo headerInfo;
  final List<ItemInfo> itemInfo;
  bool isPaid = false;

  pw.Document pdf = pw.Document();

  PDFCreator({this.headerInfo, this.itemInfo, this.isPaid});

  int totalAmount = 0;
  List totalList = [];

  calcuateItemData() {
    final data = itemInfo.map((e) {
      int amount = num.parse(e.amount);
      final total = amount * e.qty;
      totalList.add(total);
      return [
        itemInfo.indexOf(e) + 1,
        e.desc,
        e.qty,
        e.amount,
        total,
      ];
    }).toList();
    totalList.forEach((e) {
      totalAmount += e;
    });
    return data;
  }

  createPDF() async {
    final svgImage =
        await rootBundle.loadString('images/logo-transparent-black.svg');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 160,
                    height: 100,
                    // color: PdfColors.grey300,
                    child: pw.SvgImage(
                      svg: svgImage,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Column(children: [
                    pw.Text(
                      'T R I O S Y S',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 20.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'IT Services and Solutions',
                      style:
                          pw.TextStyle(color: PdfColors.black, fontSize: 18.0),
                    ),
                    pw.Text(
                      'support@triosys.info',
                      style:
                          pw.TextStyle(color: PdfColors.blue, fontSize: 18.0),
                    ),
                    pw.Text(
                      '09-777400744',
                      style:
                          pw.TextStyle(color: PdfColors.black, fontSize: 18.0),
                    ),
                  ])
                ],
              ),
            ),
            pw.Center(
              child: pw.Paragraph(
                text: "INVOICE",
                style: pw.TextStyle(color: PdfColors.blue300, fontSize: 24.0),
              ),
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Paragraph(
                      text: "Customer",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    pw.Paragraph(text: "${headerInfo.customerName}"),
                    pw.Paragraph(text: "${headerInfo.customerAddress}"),
                    pw.Paragraph(text: "${headerInfo.customerContact}"),
                  ],
                ),
                pw.Table(
                  border: pw.TableBorder.all(),
                  tableWidth: pw.TableWidth.max,
                  children: [
                    pw.TableRow(
                      children: [
                        customTableText("Invoice No."),
                        customTableText("${headerInfo.invoiceNo}"),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        customTableText("Date"),
                        customTableText("${headerInfo.date}"),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        customTableText("Payment Method"),
                        customTableText("${headerInfo.payment}"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            pw.Stack(
              children: [
                pw.Table.fromTextArray(
                  headers: ["NO.", "Description", "Qty", "Price", "Amount"],
                  data: calcuateItemData(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  border: null,
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerRight,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                    4: pw.Alignment.centerRight,
                  },
                ),
                if (isPaid)
                  pw.SizedBox(
                    height: 150,
                    child: pw.Watermark(
                        angle: math.pi / 8,
                        child: pw.Opacity(
                          opacity: 0.3,
                          child: pw.Container(
                            padding: pw.EdgeInsets.all(10.0),
                            child: pw.Text(
                              "PAID",
                              style: pw.TextStyle(
                                color: PdfColors.grey,
                                fontSize: 60.0,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            // decoration: pw.BoxDecoration(
                            //   border: pw.Border.all(
                            //       color: PdfColors.grey, width: 3.0),
                            // ),
                          ),
                        )),
                  ),
              ],
            ),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 160.0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    buildAmountText("Net Total", "$totalAmount"),
                    buildAmountText("Discount", ""),
                    pw.Divider(),
                    buildAmountText("Total Amount", "$totalAmount"),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 40.0),
            invoiceFooter(),
          ];
        },
      ),
    );
  }

  pw.Row invoiceFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Co-operative Bank Ltd., (CB Bank)"),
            buildAmountText("Account Name :", ""),
            buildAmountText("Account No. :", "")
          ],
        ),
        pw.Container(
            padding: pw.EdgeInsets.all(20.0),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  "Issued by",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text("T R I O S Y S"),
              ],
            ))
      ],
    );
  }

  pw.Row buildAmountText(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label), pw.Text(value)],
    );
  }

  pw.Padding customTableText(String text) {
    return pw.Padding(
      child: pw.Text(text),
      padding: pw.EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
    );
  }

  Future savePDF() async {
    Directory documentDir = await getApplicationDocumentsDirectory();
    String documentDirPath = documentDir.path;
    File file = File("$documentDirPath/${headerInfo.invoiceNo}.pdf");
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);
    return documentDirPath;
  }
}
