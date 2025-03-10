import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fiap_m03_mobile_flutter/types/transaction.dart';
import 'package:fiap_m03_mobile_flutter/screens/transaction_screen.dart';

class TransactionCard extends StatefulWidget {
  final TransactionType transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  _TransactionCardState createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool isDownloading = false;

  Future<void> downloadAttachment(BuildContext context, String url) async {
    setState(() => isDownloading = true);

    try {
      String path = Uri.parse(url).pathSegments.last;

      String fileName = path.split('/').last;

      final filePath = '/storage/emulated/0/Download/$fileName';

      await Dio().download(url, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download concluído: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar anexo: $e')),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isIncome = widget.transaction.amount > 0;
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TransactionScreen(transaction: widget.transaction),
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Icon(
            isIncome ? Icons.arrow_circle_up : Icons.arrow_circle_down,
            color: isIncome ? Colors.green : Colors.red,
            size: 32,
          ),
          title: Text(
            widget.transaction.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              '${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(widget.transaction.date.millisecondsSinceEpoch))} • ${widget.transaction.category}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.transaction.attachmentUrl != null)
                IconButton(
                  icon: isDownloading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.download,
                          color: Theme.of(context).primaryColor),
                  onPressed: isDownloading
                      ? null
                      : () => downloadAttachment(
                          context, widget.transaction.attachmentUrl!),
                ),
              Text(
                currencyFormat.format(widget.transaction.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
