# 🍃 虛空終端 (Akasha Terminal)

> **「啟動虛空終端，連結世界樹，掌握提瓦特之旅。」**
> 專屬於旅行者的 iOS AI 智慧冒險助手。

## 📖 專案簡介 (Introduction)

**虛空終端 (Akasha Terminal)** 是一款結合 **Generative AI (生成式 AI)** 與 **iOS 原生視覺辨識技術** 的原神粉絲創作 App。

本專案旨在將 iPhone 化身為提瓦特的「虛空終端」，提供原創角色生成、聖遺物數值鑑定以及深淵戰術模擬等功能。透過整合 Google Gemini API，讓每一次的互動都充滿靈魂與驚喜。

## ✨ 核心功能 (Features)

### 1. 🎭 AI 原創角色構建 (OC Maker)
利用 AI 算力，解決創作者的靈感枯竭。
* **智慧命名**：根據七國風格（如：蒙德/德式、稻妻/日式）隨機生成符合世界觀的名字。
* **命之座訂製**：AI 自動演繹富有詩意的命之座名稱（如：靈狐座、蒼穹座）。
* **傳記演繹**：根據設定的屬性與武器，撰寫長達 500 字的深度背景故事。
* **中二模式 (Chuunibyou Mode)**：獨家開關！切換至晦澀難懂的「幽夜淨土」敘事風格。
* **社群分享**：一鍵生成附帶 QR Code 的角色卡片，與好友分享你的創作。

### 2. 🔍 智慧聖遺物鑑定 (Artifact Scanner)
告別繁瑣的手動計算，用科技辨識神器。
* **視覺辨識 (OCR)**：整合 **Vision Framework**，直接上傳遊戲截圖即可讀取數值。
* **CV 評分計算**：即時計算「雙爆評分 (Crit Value)」，判斷是極品還是肥料。
* **動態圖表**：使用 **Swift Charts** 繪製雙爆分佈圖，視覺化呈現數值權重。
* **AI 毒舌評審**：可切換不同性格（智慧、嚴厲、鼓勵）的 AI 對聖遺物進行短評。

### 3. 🛡️ 機密戰術模擬 (Tactical Simulation)
連線至世界樹資料庫，分析強敵弱點。
* **Boss 資料庫**：即時載入敵方抗性與屬性弱點（整合 **Kingfisher** 圖片快取）。
* **戰力評估**：根據我方角色面板與敵方抗性，由 AI 生成戰術建議報告。
* **生物辨識鎖定**：整合 **LocalAuthentication (FaceID / TouchID)**，以最高安全規格守護戰術機密。
* **互動式圖鑑**：支援全螢幕查看與雙指縮放 (**Zoomable**) 觀察怪物模型細節。

### 4. 🌌 沈浸式體驗
* **虛空開機動畫**：還原遊戲內的啟動特效，包含科技光環與系統載入介面。
* **新手引導**：整合 iOS 17 **TipKit**，提供貼心的操作提示氣泡。

---

## 🛠️ 技術堆疊 (Tech Stack)

本專案使用 **SwiftUI** 構建，並採用 **MVVM** 架構模式。

| 類別 | 使用技術 / 套件 | 用途 |
| :--- | :--- | :--- |
| **UI Framework** | **SwiftUI** | 核心介面構建 |
| **AI & LLM** | **Google Generative AI (Gemini)** | 自然語言生成 (名字、故事、戰術分析) |
| **Computer Vision** | **Vision (Core ML)** | OCR 文字辨識 (讀取聖遺物數值) |
| **Data Visualization** | **Swift Charts** | 繪製聖遺物數值長條圖 |
| **Security** | **LocalAuthentication** | FaceID / TouchID 生物辨識解鎖 |
| **User Experience** | **TipKit** | 浮動式操作引導提示 (iOS 17+) |
| **Image Processing** | **CoreImage (CIFilter)** | 生成 QR Code |
| **Networking** | **Async / Await** | 非同步資料請求 |
| **Third-party (SPM)** | **Kingfisher** | 網路圖片下載與快取 |
| **Third-party (SPM)** | **Zoomable** | 圖片縮放手勢支援 |
| **Third-party (SPM)** | **ConfettiSwiftUI** | 鑑定成功時的慶祝特效 |

---

## 📱 系統需求 (Requirements)

* **iOS 版本**: iOS 17.0+ (因使用 TipKit 與 Swift Charts)
* **開發環境**: Xcode 15.0+
* **API Key**: 需要 Google Gemini API Key

---

## 🚀 安裝與執行 (Installation)

1.  **Clone 專案**
    ```bash
    git clone [https://github.com/yourusername/AkashaTerminal.git](https://github.com/yourusername/AkashaTerminal.git)
    ```
2.  **開啟專案**
    使用 Xcode 開啟 `.xcodeproj` 檔案。
3.  **設定 API Key**
    在 `GenerativeAI-Info.plist` (或專案設定處) 填入你的 Google API Key。
4.  **安裝套件**
    等待 Xcode 自動解析 Swift Package Manager (SPM) 套件。
5.  **執行**
    選擇模擬器或實機 (建議使用 iPhone 15 Pro 以獲得最佳體驗) 進行 Build & Run。
