import 'package:flutter/foundation.dart';
import '../../../core/models/credit_card.dart';
import '../../../core/models/credit_card_statement.dart';
import '../../../core/models/payment_record.dart';
import '../../../core/utils/storage_service.dart';

/// Service: pure data layer for credit card operations.
class CreditCardService {
  Future<List<CreditCard>> loadCreditCards() => StorageService.loadCreditCards();
  Future<List<CreditCardStatement>> loadStatements() => StorageService.loadCreditCardStatements();
  Future<List<PaymentRecord>> loadPaymentRecords() => StorageService.loadPaymentRecords();

  Future<void> saveCreditCard(CreditCard card) => StorageService.updateCreditCard(card);
  Future<void> addCreditCard(CreditCard card) => StorageService.addCreditCard(card);
  Future<void> deleteCreditCard(String id) => StorageService.deleteCreditCard(id);

  Future<void> saveStatements(List<CreditCardStatement> items) =>
      StorageService.saveCreditCardStatements(items);
  Future<void> addStatement(CreditCardStatement s) =>
      StorageService.addCreditCardStatement(s);
  Future<void> updateStatement(CreditCardStatement s) =>
      StorageService.updateCreditCardStatement(s);
  Future<void> deleteStatement(String id) =>
      StorageService.deleteCreditCardStatement(id);

  Future<void> addPaymentRecord(PaymentRecord p) =>
      StorageService.addPaymentRecord(p);
  Future<void> savePaymentRecords(List<PaymentRecord> items) =>
      StorageService.savePaymentRecords(items);
}
