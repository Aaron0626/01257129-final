import SwiftUI
import PhotosUI
import Combine

// MARK: - 1. 資料結構定義 (ArtifactData)
// 將原本散落在 View 裡面的 struct 搬過來這裡，讓全域都能使用
struct ArtifactData: Identifiable, Equatable {
    let id = UUID()
    let slotName: String // 部位名稱 (如：生之花)
    
    // 圖片相關
    var selectedItem: PhotosPickerItem?
    var image: Image?
    
    // 數值相關 (OCR 自動填入或手動調整)
    var critRate: Double = 0.0
    var critDmg: Double = 0.0
    
    // 分析結果相關
    var score: Double = 0.0
    var aiComment: String = "準備就緒，請上傳圖片，虛空終端將自動讀取數值..."
    var isAnalyzing: Bool = false
}

// MARK: - 2. 共用資料模型 (SharedDataModel)
class SharedDataModel: ObservableObject {
    // MARK: - Tab 1 資料 (角色)
    @Published var characterName: String = ""
    @Published var constellationName: String = ""
    @Published var selectedGender: String = "男"
    @Published var selectedElement: String = "風 (Anemo)"
    @Published var selectedWeapon: String = "單手劍"
    @Published var themeColor: Color = .mint
    @Published var ageScale: Double = 18.0
    
    // MARK: - Tab 2 資料 (聖遺物)
    @Published var artifacts: [ArtifactData] = [
        ArtifactData(slotName: "生之花"),
        ArtifactData(slotName: "死之羽"),
        ArtifactData(slotName: "時之沙"),
        ArtifactData(slotName: "空之杯"),
        ArtifactData(slotName: "理之冠")
    ]
    
    // 輔助：計算全套聖遺物的總面板 (給 Tab 3 用)
    var totalCritRate: Double {
        artifacts.reduce(0) { $0 + $1.critRate }
    }
    
    var totalCritDmg: Double {
        artifacts.reduce(0) { $0 + $1.critDmg }
    }
    
    // 判斷是否已經有足夠資料進行模擬
    var isReadyForSim: Bool {
        // 名字不為空 且 至少有一點爆擊率 (代表有掃描過)
        !characterName.isEmpty && totalCritRate > 0
    }
}
