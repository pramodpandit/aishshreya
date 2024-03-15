import 'dart:io';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/utils/image_icons.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfInvoiceApi {
  // static Future<File>
  static Future<pw.Document> generateInvoice(ServiceDetail serviceDetail, List<TransactionDetail> transactions) async {
    final pdf = pw.Document();

    final iconImage =
    (await rootBundle.load(AppImages.logo)).buffer.asUint8List();

    final tableHeaders = [
      'Description',
      'Date',
      'Amount',
    ];

    List<List<dynamic>> tableData = [];

    // tableData.add([
    //   "${serviceDetail.name}",
    //   "${serviceDetail.amount}",
    //   "${serviceDetail.amount}",
    // ]);

    for(var tr in transactions) {
      if(tr.status=='Active') {
        tableData.add([
          "${tr.description}",
          tr.createdAt==null? '': "${DateFormat('dd-MMM-yyyy').format(DateTime.parse(tr.createdAt ?? ''))}",
          "${tr.type=="service" ? '+' : '-'}₹${tr.amount}"
        ]);
      }
    }





    pdf.addPage(
      pw.MultiPage(
        // header: (context) {
        //   return pw.Text(
        //     'Flutter Approach',
        //     style: pw.TextStyle(
        //       fontWeight: pw.FontWeight.bold,
        //       fontSize: 15.0,
        //     ),
        //   );
        // },
        theme: pw.ThemeData.withFont(
          base: await PdfGoogleFonts.robotoRegular(),
          bold: await PdfGoogleFonts.robotoBold(),
          icons: await PdfGoogleFonts.materialIcons(),
        ),
        build: (context) {
          return [
            pw.Row(
              children: [
                // pw.ClipRRect(
                //   horizontalRadius: 10,
                //   verticalRadius: 10,
                //   child: pw.Image(
                //     pw.MemoryImage(iconImage),
                //     height: 72,
                //     width: 72,
                //     fit: pw.BoxFit.cover,
                //   ),
                // ),
                // pw.SizedBox(width: 2 * PdfPageFormat.mm),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'AishShreya',
                      style: pw.TextStyle(
                        fontSize: 17.0,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Service Invoice',
                      style: const pw.TextStyle(
                        fontSize: 15.0,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Invoice #${(serviceDetail.id??0) + 1000000}',
                      style: pw.TextStyle(
                        fontSize: 15.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Invoice Date',
                    ),
                    pw.Text(
                      "${DateFormat("yyyy MMM dd").format(DateTime.now())}",
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1)
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 10),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 2 * PdfPageFormat.mm),
                          child: pw.Text("Client Detail"),
                        ),
                        pw.Divider(),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 2 * PdfPageFormat.mm),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("${serviceDetail.clientName}", style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              )),
                              pw.Text("Phone: ${serviceDetail.clientPhone}", style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              )),
                              pw.SizedBox(height: 10),
                            ]
                          ),
                        ),
                      ]
                    )
                  )
                ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                    child: pw.Container(
                        decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black, width: 1)
                        ),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 10),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 2 * PdfPageFormat.mm),
                                child: pw.Text("Service Detail"),
                              ),
                              pw.Divider(),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 2 * PdfPageFormat.mm),
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text("${serviceDetail.name}", style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey600,
                                    )),
                                    if(serviceDetail.serviceDate!=null && serviceDetail.serviceDate!="") pw.Text("Service Date: ${DateFormat("MMM dd, yyyy hh:mm a").format(DateTime.parse(serviceDetail.serviceDate ?? ""))}", style: pw.TextStyle(
                                      fontSize: 10,
                                      color: PdfColors.grey600,
                                    )),
                                    pw.SizedBox(height: 10),
                                  ],
                                ),
                              ),

                            ]
                        )
                    )
                ),
              ]
            ),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
            if(serviceDetail.description!=null) pw.Container(
                decoration: pw.BoxDecoration(
                    // border: pw.Border.all(color: PdfColors.black, width: 1)
                ),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      // pw.Padding(
                      //   padding: const pw.EdgeInsets.symmetric(horizontal: 2 * PdfPageFormat.mm),
                      //   child: pw.Text("Invoice Description"),
                      // ),
                      // pw.SizedBox(height: 10),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2 * PdfPageFormat.mm),
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text("${serviceDetail.description}", style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              )),
                              pw.SizedBox(height: 10),
                            ]
                        ),
                      ),
                    ]
                )
            ),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),
            ///
            /// PDF Table Create
            ///
            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
              const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30.0,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 6),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Amount Paid',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              '₹ ${serviceDetail.amountPaid}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Amount Due',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.redAccent,
                                ),
                              ),
                            ),
                            pw.Text(
                              '₹ ${(serviceDetail.amount ?? 0) - (serviceDetail.amountPaid ?? 0)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total',
                                style: pw.TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                              '₹ ${serviceDetail.amount}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        // footer: (context) {
        //   return pw.Column(
        //     mainAxisSize: pw.MainAxisSize.min,
        //     children: [
        //       pw.Divider(),
        //       pw.SizedBox(height: 2 * PdfPageFormat.mm),
        //       pw.Text(
        //         'Aishshreya',
        //         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        //       ),
        //       pw.SizedBox(height: 1 * PdfPageFormat.mm),
        //       pw.Row(
        //         mainAxisAlignment: pw.MainAxisAlignment.center,
        //         children: [
        //           pw.Text(
        //             'Address: ',
        //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        //           ),
        //           pw.Text(
        //             'Address Detail Here',
        //           ),
        //         ],
        //       ),
        //       pw.SizedBox(height: 1 * PdfPageFormat.mm),
        //       pw.Row(
        //         mainAxisAlignment: pw.MainAxisAlignment.center,
        //         children: [
        //           pw.Text(
        //             'Email: ',
        //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        //           ),
        //           pw.Text(
        //             'admininfo@gmail.com',
        //           ),
        //         ],
        //       ),
        //     ],
        //   );
        // },
      ),
    );

    return pdf;
    // return FileHandleApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }
}

class FileHandleApi {
  // save pdf file function
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  // open pdf file function
  // static Future openFile(File file) async {
  //   final url = file.path;
  //
  //   await OpenFile.open(url);
  // }
}