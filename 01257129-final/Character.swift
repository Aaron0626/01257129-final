import SwiftUI
import FoundationModels
import PhotosUI
import TipKit
import CoreImage.CIFilterBuiltins

// Tips 定義
struct AvatarTip: Tip {
    var title: Text { Text("自訂角色外觀") }
    var message: Text? { Text("點擊相框中間，即可從相簿上傳你喜歡的圖片作為角色頭像。") }
    var image: Image? { Image(systemName: "photo.badge.plus") }
}

struct DiceTip: Tip {
    var title: Text { Text("缺乏靈感？") }
    var message: Text? { Text("點擊骰子，讓 AI 幫你隨機生成一個提瓦特風格的名字！") }
    var image: Image? { Image(systemName: "dice") }
}

struct StoryTip: Tip {
    var title: Text { Text("虛空終端運算") }
    var message: Text? { Text("根據你設定的數值，AI 將自動演繹出一段屬於該角色的背景故事。") }
    var image: Image? { Image(systemName: "sparkles.rectangle.stack") }
}

struct CharacterCreatorView: View {
    @EnvironmentObject var sharedData: SharedDataModel
    let genders = ["男", "女", "雌雄同體", "無性別"]
    let elements = ["火 (Pyro)", "水 (Hydro)", "風 (Anemo)", "雷 (Electro)", "草 (Dendro)", "冰 (Cryo)", "岩 (Geo)"]
    let weapons = ["單手劍", "雙手劍", "長柄武器", "法器", "弓箭"]
    
    @State private var selectedMonth = 1
    @State private var selectedDay = 1
    @State private var birthDate = Date()
    @State private var isChuunibyou = false
    
    @State private var selectedAvatarItem: PhotosPickerItem? = nil
    @State private var avatarImage: Image? = nil
    
    @State private var aiResponse: String = "等待生成角色故事..."
    @State private var isGenerating: Bool = false
    @State private var isNameLoading: Bool = false
    @State private var isConstellationLoading: Bool = false
    // 初始化 AI Session
    @State private var session = LanguageModelSession()
    
    // Tips
    let avatarTip = AvatarTip()
    let diceTip = DiceTip()
    let storyTip = StoryTip()
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    Image(.back)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .brightness(0.05)
                        .overlay(
                            // 使用 sharedData 的顏色
                            sharedData.themeColor.opacity(0.6)
                                .blendMode(.overlay)
                        )
                }
                .ignoresSafeArea()
                
                // 上層：內容區域
                VStack(spacing: 0) {
                    
                    // --- Header 區域 ---
                    ZStack(alignment: .topTrailing) {
                        ZStack(alignment: .bottomLeading) {
                            
                            // 中間層：角色框 + 頭像
                            HStack {
                                Spacer()
                                
                                PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(sharedData.themeColor.opacity(0.95)) // 使用半透明的元素色
                                            .frame(width: 148, height: 215)
                                            .offset(y: -3)
                                            .blendMode(.overlay)
                                        if let avatarImage {
                                            avatarImage
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 148, height: 215)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .offset(y: -3)
                                        } else {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(sharedData.themeColor.opacity(0.9))
                                                .frame(width: 148, height: 215)
                                                .overlay(
                                                    VStack(spacing: 6) {
                                                        Image(systemName: "person.fill")
                                                            .font(.system(size: 150))
                                                            .symbolEffect(.pulse)
                                                    }
                                                    .foregroundStyle(.white.opacity(0.95))
                                                )
                                                .offset(y: -3)
                                        }
                                        
                                        Image(.roleback)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 260)
                                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                                    }
                                }
                                .popoverTip(avatarTip, arrowEdge: .top)
                                
                                Spacer()
                            }
                            .padding(.bottom, 20)
                            
                            // 文字資訊 (綁定 sharedData)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sharedData.characterName.isEmpty ? "旅行者" : sharedData.characterName)
                                    .font(.system(size: 32, weight: .heavy, design: .serif))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.8), radius: 2, x: 2, y: 2)
                                if !sharedData.constellationName.isEmpty {
                                    Text(sharedData.constellationName)
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.8))
                                        .shadow(color: .black.opacity(0.5), radius: 1)
                                }
                                
                                HStack(spacing: 8) {
                                    // 元素
                                    HStack(spacing: 4) {
                                        Image(getElementIcon(element: sharedData.selectedElement))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        
                                        Text(sharedData.selectedElement)
                                            .font(.subheadline).bold()
                                            .foregroundStyle(sharedData.themeColor.opacity(0.9))
                                    }
                                    
                                    Text("|").foregroundStyle(.white.opacity(0.4))
                                    
                                    // 武器
                                    HStack(spacing: 4) {
                                        Image(getWeaponIcon(weapon: sharedData.selectedWeapon))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        
                                        Text(sharedData.selectedWeapon)
                                            .font(.subheadline).bold()
                                            .foregroundStyle(.gray.opacity(0.9))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(.ultraThinMaterial, in: Capsule())
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .padding(.leading, 20)
                            .padding(.bottom, -10)
                        }
                        .frame(height: 360)
                        .background(
                            LinearGradient(colors: [.black.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom)
                        )
                        ShareLink(item: Image(uiImage: generateQRCode(from: "https://genshin.hoyoverse.com/zh-tw/character/\(sharedData.characterName)")), preview: SharePreview("角色QR Code", image: Image(uiImage: generateQRCode(from: "https://genshin.hoyoverse.com")))) {
                                Image(systemName: "qrcode")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
                            }
                            .padding(.top, 60) // 避開安全區域
                            .padding(.trailing, 20)
                        }

                    // --- 表單區域 ---
                    Form {
                        Section("角色基本資料") {
                            HStack {
                                Text("姓名")
                                // 綁定 SharedData
                                TextField("請輸入角色名字", text: $sharedData.characterName)
                                    .multilineTextAlignment(.trailing)
                                
                                Button {
                                    Task { await generateRandomName() }
                                } label: {
                                    Image(systemName: "dice.fill")
                                        .font(.title2)
                                        .foregroundStyle(sharedData.themeColor)
                                        .opacity(isNameLoading ? 1.0 : 0.4)
                                        .symbolEffect(.bounce, value: isNameLoading)
                                }
                                .buttonStyle(.plain)
                                .disabled(isNameLoading)
                                .popoverTip(diceTip)
                            }
                            
                            Picker("性別", selection: $sharedData.selectedGender) {
                                ForEach(genders, id: \.self) { gender in
                                    Text(gender)
                                }
                            }
                            .pickerStyle(.segmented)
                            .listRowBackground(Color.clear)
                            
                            // 元素選擇 (綁定 SharedData)
                            Picker("神之眼", selection: $sharedData.selectedElement) {
                                ForEach(elements, id: \.self) { element in
                                    Text(element)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: sharedData.selectedElement) { oldValue, newValue in
                                updateThemeColor(for: newValue)
                            }
                            HStack {
                                Text("命之座")
                                TextField("旅人座", text: $sharedData.constellationName)
                                    .multilineTextAlignment(.trailing)
                                
                                Button { Task { await generateRandomConstellation() } } label: {
                                    Image(systemName: "star.square.fill") // 換個星星圖示
                                        .font(.title2).foregroundStyle(sharedData.themeColor)
                                        .opacity(isConstellationLoading ? 1.0 : 0.4)
                                        .symbolEffect(.variableColor, value: isConstellationLoading)
                                }
                                .buttonStyle(.plain)
                                .disabled(isConstellationLoading)
                            }
                            
                            // 武器選擇 (綁定 SharedData)
                            Picker("武器", selection: $sharedData.selectedWeapon) {
                                ForEach(weapons, id: \.self) { weapon in
                                    Text(weapon)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .listRowBackground(Color.clear.background(.ultraThinMaterial.opacity(0.5)))
                        
                        Section("外觀與性格設定") {
                            // 顏色選擇
                            ColorPicker("命之座代表色", selection: $sharedData.themeColor)
                            
                            // 生日選擇
                            HStack {
                                Text("設定生日")
                                Spacer()
                                Picker("月", selection: $selectedMonth) {
                                    ForEach(1...12, id: \.self) { month in
                                        Text("\(month)月").tag(month)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                
                                Picker("日", selection: $selectedDay) {
                                    ForEach(1...getDaysInMonth(month: selectedMonth), id: \.self) { day in
                                        Text("\(day)日").tag(day)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .id(selectedMonth)
                            }
                            .onChange(of: selectedMonth) { _, _ in updateBirthDate() }
                            .onChange(of: selectedDay) { _, _ in updateBirthDate() }
                            
                            // 年齡 (綁定 SharedData)
                            VStack(alignment: .leading) {
                                Text("設定年齡: \(Int(sharedData.ageScale)) 歲")
                                Slider(value: $sharedData.ageScale, in: 10...200, step: 1) {
                                    Text("Age")
                                } minimumValueLabel: { Text("10") } maximumValueLabel: { Text("200") }
                            }
                            
                            Toggle(isOn: $isChuunibyou) {
                                VStack(alignment: .leading) {
                                    Text("開啟「中二」模式")
                                    Text("AI 生成的故事將會變得非常晦澀難懂")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listRowBackground(Color.clear.background(.ultraThinMaterial.opacity(0.5)))
                        
                        Section("虛空終端") {
                            TipView(storyTip)
                                .tipBackground(.ultraThinMaterial)
                            
                            Button {
                                Task { await generateCharacterStory() }
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text(isGenerating ? "正在接收地脈資訊..." : "生成背景故事")
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .disabled(isGenerating)
                            .listRowBackground(sharedData.themeColor.opacity(0.4))
                            
                            Text(aiResponse)
                                .padding(.vertical, 8)
                                .foregroundStyle(isChuunibyou ? .purple : .primary)
                        }
                        .listRowBackground(Color.clear.background(.ultraThinMaterial))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // 初始化時更新顏色
            updateThemeColor(for: sharedData.selectedElement)
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
        .onChange(of: selectedAvatarItem) { oldValue, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    avatarImage = Image(uiImage: uiImage)
                    avatarTip.invalidate(reason: .actionPerformed)
                }
            }
        }
    }
    
    func getDaysInMonth(month: Int) -> Int {
        let dateComponents = DateComponents(year: 2024, month: month)
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func updateBirthDate() {
        var components = DateComponents()
        components.year = 2000
        components.month = selectedMonth
        components.day = selectedDay
        if let date = Calendar.current.date(from: components) {
            birthDate = date
        }
    }
    
    func updateThemeColor(for element: String) {
        // 更新 SharedData 的顏色
        if element.contains("火") { sharedData.themeColor = .red }
        else if element.contains("水") { sharedData.themeColor = .blue }
        else if element.contains("風") { sharedData.themeColor = .mint }
        else if element.contains("雷") { sharedData.themeColor = .purple }
        else if element.contains("草") { sharedData.themeColor = .green }
        else if element.contains("冰") { sharedData.themeColor = .cyan }
        else { sharedData.themeColor = .yellow }
    }
    
    func getElementIcon(element: String) -> String {
        if element.contains("火") { return "Pyro" }
        else if element.contains("水") { return "Hydro" }
        else if element.contains("風") { return "Anemo" }
        else if element.contains("雷") { return "Electro" }
        else if element.contains("草") { return "Dendro" }
        else if element.contains("冰") { return "Cryo" }
        else { return "geo" }
    }
    
    func getWeaponIcon(weapon: String) -> String {
        if weapon.contains("單手劍") { return "sword" }
        else if weapon.contains("雙手劍") { return "claymore" }
        else if weapon.contains("長柄") { return "polearm" }
        else if weapon.contains("法器") { return "catalyst" }
        else { return "bow" }
    }
    
    func generateRandomName() async {
        isNameLoading = true
        // 注意：這裡先給個 Loading 文字
        sharedData.characterName = "讀取中..."
        
        let nations = ["蒙德(荷蘭)", "璃月(中式)", "稻妻(日式)", "須彌(波斯/印度)", "楓丹(法式)", "納塔(墨西哥)", "至冬(俄羅斯)"]
        let randomNation = nations.randomElement() ?? "蒙德"
        
        let prompt = """
        請給我一個原神風格的角色名字，風格參考：\(randomNation)。
        規則：
        1.只要回傳一個名字。
        2.不要標點符號。
        3.長度1~5個字。
        """
        
        do {
            let session = LanguageModelSession()
            let response = try await session.respond(to: prompt)
            sharedData.characterName = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("名字生成失敗: \(error)")
            sharedData.characterName = "旅行者"
        }
        
        diceTip.invalidate(reason: .actionPerformed)
        isNameLoading = false
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func generateRandomConstellation() async {
        isConstellationLoading = true
        sharedData.constellationName = "..."
        
        let prompt = """
        你是一位《原神》的角色設計師。請為這位角色設計一個**獨特且富含詩意**的「命之座」名稱。

        【角色資訊】
        - 名字：\(sharedData.characterName)
        - 元素：\(sharedData.selectedElement)
        - 武器：\(sharedData.selectedWeapon)

        【設計規則】
        1. **格式**：2~4 個中文字，並強制以「座」結尾（例如：琉金座）。
        2. **風格**：必須優雅、古典，類似拉丁文學名的意譯。請使用**動物、傳說生物、植物、或是特殊的器物**作為象徵。
        3. **絕對禁止**：
           - ❌ **禁止**直接使用角色的名字（例如：若叫諾亞，不能叫「諾亞座」）。
           - ❌ **禁止**直接使用元素名稱（例如：不能叫「諾亞風座」、「雷電座」）。
           - ❌ **禁止**使用過於現代或普通的詞彙（例如：不能叫「帥氣座」、「打架座」）。

        【參考範例】
        - 好的例子：仙麟座 (甘雨)、錦織座 (千織)、白鷺座 (神里綾華)、鯨天座 (達達利亞)、金狼座、紅死之座、歌仙座。
        - 壞的例子：旅行者座、火神座、單手劍座。

        【輸出要求】
        只要回傳一個2~4個字的名稱字串即可，不要直接使用角色名稱和元素，**不要**包含任何標點符號，**不要**使用 Markdown（不要加粗體星號）。
        """
        
        do {
            let response = try await session.respond(to: prompt)
            sharedData.constellationName = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch { sharedData.constellationName = "旅人座" }
        isConstellationLoading = false
    }
    
    func generateCharacterStory() async {
        isGenerating = true
        aiResponse = ""
        let session = LanguageModelSession()
        let constellation = sharedData.constellationName.isEmpty ? "旅人座" : sharedData.constellationName
        let name = sharedData.characterName.isEmpty ? "旅行者" : sharedData.characterName
        let personality = isChuunibyou ? "極度中二、使用大量艱澀詞彙、使徒" : "經過一個悲傷的事件或是偶然獲得或是正經、熱血、充滿冒險精神"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        let birthString = dateFormatter.string(from: birthDate)
        
        let prompt = """
        請為一位提瓦特風格的原神角色創作背景故事。
        角色名稱：\(name)
        性別：\(sharedData.selectedGender)
        命之座：\(constellation)
        神之眼：\(sharedData.selectedElement)
        武器：\(sharedData.selectedWeapon)
        生日：\(birthString)
        年齡：\(Int(sharedData.ageScale))歲
        性格特徵：\(personality)
        請用繁體中文，寫一段約 500 字的故事，描述他獲得神之眼的契機，或以及他的生活背景。
        """
        
        do {
            let response = try await session.respond(to: prompt)
            let fullText = response.content
            for char in fullText {
                aiResponse.append(char)
                try? await Task.sleep(nanoseconds: 30_000_000)
            }
        } catch {
            aiResponse = "連線失敗：\(error.localizedDescription)"
        }
        isGenerating = false
    }
}

#Preview {
    // 預覽時需要注入 environmentObject
    CharacterCreatorView()
        .environmentObject(SharedDataModel())
}
