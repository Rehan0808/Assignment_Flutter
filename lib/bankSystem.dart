// Banking System OOP Challenge - Beginner-friendly Dart implementation
// File: banking_system.dart

import 'dart:math';

// -------------------------------
// 1) Abstract base class BankAccount
// -------------------------------
abstract class BankAccount {
  // Private fields (encapsulation)
  String _accountNumber;
  String _holderName;
  double _balance;

  // Transaction history (simple list of strings)
  final List<String> transactions = [];

  BankAccount(this._accountNumber, this._holderName, this._balance) {
    if (_balance < 0) throw ArgumentError('Initial balance cannot be negative');
  }

  // Getters
  String get accountNumber => _accountNumber;
  String get holderName => _holderName;
  double get balance => _balance;

  // Setters with basic validation
  set holderName(String name) {
    if (name.trim().isEmpty) throw ArgumentError('Name cannot be empty');
    _holderName = name;
  }

  // Protected helper to change balance within subclasses
  void changeBalance(double amount, {required String reason}) {
    _balance += amount;
    _recordTransaction(amount, reason);
  }

  void _recordTransaction(double amount, String reason) {
    final now = DateTime.now();
    final entry =
        '${now.toIso8601String()} | ${amount >= 0 ? 'Credit' : 'Debit'} '
        '| \$${amount.abs().toStringAsFixed(2)} | $reason | Balance: \$${_balance.toStringAsFixed(2)}';
    transactions.add(entry);
  }

  // Abstract methods
  void withdraw(double amount);
  void deposit(double amount);

  // Display info
  void displayInfo() {
    print('Account: ${_accountNumber}');
    print('Holder: ${_holderName}');
    print('Balance: \$${_balance.toStringAsFixed(2)}');
  }
}

// -------------------------------
// 2) Interface / abstract class for interest-bearing accounts
// -------------------------------
abstract class InterestBearing {
  // Returns interest amount (not applied)
  double calculateInterest();

  // Apply interest to account (mutates balance)
  void applyInterest();
}

// -------------------------------
// 3) SavingsAccount
// -------------------------------
class SavingsAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 500.0;
  static const double annualInterestRate = 0.02; // 2%
  static const int withdrawalLimitPerMonth = 3;

  int _monthlyWithdrawals = 0;

  SavingsAccount(String accNo, String name, double initialBalance)
      : super(accNo, name, initialBalance) {
    if (initialBalance < minBalance) {
      throw ArgumentError('Savings account requires minimum \$${minBalance}');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Withdraw amount should be positive');
    if (_monthlyWithdrawals >= withdrawalLimitPerMonth) {
      print('Withdrawal failed: monthly withdrawal limit reached');
      return;
    }
    if (amount > balance) {
      print('Withdrawal failed: insufficient funds');
      return;
    }
    changeBalance(-amount, reason: 'Savings withdrawal');
    _monthlyWithdrawals++;
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Savings');
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit amount should be positive');
    changeBalance(amount, reason: 'Savings deposit');
    print('Deposited \$${amount.toStringAsFixed(2)} to Savings');
  }

  // Reset monthly counters (call from Bank at month boundary)
  void resetMonthlyCounters() {
    _monthlyWithdrawals = 0;
  }

  @override
  double calculateInterest() {
    // monthly interest based on annual rate
    return balance * (annualInterestRate / 12);
  }

  @override
  void applyInterest() {
    final interest = calculateInterest();
    if (interest > 0) {
      changeBalance(interest, reason: 'Savings monthly interest');
    }
  }
}

// 4) CheckingAccount
class CheckingAccount extends BankAccount {
  static const double overdraftFee = 35.0;

  CheckingAccount(String accNo, String name, double initialBalance)
      : super(accNo, name, initialBalance);

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Withdraw amount should be positive');

    changeBalance(-amount, reason: 'Checking withdrawal');
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Checking');

    if (balance < 0) {
      changeBalance(-overdraftFee, reason: 'Overdraft fee');
      print('Account went negative: overdraft fee \$${overdraftFee} charged');
    }
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit amount should be positive');
    changeBalance(amount, reason: 'Checking deposit');
    print('Deposited \$${amount.toStringAsFixed(2)} to Checking');
  }
}
// 5) PremiumAccount

class PremiumAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 10000.0;
  static const double annualInterestRate = 0.05; // 5%

  PremiumAccount(String accNo, String name, double initialBalance)
      : super(accNo, name, initialBalance) {
    if (initialBalance < minBalance) {
      throw ArgumentError('Premium account requires minimum \$${minBalance}');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Withdraw amount should be positive');
    if (amount > balance) {
      print('Withdrawal failed: insufficient funds');
      return;
    }
    changeBalance(-amount, reason: 'Premium withdrawal');
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Premium');
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit amount should be positive');
    changeBalance(amount, reason: 'Premium deposit');
    print('Deposited \$${amount.toStringAsFixed(2)} to Premium');
  }

  @override
  double calculateInterest() {
    return balance * (annualInterestRate / 12);
  }

  @override
  void applyInterest() {
    final interest = calculateInterest();
    if (interest > 0) {
      changeBalance(interest, reason: 'Premium monthly interest');
    }
  }
}


// 6) StudentAccount (extension)

class StudentAccount extends BankAccount {
  static const double maxBalance = 5000.0;

  StudentAccount(String accNo, String name, double initialBalance)
      : super(accNo, name, initialBalance) {
    if (initialBalance > maxBalance) {
      throw ArgumentError('Initial balance exceeds student account maximum');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) throw ArgumentError('Withdraw amount should be positive');
    if (amount > balance) {
      print('Withdrawal failed: insufficient funds');
      return;
    }
    changeBalance(-amount, reason: 'Student withdrawal');
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Student');
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Deposit amount should be positive');
    if (balance + amount > maxBalance) {
      print(
          'Deposit failed: would exceed student account maximum of \$${maxBalance}');
      return;
    }
    changeBalance(amount, reason: 'Student deposit');
    print('Deposited \$${amount.toStringAsFixed(2)} to Student');
  }
}

// 7) Bank class

class Bank {
  final Map<String, BankAccount> _accounts = {};

  // Create new accounts (basic factory method); returns account number
  String createAccount(BankAccount account) {
    if (_accounts.containsKey(account.accountNumber)) {
      throw ArgumentError('Account number already exists');
    }
    _accounts[account.accountNumber] = account;
    return account.accountNumber;
  }

  BankAccount? findAccount(String accNo) => _accounts[accNo];

  bool transfer(String fromAcc, String toAcc, double amount) {
    final from = findAccount(fromAcc);
    final to = findAccount(toAcc);
    if (from == null || to == null) {
      print('Transfer failed: one or both accounts not found');
      return false;
    }
    if (amount <= 0) {
      print('Transfer failed: amount must be positive');
      return false;
    }

    try {
      from.withdraw(amount);
      to.deposit(amount);
      from.transactions.add(
          '${DateTime.now().toIso8601String()} | Transfer out | \$${amount.toStringAsFixed(2)} | To: ${to.accountNumber}');
      to.transactions.add(
          '${DateTime.now().toIso8601String()} | Transfer in | \$${amount.toStringAsFixed(2)} | From: ${from.accountNumber}');
      print(
          'Transfer \$${amount.toStringAsFixed(2)} from ${from.accountNumber} to ${to.accountNumber}');
      return true;
    } catch (e) {
      print('Transfer failed with error: $e');
      return false;
    }
  }

  // Generate a simple report of all accounts
  void generateReport() {
    print('--- Bank Accounts Report ---');
    for (final acc in _accounts.values) {
      print(
          'Account: ${acc.accountNumber} | Holder: ${acc.holderName} | Balance: \$${acc.balance.toStringAsFixed(2)}');
    }
    print('--- End of Report ---');
  }

  // Apply monthly interest to all interest-bearing accounts
  void applyMonthlyInterestToAll() {
    for (final acc in _accounts.values) {
      if (acc is InterestBearing) {
        try {
          (acc as InterestBearing).applyInterest();
        } catch (e) {
          print('Failed to apply interest to ${acc.accountNumber}: $e');
        }
      }

      if (acc is SavingsAccount) {
        acc.resetMonthlyCounters();
      }
    }
  }
}

// -------------------------------
// 8) Demonstration (main)
// -------------------------------
void main() {
  final bank = Bank();

  // Create accounts
  final savings = SavingsAccount('SAV1001', 'Alice', 1000.0);
  final checking = CheckingAccount('CHK2001', 'Bob', 200.0);
  final premium = PremiumAccount('PRM3001', 'Carol', 15000.0);
  final student = StudentAccount('STD4001', 'Dave', 100.0);

  bank.createAccount(savings);
  bank.createAccount(checking);
  bank.createAccount(premium);
  bank.createAccount(student);

  // Do some operations
  savings.deposit(200);
  savings.withdraw(100);
  savings.withdraw(100);
  savings.withdraw(50);
  savings.withdraw(10); // should hit withdrawal limit

  checking.withdraw(300); // causes overdraft and fee

  student.deposit(4900); // should reach near max
  student.deposit(100); // should fail (over max)

  bank.transfer('PRM3001', 'CHK2001', 500.0);

  // Apply monthly interest and reset counters
  bank.applyMonthlyInterestToAll();

  // Report
  bank.generateReport();

  // Print transaction history for one account
  print('\n--- Transaction history for ${savings.accountNumber} ---');
  for (final t in savings.transactions) {
    print(t);
  }
}
