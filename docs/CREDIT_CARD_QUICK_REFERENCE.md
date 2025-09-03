# Credit Card Management - Quick Reference Guide

## 🚀 **Quick Start**

### **Adding Transactions from Credit Card Screen**
1. Open Credit Card → Click FAB (+) button
2. Account is pre-selected → Start typing description
3. Tab to Amount → Enter amount
4. Tab to Category → Select category
5. Tab to Notes → Add notes (optional)
6. Save → Success message appears

### **Generating Statements**
1. Go to Statements tab
2. Click "Generate Statement"
3. If already exists → Orange warning message
4. If new → Confirmation dialog → Generate
5. Statement appears in history

### **Making Payments**
1. Go to Payments tab
2. Click "Make Payment" or "Pay Now"
3. Select amount (Full/Minimum)
4. Choose source account
5. Add notes (optional)
6. Process Payment

### **Viewing Payment History**
1. Go to Payments tab
2. Scroll to "Payment History"
3. Click "View All" → Full history screen
4. See summary cards and detailed list

---

## 🐛 **Common Issues & Quick Fixes**

| Issue | Quick Fix |
|-------|-----------|
| Statement generation error | Check if statement already exists, delete if needed |
| Auto-focus not working | Ensure account is pre-selected from credit card screen |
| Payment history empty | Verify transactions are 'expense' type with correct toAccountId |
| App shows error screen | Click "Retry" button or refresh the screen |
| Minimum payment shows ₹25 | Fixed - now shows ₹0 when calculated amount is less |

---

## 📱 **Screen Navigation**

```
Credit Cards Screen
├── Credit Card List
│   ├── Bill Date Info
│   ├── Due Date Info
│   └── Days Remaining
└── FAB (+) → Add Credit Card

Credit Card Detail Screen
├── Overview Tab
│   ├── Card Visual
│   ├── Key Metrics
│   ├── Payment Status
│   ├── Quick Actions
│   └── Recent Activity
├── Transactions Tab
│   ├── Transaction List
│   ├── Analytics Button
│   └── FAB (+) → Add Transaction
├── Statements Tab
│   ├── Current Statement
│   ├── Statement History
│   └── Generate Statement
└── Payments Tab
    ├── Payment Overview
    ├── Quick Actions
    └── Payment History
```

---

## ⚡ **Keyboard Shortcuts & Flow**

### **Transaction Entry Flow**
1. **Description** (auto-focused) → Type transaction description
2. **Amount** (Tab/Enter) → Enter amount
3. **Category** (Tab/Enter) → Select category
4. **Notes** (Tab/Enter) → Add notes
5. **Save** (Button) → Complete transaction

### **Quick Actions**
- **FAB (+) on Overview** → Add Transaction
- **FAB (+) on Transactions** → Add Transaction  
- **FAB (+) on Statements** → Generate Statement
- **FAB (+) on Payments** → Make Payment

---

## 🔧 **Technical Notes**

### **Export Functionality**
- **Status**: Simulated only (shows success messages)
- **Required**: File permissions and PDF/CSV libraries
- **Impact**: Low - core functionality works

### **Auto-Pay**
- **Status**: Setup only (scheduled payments)
- **Required**: Background processing
- **Impact**: Medium - manual trigger needed

### **Error Recovery**
- **Statement Errors**: Auto-cleared on refresh
- **Payment Errors**: Retry button available
- **App Errors**: No restart required

---

## 📞 **Support**

For issues not covered in this guide:
1. Check the main documentation
2. Verify data integrity
3. Try refresh/retry options
4. Check error messages for specific guidance

**Last Updated**: December 2024  
**Version**: 2.0.0