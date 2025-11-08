

import 'dart:math';


// 1) Abstract base class BankAccount

abstract class BankAccount {
  // Private fields (encapsulation)
  String _accountNumber;
  String _holderName;
  double _balance;

  // Transaction history (simple list of strings)
  final List<String> transactions = [];

  BankAccount(this._accountNumber, this._holderName, this._balance) {
    if (_balance < 0) {
      print('Error: Initial balance cannot be negative');
      _balance = 0;
    }
  }

  // Getters
  String get accountNumber => _accountNumber;
  String get holderName => _holderName;
  double get balance => _balance;

  // Setters with basic validation
  set holderName(String name) {
    if (name.trim().isEmpty) {
      print('Error: Name cannot be empty');
    } else {
      _holderName = name;
    }
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

// 2) Interface / abstract class for interest-bearing accounts

abstract class InterestBearing {
  double calculateInterest();
  void applyInterest();
}


// 3) SavingsAccount

class SavingsAccount extends BankAccount implements InterestBearing {
  static const double minBalance = 500.0;
  static const double annualInterestRate = 0.02; // 2%
  static const int withdrawalLimitPerMonth = 3;

  int _monthlyWithdrawals = 0;

  SavingsAccount(String accNo, String name, double initialBalance)
      : super(accNo, name, initialBalance) {
    if (initialBalance < minBalance) {
      print('Error: Savings account requires minimum \$${minBalance}');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Error: Withdraw amount should be positive');
      return;
    }
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
    if (amount <= 0) {
      print('Error: Deposit amount should be positive');
      return;
    }
    changeBalance(amount, reason: 'Savings deposit');
    print('Deposited \$${amount.toStringAsFixed(2)} to Savings');
  }

  void resetMonthlyCounters() {
    _monthlyWithdrawals = 0;
  }

  @override
  double calculateInterest() {
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
    if (amount <= 0) {
      print('Error: Withdraw amount should be positive');
      return;
    }

    changeBalance(-amount, reason: 'Checking withdrawal');
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Checking');

    if (balance < 0) {
      changeBalance(-overdraftFee, reason: 'Overdraft fee');
      print('Account went negative: overdraft fee \$${overdraftFee} charged');
    }
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print('Error: Deposit amount should be positive');
      return;
    }
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
      print('Error: Premium account requires minimum \$${minBalance}');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Error: Withdraw amount should be positive');
      return;
    }
    if (amount > balance) {
      print('Withdrawal failed: insufficient funds');
      return;
    }
    changeBalance(-amount, reason: 'Premium withdrawal');
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Premium');
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print('Error: Deposit amount should be positive');
      return;
    }
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


// 6) StudentAccount

class StudentAccount extends BankAccount {
  static const double maxBalance = 5000.0;

  StudentAccount(String accNo, String name, double initialBalance)
      : super(accNo, name, initialBalance) {
    if (initialBalance > maxBalance) {
      print('Error: Initial balance exceeds student account maximum');
    }
  }

  @override
  void withdraw(double amount) {
    if (amount <= 0) {
      print('Error: Withdraw amount should be positive');
      return;
    }
    if (amount > balance) {
      print('Withdrawal failed: insufficient funds');
      return;
    }
    changeBalance(-amount, reason: 'Student withdrawal');
    print('Withdrawn \$${amount.toStringAsFixed(2)} from Student');
  }

  @override
  void deposit(double amount) {
    if (amount <= 0) {
      print('Error: Deposit amount should be positive');
      return;
    }
    if (balance + amount > maxBalance) {
      print('Deposit failed: would exceed student account maximum of \$${maxBalance}');
      return;
    }
    changeBalance(amount, reason: 'Student deposit');
    print('Deposited \$${amount.toStringAsFixed(2)} to Student');
  }
}

// 7) Bank class

class Bank {
  final Map<String, BankAccount> _accounts = {};

  String createAccount(BankAccount account) {
    if (_accounts.containsKey(account.accountNumber)) {
      print('Error: Account number already exists');
      return account.accountNumber;
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
      print('Transfer \$${amount.toStringAsFixed(2)} from ${from.accountNumber} to ${to.accountNumber}');
      return true;
    } catch (e) {
      print('Transfer failed with error: $e');
      return false;
    }
  }

  void generateReport() {
    print('--- Bank Accounts Report ---');
    for (final acc in _accounts.values) {
      print('Account: ${acc.accountNumber} | Holder: ${acc.holderName} | Balance: \$${acc.balance.toStringAsFixed(2)}');
    }
    print('--- End of Report ---');
  }

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

// 8) Demonstration (main)

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
  savings.withdraw(10); 

  checking.withdraw(300); 

  student.deposit(4900); 
  student.deposit(100); 

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