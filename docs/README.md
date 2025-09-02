# Kora Expense Tracker

A modern, intuitive expense tracker app built with Flutter and Material 3 design principles.

## 🎯 Project Overview

Kora Expense Tracker is designed to be effortless and intuitive—like swiping through social media but for finances. It emphasizes:

- **Gesture-based interactions** for natural user experience
- **Material 3 design** with dark mode support
- **Multi-language support** with dynamic currency formatting
- **Offline-first** approach for privacy and reliability
- **Quick actions** with minimal taps required

## 🚀 Key Features

### Core Functionality
- **Transaction Management**: Add, edit, delete transactions with instant updates
- **Account Management**: Unlimited accounts with visual balance indicators
- **Category Management**: Smart defaults with unlimited custom categories
- **Transfer Support**: Seamless money movement between accounts
- **Real-time Updates**: Instant balance and summary updates

### User Experience
- **Bottom Navigation**: Easy one-thumb access to core sections
- **Floating Action Button**: Quick transaction addition with expandable options
- **Inline Account/Category Creation**: Add new items directly from transaction forms
- **Gesture Support**: Swipe to filter, long-press for multi-select
- **Pull-to-refresh**: Natural data refresh mechanism

### Design & Accessibility
- **Material 3**: Modern design with adaptive layouts
- **Dark Mode**: System-aware theme switching
- **Responsive Design**: Works on phones and tablets
- **Color Coding**: Visual indicators for income/expense/transfers
- **Safe Area Support**: Handles notches and edge cases

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/          # Data models and entities
├── providers/       # State management with Provider
├── screens/         # Main app screens
├── widgets/         # Reusable UI components
├── utils/           # Helper functions and utilities
└── constants/       # App-wide constants and configurations
```

### State Management
- **Provider Pattern**: For reactive UI updates
- **Local Storage**: SharedPreferences for data persistence
- **Real-time Updates**: Instant UI refresh on data changes

### Data Models
- **Transaction**: Core transaction entity with type, amount, category, account
- **Account**: Financial account with balance and metadata
- **Category**: Transaction categorization with icons and colors
- **Settings**: User preferences and app configuration

## 🛠️ Development Guidelines

### Git Workflow
1. **Feature Branches**: Create feature branches for new functionality
2. **Meaningful Commits**: Use descriptive commit messages
3. **Testing**: Test thoroughly before merging to main
4. **Documentation**: Update docs with each significant change

### Code Standards
- **Clean Architecture**: Separation of concerns
- **Consistent Naming**: Clear, descriptive names
- **Documentation**: Inline comments for complex logic
- **Error Handling**: Graceful error management
- **Performance**: Optimize for smooth scrolling and interactions

### Internationalization
- **Multi-language Support**: Ready for Hindi, Tamil, and other languages
- **Dynamic Currency**: No hardcoded currency symbols
- **Locale-aware Formatting**: Numbers, dates, and amounts per region

## 📱 Screens Overview

### Home Screen (Dashboard)
- Summary card with total balance and monthly overview
- Recent transactions with swipe actions
- Quick stats and category insights
- Pull-to-refresh functionality

### Transactions Screen
- Full transaction list grouped by date
- Search and filter capabilities
- Infinite scroll with lazy loading
- Quick categorization for uncategorized items

### Accounts Screen
- Visual account cards with balance indicators
- Quick transfer functionality
- Account-specific transaction views
- Easy account addition and management

### Categories Screen
- Smart default categories with icons
- Unlimited custom categories
- Color and icon customization
- Quick-add from transaction forms

### More Screen
- Settings and preferences
- Export/import functionality
- Theme and language options
- App information and help

## 🔄 Development Progress

### Phase 1: Foundation ✅
- [x] Project setup and dependencies
- [x] Basic project structure
- [x] Documentation framework

### Phase 2: Core Models (In Progress)
- [ ] Data models (Transaction, Account, Category)
- [ ] State management setup
- [ ] Local storage implementation

### Phase 3: UI Foundation
- [ ] Material 3 theme setup
- [ ] Bottom navigation structure
- [ ] Basic screen layouts

### Phase 4: Core Functionality
- [ ] Transaction CRUD operations
- [ ] Account management
- [ ] Category system

### Phase 5: Advanced Features
- [ ] Transfer functionality
- [ ] Search and filters
- [ ] Export/import features

### Phase 6: Polish & Testing
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Final documentation

## 📚 Learning Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Material 3 Design](https://m3.material.io/)
- [Provider State Management](https://pub.dev/packages/provider)
- [Flutter Internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

## 🤝 Contributing

1. Follow the established project structure
2. Use meaningful commit messages
3. Test thoroughly before submitting
4. Update documentation for new features
5. Follow Material Design principles

---

**Current Status**: Initial setup phase - Foundation and project structure established.
