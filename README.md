# Kora Expense Tracker 💰

A comprehensive, user-friendly expense tracking application built with Flutter. Track your income, expenses, and transfers across multiple accounts with intelligent financial health insights.

## ✨ Features

### 🏦 **Account Management**
- Multiple account types (Savings, Wallet, Credit Card, Cash, Investment, Loan)
- Real-time balance tracking
- Account-specific transaction views
- Visual account cards with color-coded types

### 💳 **Transaction Management**
- Income, Expense, and Transfer tracking
- Category-based organization
- Date-based grouping
- Swipe gestures for filtering
- Search and sort functionality

### 📊 **Financial Health Analysis**
- **Smart Health Scoring** (0-100 scale)
- **Personalized Insights** and recommendations
- **Asset-to-Liability Ratio** analysis
- **Net Worth Tracking** with visual indicators
- **Interactive Financial Overview**

### 🎨 **User Experience**
- Modern Material 3 design
- Smooth swipe navigation
- Intuitive gesture controls
- Professional visual design
- Responsive layouts

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/kora_expense_tracker.git
   cd kora_expense_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

### **Main Screens**
- **Dashboard**: Overview of finances and recent transactions
- **Transactions**: Complete transaction management with filtering
- **Accounts**: Account management and financial health analysis
- **Categories**: Transaction category management
- **More**: Settings and additional features

### **Key Features**
- **Account Transactions**: Click any account to view its specific transactions
- **Swipe Filtering**: Swipe left/right to filter by transaction type
- **Financial Health**: Comprehensive analysis with actionable insights
- **Currency Formatting**: Full amount display with proper formatting

## 🏗️ Architecture

### **State Management**
- Provider pattern for state management
- Global AppProvider for app-wide data
- Efficient data filtering and caching

### **Data Models**
- Account management with multiple types
- Transaction categorization
- Category management
- Settings persistence

### **UI Components**
- Reusable card components
- Consistent design system
- Responsive layouts
- Professional animations

## 📊 Financial Health System

The app includes an intelligent financial health analysis system:

### **Health Scoring**
- **Excellent** (80-100): Strong financial position
- **Good** (60-79): Healthy financial status
- **Fair** (40-59): Room for improvement
- **Poor** (0-39): Needs attention

### **Smart Insights**
- Net worth analysis
- Asset-to-liability ratio assessment
- Account diversification recommendations
- Personalized financial advice

## 🎯 Usage

### **Adding Transactions**
1. Tap the + button on any screen
2. Select transaction type (Income/Expense/Transfer)
3. Choose account and category
4. Enter amount and details
5. Save transaction

### **Viewing Account Transactions**
1. Go to Accounts screen
2. Tap any account card
3. View account-specific transactions
4. Use swipe gestures to filter by type

### **Financial Health Analysis**
1. Go to Accounts screen
2. Tap the Financial Health card
3. View detailed analysis and insights
4. Get personalized recommendations

## 🛠️ Development

### **Project Structure**
```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models and serialization
├── providers/         # State management
├── screens/           # Main app screens
├── utils/             # Utility functions and formatters
└── widgets/           # Reusable UI components
```

### **Key Dependencies**
- `provider`: State management
- `intl`: Internationalization and formatting
- `json_annotation`: JSON serialization
- `shared_preferences`: Local data persistence

## 📈 Future Enhancements

- **Multi-currency Support**: Support for different currencies
- **Cloud Sync**: Data synchronization across devices
- **Advanced Analytics**: Detailed financial reports
- **Export Features**: PDF and CSV export
- **Budget Management**: Spending limits and alerts
- **Investment Tracking**: Portfolio management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- Open source community for inspiration

---

**Built with ❤️ using Flutter**

*Track your finances, achieve your goals!*
