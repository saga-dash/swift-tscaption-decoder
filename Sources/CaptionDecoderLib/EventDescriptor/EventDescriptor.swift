// 
//  EventDescriptor.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/31.
//


import Foundation


// ARIB STD-B10 第1部  図 6.2-*
public protocol EventDescriptor {
    var descriptorTag: UInt8 { get }                 //  8 uimsbf
    var descriptorLength: UInt8 { get }              //  8 uimsbf
    init(_ bytes: [UInt8])
    var description: String { get }
}
extension EventDescriptor {
    var length: Int {
        // 2 byte + descriptorLength
        return 2 + Int(descriptorLength)
    }
}

public struct UnhandledDescriptor: EventDescriptor {
    public var descriptorTag: UInt8
    public var descriptorLength: UInt8
    public init(_ bytes: [UInt8]) {
        self.descriptorTag = bytes[0]
        self.descriptorLength = bytes[1]
        self.name = "Unhandled"
    }
    public var name: String
    public init(_ bytes: [UInt8], _ name: String) {
        self.init(bytes)
        self.name = name
    }
}
extension UnhandledDescriptor : CustomStringConvertible {
    public var description: String {
        return "\(name)(descriptorTag: \(String(format: "0x%02x", descriptorTag))"
            + ", descriptorLength: \(String(format: "0x%02x", descriptorLength))"
            + ")"
    }
}


func convertEventDescriptor(_ bytes: [UInt8]) -> EventDescriptor? {
    switch bytes[0] {
    case 0x09:
        return UnhandledDescriptor(bytes, "ConditionalAccessMethod") // 図 6.2-1 限定受信方式記述子のデータ構造
    case 0x40:
        return UnhandledDescriptor(bytes, "NetworkName")  // 図 6.2-2 ネットワーク名記述子のデータ構造
    case 0x41:
        return UnhandledDescriptor(bytes, "ServiceList")    // 図 6.2-3 サービスリスト記述子のデータ構造
    case 0x42:
        return UnhandledDescriptor(bytes, "Stuffing")        // 図 6.2-4 スタッフ記述子のデータ構造
    case 0x43:
        return UnhandledDescriptor(bytes, "SatelliteDeliverySystem") // 図 6.2-5 衛星分配システム記述子のデータ構造
    case 0x47:
        return UnhandledDescriptor(bytes, "BouquetName") // 図 6.2-6 ブーケ名記述子のデータ構造
    case 0x48:
        return UnhandledDescriptor(bytes, "Service") // 図 6.2-7 サービス記述子のデータ構造
    case 0x49:
        return UnhandledDescriptor(bytes, "CountryAvailability") // 図 6.2-8 国別受信可否記述子のデータ構造
    case 0x4A:
        return UnhandledDescriptor(bytes, "Linkage") // 図 6.2-9 リンク記述子のデータ構造
    case 0x4B:
        return UnhandledDescriptor(bytes, "NVODReference") // 図 6.2-10 NVOD基準サービス記述子のデータ構造
    case 0x4C:
        return UnhandledDescriptor(bytes, "TimeShiftedService") // 図 6.2-11 タイムシフトサービス記述子のデータ構造
    case 0x4D:
        return ShortEventDescriptor(bytes) // 図 6.2-12 短形式イベント記述子のデータ構造
    case 0x4E:
        return UnhandledDescriptor(bytes, "ExtendedEvent") // 図 6.2-13 拡張形式イベント記述子のデータ構造
    case 0x4F:
        return UnhandledDescriptor(bytes, "TimeShiftedEvent") // 図 6.2-14 タイムシフトイベント記述子のデータ構造
    case 0x50:
        return UnhandledDescriptor(bytes, "Component") // 図 6.2-15 コンポーネント記述子のデータ構造
    case 0x51:
        return UnhandledDescriptor(bytes, "Mosaic") // 図 6.2-16 モザイク記述子のデータ構造
    case 0x52:
        return UnhandledDescriptor(bytes, "StreamIdentifier") // 図 6.2-17 ストリーム識別記述子のデータ構造
    case 0x53:
        return UnhandledDescriptor(bytes, "CAIdentifier") // 図 6.2-18 CA識別記述子のデータ構造
    case 0x54:
        return ContentDescriptor(bytes) // 図 6.2-19 コンテント記述子のデータ構造
    case 0x55:
        return UnhandledDescriptor(bytes, "ParentalRating") // 図 6.2-20 パレンタルレート記述子のデータ構造
    case 0xFD:
        return UnhandledDescriptor(bytes, "DataComponent") // 図 6.2-21 データ符号化方式記述子のデータ構造
    case 0xFE:
            return UnhandledDescriptor(bytes, "SystemManagement") // 図 6.2-22 システム管理記述子のデータ構造
    case 0x0D:
        return UnhandledDescriptor(bytes, "Copyright") // 図 6.2-23 著作権記述子のデータ構造
    case 0xC0:
        return UnhandledDescriptor(bytes, "HierarchicalTransmission") // 図 6.2-24 階層伝送記述子のデータ構造
    case 0xC1:
        return UnhandledDescriptor(bytes, "DigitalCopyControl") // 図 6.2-25 デジタルコピー制御記述子のデータ構造
    case 0xFC:
        return UnhandledDescriptor(bytes, "EmergencyInformation") // 図 6.2-26 緊急情報記述子のデータ構造
    case 0x58:
        return UnhandledDescriptor(bytes, "LocalTimeOffset") // 図 6.2-27 ローカル時間オフセット記述子のデータ構造
    case 0xC4:
        return UnhandledDescriptor(bytes, "AudioComponent") // 図 6.2-28 音声コンポーネント記述子のデータ構造
    case 0xC5:
        return UnhandledDescriptor(bytes, "Hyperlink") // 図 6.2-29 ハイパーリンク記述子のデータ構造
    case 0xC6:
        return UnhandledDescriptor(bytes, "TargetRegion") // 図 6.2-30 対象地域記述子のデータ構造
    case 0xC7:
        return UnhandledDescriptor(bytes, "DataContents") // 図 6.2-31 データコンテンツ記述子のデータ構造
    case 0xC8:
        return UnhandledDescriptor(bytes, "VideoDecodeControl") // 図 6.2-32 ビデオデコードコントロール記述子のデータ構造
    case 0xD0:
        return UnhandledDescriptor(bytes, "BasicLocalEvent") // 図 6.2-33 基本ローカルイベント記述子のデータ構造
    case 0xD1:
        return UnhandledDescriptor(bytes, "Reference") // 図 6.2-34 リファレンス記述子のデータ構造
    case 0xD2:
        return UnhandledDescriptor(bytes, "NodeRelation") // 図 6.2-35 ノード関係記述子のデータ構造
    case 0xD3:
        return UnhandledDescriptor(bytes, "ShortNodeInformation") // 図 6.2-36 短形式ノード情報記述子のデータ構造
    case 0xD4:
        return UnhandledDescriptor(bytes, "STCReference") // 図 6.2-37 STC参照記述子のデータ構造
    case 0xFA:
        return UnhandledDescriptor(bytes, "TerrestrialDeliverySystem") // 図 6.2-38 地上分配システム記述子のデータ構造
    case 0xFB:
        return UnhandledDescriptor(bytes, "PartialReception") // 図 6.2-39 部分受信記述子のデータ構造
    case 0xD5:
        return UnhandledDescriptor(bytes, "Series") // 図 6.2-40 シリーズ記述子のデータ構造
    case 0xD6:
        return UnhandledDescriptor(bytes, "EventGroup") // 図 6.2-41 イベントグループ記述子のデータ構造
    case 0xD7:
        return UnhandledDescriptor(bytes, "SITransmissionParameter") // 図 6.2-42 SI伝送パラメータ記述子のデータ構造
    case 0xD8:
        return UnhandledDescriptor(bytes, "BroadcasterName") // 図 6.2-43 ブロードキャスタ名記述子のデータ構造
    case 0xD9:
        return UnhandledDescriptor(bytes, "ComponentGroup") // 図 6.2-44 コンポーネントグループ記述子のデータ構造
    case 0xDA:
        return UnhandledDescriptor(bytes, "SIPrimeTS") // 図 6.2-45 SIプライムTS記述子のデータ構造
    case 0xDB:
        return UnhandledDescriptor(bytes, "BoardInformation") // 図 6.2-46 掲示板情報記述子のデータ構造
    case 0xDC:
        return UnhandledDescriptor(bytes, "LDTLinkage") // 図 6.2-47 LDTリンク記述子のデータ構造
    case 0xDD:
        return UnhandledDescriptor(bytes, "ConnectedTransmission") // 図 6.2-48 連結送信記述子のデータ構造
    case 0xCD:
        return UnhandledDescriptor(bytes, "TSInformation") // 図 6.2-49 TS情報記述子のデータ構造
    case 0xCE:
        return UnhandledDescriptor(bytes, "ExtendedBroadcaster") // 図 6.2-50 拡張ブロードキャスタ記述子のデータ構造
    case 0xCF:
        return UnhandledDescriptor(bytes, "LogoTransmission") // 図 6.2-51 ロゴ伝送記述子のデータ構造
    case 0xDE:
        return UnhandledDescriptor(bytes, "ContentAvailability") // 図 6.2-52 コンテント利用記述子のデータ構造
    case 0xF7:
        return UnhandledDescriptor(bytes, "CarouselCompatibleComposite") // 図 6.2-53 カルーセル互換複合記述子のデータ構造
    case 0xF8:
        return UnhandledDescriptor(bytes, "RestrictedPlayback") // 図 6.2-54 限定再生方式記述子のデータ構造
    case 0x28:
        return UnhandledDescriptor(bytes, "AVCVideo") // 図 6.2-55 AVCビデオ記述子のデータ構造
    case 0x2A:
        return UnhandledDescriptor(bytes, "AVCTimingHRD") // 図 6.2-56 AVCタイミングHRD記述子のデータ構造
    case 0xE0:
        return UnhandledDescriptor(bytes, "ServiceGroup") // 図 6.2-57 サービスグループ記述子のデータ構造



    case 0x1C:
        return UnhandledDescriptor(bytes, "MPEG-4Audio") // 図 6.2-58 MPEG-4オーディオ記述子のデータ構造
    case 0x2E:
        return UnhandledDescriptor(bytes, "MPEG-4AudioExtention") // 図 6.2-59 MPEG-4オーディオ拡張記述子のデータ構造
    case 0x05:
        return UnhandledDescriptor(bytes, "Registered") // 図 6.2-60 登録記述子のデータ構造
    case 0x66:
        return UnhandledDescriptor(bytes, "Broadcast") // 図 6.2-61 データブロードキャスト識別記述子のデータ構造
    case 0xF6:
        return UnhandledDescriptor(bytes, "AccessControl") // 図 6.2-62 アクセス制御記述子のデータ構造
    case 0xE1:
        return UnhandledDescriptor(bytes, "AreaInfomation") // 図 6.2-63 エリア放送情報記述子のデータ構造
    case 0x67:
        return UnhandledDescriptor(bytes, "") // 図 6.2-64 素材情報記述子のデータ構造
    case 0x38:
        return UnhandledDescriptor(bytes, "") // 図 6.2-65 HEVCビデオ記述子のデータ構造
    case 0x04:
        return UnhandledDescriptor(bytes, "") // 図 6.2-66 階層符号化記述子のデータ構造
    case 0x68:
        return UnhandledDescriptor(bytes, "") // 図 6.2-67 通信連携情報記述子のデータ構造
    case 0xF5:
        return UnhandledDescriptor(bytes, "") // 図 6.2-68 スクランブル方式記述子のデータ構造
    /*
    // INT で使用される記述子のデータ構造
    case 0x06:
         return UnhandledDescriptor(bytes, "") // 図 6.3-1 ターゲットスマートカード記述子のデータ構造
    case 0x09:
         return UnhandledDescriptor(bytes, "") // 図 6.3-2 ターゲットIPアドレス記述子のデータ構造
    case 0x0A:
         return UnhandledDescriptor(bytes, "") // 図 6.3-3 ターゲットIPv6アドレス記述子のデータ構造
    case 0x0C:
         return UnhandledDescriptor(bytes, "") // 図 6.3-4 IP/MACプラットフォーム名記述子のデータ構造
    case 0x0D:
         return UnhandledDescriptor(bytes, "") // 図 6.3-5 IP/MACプラットフォームプロバイダ名記述子のデータ構造
    case 0x13:
         return UnhandledDescriptor(bytes, "") // 図 6.3-6 IP/MACストリーム配置記述子のデータ構造
    */
        
    default:
        return UnhandledDescriptor(bytes)
    }
}
