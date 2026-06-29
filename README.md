# Flash Card App

Ứng dụng flash card với whiteboard viết tay và nhận diện chữ viết sử dụng Google ML Kit.

## Tính năng

- **Whiteboard viết tay**: Vẽ trực tiếp trên flash card với nhiều màu sắc và kích thước bút
- **Nhận diện chữ viết**: Sử dụng Google ML Kit Digital Ink Recognition để nhận diện chữ viết tay
- **Quản lý flash card**: Tạo, chỉnh sửa, xóa flash card
- **Lưu trữ cục bộ**: Dữ liệu được lưu bằng Hive
- **Cross-platform**: Hỗ trợ Android và Web

## Cài đặt

### Yêu cầu
- Flutter SDK >= 3.2.0
- Android Studio / VS Code
- Java JDK 11+

### Chạy ứng dụng

```bash
# Cài đặt dependencies
flutter pub get

# Chạy trên Android
flutter run

# Chạy trên Web
flutter run -d chrome
```

## Cấu trúc dự án

```
lib/
├── core/
│   ├── constants/        # Hằng số ứng dụng
│   ├── theme/           # Giao diện light/dark theme
│   └── utils/           # Router, utilities
├── features/
│   ├── flashcard/       # Tính năng flash card
│   │   ├── data/
│   │   ├── domain/      # Providers, state management
│   │   └── presentation/ # UI screens
│   ├── whiteboard/      # Tính năng whiteboard
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/ # Canvas, toolbar
│   └── recognition/     # Tính năng nhận diện chữ viết
│       └── domain/
│           └── services/ # ML Kit integration
└── shared/
    ├── models/          # Data models (Flashcard, Stroke, Point)
    ├── services/        # Storage service
    └── widgets/         # Shared widgets
```

## Tech Stack

- **Flutter** - Cross-platform framework
- **Riverpod** - State management
- **GoRouter** - Navigation
- **Hive** - Local storage
- **Google ML Kit** - Digital Ink Recognition
- **Freezed** - Immutable data classes

## License

MIT License