# Vertex AI Chat 範例

[![English Version](https://img.shields.io/badge/README-English-blue)](README.md)

一個新的 Flutter 項目，旨在展示 Vertex AI 與 Flutter 應用的整合。該專案展示了各種功能，並為建立更複雜的應用程式提供了堅實的基礎。

## 介紹

Vertex AI 是一個用於建置、部署和擴展機器學習模型的強大工具。這個 Flutter 專案旨在提供一個如何將 Vertex AI 整合到行動應用中的實際範例。透過遵循這個範例，開發人員可以學習如何利用 Vertex AI 的功能來增強他們的 Flutter 應用程式。

## 安裝

1. **Clone 倉庫：**
 ```sh
 git clone https://github.com/your_username/vertex_ai_example.git
 cd vertex_ai_example
 ```

2. **安裝依賴：**
 ```sh
 flutter pub get
 ```

3. **運行應用：**
 ```sh
 flutter run
 ```

## Firebase 設定

1. **安裝 `flutterfire_cli`：**
 ```sh
 dart pub global activate flutterfire_cli
 ```

2. **為你的 Flutter 應用程式配置 Firebase：**
 ```sh
 flutterfire configure
 ```

 按照提示選擇你的 Firebase 專案和平台（iOS、Android 等）。

3. **新增 Firebase 依賴：**
 確保在你的 `pubspec.yaml` 檔案中有必要的 Firebase 依賴。例如：
 ```yaml
 dependencies:
   firebase_core: latest_version
   firebase_vertexai: latest_version
 ```

4. **在你的 Flutter 應用程式中初始化 Firebase：**
 在你的 `main.dart` 檔案中，在執行應用程式之前初始化 Firebase：
 ```dart
 import 'package:firebase_core/firebase_core.dart';
 import 'package:flutter/material.dart';

 void main() async {
   WidgetsFlutterBinding.ensureInitialized();

   // 1.
   await Firebase.initializeApp();
   // 2.
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)

   runApp(MyApp());
 }
 ```

## 使用場景

### 1. 文字提示回應
在這個情境中，使用者輸入一個文字提示並將其發送給 AI。 AI 根據給定的輸入提供回應。這可以用於各種應用，如聊天機器人、虛擬助理等。

### 2. 基於圖像的查詢
除了文字提示，使用者還可以提供圖像輸入，可以透過拍照或從圖庫中選擇。想像一下，拍照後詢問 AI 這張照片裡有什麼。這個使用場景特別適用於影像辨識、擴增實境等應用。

### 3. 計算 Token 使用量
這個情境涉及使用 Vertex AI 進行額外操作以計算 Token 使用量。使用的 Token 數量代表了成本消耗，並有助於評估當前的 AI 互動是否正常運作。監控 Token 使用量是管理成本和確保 AI 高效運作的重要指標。

## 範例展示

![Screenshot 1](screenshots/1.png)
![Screenshot 2](screenshots/2.png)
![Screenshot 2](screenshots/3.png)

## 專案結構

- `lib/`：包含 Flutter 應用程式的主要程式碼。
 - `home_page.dart`：應用程式的主頁。

## 貢獻

1. Fork 倉庫。
2. 建立一個新分支 (`git checkout -b feature-branch`)。
3. 進行更改。
4. 提交更改 (`git commit -m 'Add some feature'`)。
5. 推送到分支 (`git push origin feature-branch`)。
6. 開啟一個 pull request。

## 許可證

這個項目是根據 MIT 許可證授權的 - 詳情請參閱 [LICENSE](LICENSE) 文件。