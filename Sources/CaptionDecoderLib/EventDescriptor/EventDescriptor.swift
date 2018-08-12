// 
//  EventDescriptor.swift
//  CaptionDecoderLib
//
//  Created by saga-dash on 2018/07/31.
//


import Foundation
import ByteArrayWrapper

// ARIB STD-B10 第1部  図 6.2-*
public protocol EventDescriptor {
    var descriptorTag: UInt8 { get }                 //  8 uimsbf
    var descriptorLength: UInt8 { get }              //  8 uimsbf
    init(_ wrapper: ByteArray) throws
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
    public init(_ wrapper: ByteArray) throws {
        self.descriptorTag = try wrapper.get()
        self.descriptorLength = try wrapper.get()
        try wrapper.skip(Int(descriptorLength))
        self.name = "Unhandled"
    }
    public var name: String
    public init(_ wrapper: ByteArray, _ name: String) throws {
        try self.init(wrapper)
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


func convertEventDescriptor(_ wrapper: ByteArray) throws -> EventDescriptor? {
    switch try wrapper.get(doMove: false) {
    case 0x09:
        return try UnhandledDescriptor(wrapper, "ConditionalAccessMethod") // 図 6.2-1 限定受信方式記述子のデータ構造
    case 0x40:
        return try UnhandledDescriptor(wrapper, "NetworkName")  // 図 6.2-2 ネットワーク名記述子のデータ構造
    case 0x41:
        return try UnhandledDescriptor(wrapper, "ServiceList")    // 図 6.2-3 サービスリスト記述子のデータ構造
    case 0x42:
        return try UnhandledDescriptor(wrapper, "Stuffing")        // 図 6.2-4 スタッフ記述子のデータ構造
    case 0x43:
        return try UnhandledDescriptor(wrapper, "SatelliteDeliverySystem") // 図 6.2-5 衛星分配システム記述子のデータ構造
    case 0x47:
        return try UnhandledDescriptor(wrapper, "BouquetName") // 図 6.2-6 ブーケ名記述子のデータ構造
    case 0x48:
        return try UnhandledDescriptor(wrapper, "Service") // 図 6.2-7 サービス記述子のデータ構造
    case 0x49:
        return try UnhandledDescriptor(wrapper, "CountryAvailability") // 図 6.2-8 国別受信可否記述子のデータ構造
    case 0x4A:
        return try UnhandledDescriptor(wrapper, "Linkage") // 図 6.2-9 リンク記述子のデータ構造
    case 0x4B:
        return try UnhandledDescriptor(wrapper, "NVODReference") // 図 6.2-10 NVOD基準サービス記述子のデータ構造
    case 0x4C:
        return try UnhandledDescriptor(wrapper, "TimeShiftedService") // 図 6.2-11 タイムシフトサービス記述子のデータ構造
    case 0x4D:
        return try ShortEventDescriptor(wrapper) // 図 6.2-12 短形式イベント記述子のデータ構造
    case 0x4E:
        return try UnhandledDescriptor(wrapper, "ExtendedEvent") // 図 6.2-13 拡張形式イベント記述子のデータ構造
    case 0x4F:
        return try UnhandledDescriptor(wrapper, "TimeShiftedEvent") // 図 6.2-14 タイムシフトイベント記述子のデータ構造
    case 0x50:
        return try UnhandledDescriptor(wrapper, "Component") // 図 6.2-15 コンポーネント記述子のデータ構造
    case 0x51:
        return try UnhandledDescriptor(wrapper, "Mosaic") // 図 6.2-16 モザイク記述子のデータ構造
    case 0x52:
        return try UnhandledDescriptor(wrapper, "StreamIdentifier") // 図 6.2-17 ストリーム識別記述子のデータ構造
    case 0x53:
        return try UnhandledDescriptor(wrapper, "CAIdentifier") // 図 6.2-18 CA識別記述子のデータ構造
    case 0x54:
        return try ContentDescriptor(wrapper) // 図 6.2-19 コンテント記述子のデータ構造
    case 0x55:
        return try UnhandledDescriptor(wrapper, "ParentalRating") // 図 6.2-20 パレンタルレート記述子のデータ構造
    case 0xFD:
        return try UnhandledDescriptor(wrapper, "DataComponent") // 図 6.2-21 データ符号化方式記述子のデータ構造
    case 0xFE:
            return try UnhandledDescriptor(wrapper, "SystemManagement") // 図 6.2-22 システム管理記述子のデータ構造
    case 0x0D:
        return try UnhandledDescriptor(wrapper, "Copyright") // 図 6.2-23 著作権記述子のデータ構造
    case 0xC0:
        return try UnhandledDescriptor(wrapper, "HierarchicalTransmission") // 図 6.2-24 階層伝送記述子のデータ構造
    case 0xC1:
        return try UnhandledDescriptor(wrapper, "DigitalCopyControl") // 図 6.2-25 デジタルコピー制御記述子のデータ構造
    case 0xFC:
        return try UnhandledDescriptor(wrapper, "EmergencyInformation") // 図 6.2-26 緊急情報記述子のデータ構造
    case 0x58:
        return try UnhandledDescriptor(wrapper, "LocalTimeOffset") // 図 6.2-27 ローカル時間オフセット記述子のデータ構造
    case 0xC4:
        return try UnhandledDescriptor(wrapper, "AudioComponent") // 図 6.2-28 音声コンポーネント記述子のデータ構造
    case 0xC5:
        return try UnhandledDescriptor(wrapper, "Hyperlink") // 図 6.2-29 ハイパーリンク記述子のデータ構造
    case 0xC6:
        return try UnhandledDescriptor(wrapper, "TargetRegion") // 図 6.2-30 対象地域記述子のデータ構造
    case 0xC7:
        return try UnhandledDescriptor(wrapper, "DataContents") // 図 6.2-31 データコンテンツ記述子のデータ構造
    case 0xC8:
        return try UnhandledDescriptor(wrapper, "VideoDecodeControl") // 図 6.2-32 ビデオデコードコントロール記述子のデータ構造
    case 0xD0:
        return try UnhandledDescriptor(wrapper, "BasicLocalEvent") // 図 6.2-33 基本ローカルイベント記述子のデータ構造
    case 0xD1:
        return try UnhandledDescriptor(wrapper, "Reference") // 図 6.2-34 リファレンス記述子のデータ構造
    case 0xD2:
        return try UnhandledDescriptor(wrapper, "NodeRelation") // 図 6.2-35 ノード関係記述子のデータ構造
    case 0xD3:
        return try UnhandledDescriptor(wrapper, "ShortNodeInformation") // 図 6.2-36 短形式ノード情報記述子のデータ構造
    case 0xD4:
        return try UnhandledDescriptor(wrapper, "STCReference") // 図 6.2-37 STC参照記述子のデータ構造
    case 0xFA:
        return try UnhandledDescriptor(wrapper, "TerrestrialDeliverySystem") // 図 6.2-38 地上分配システム記述子のデータ構造
    case 0xFB:
        return try UnhandledDescriptor(wrapper, "PartialReception") // 図 6.2-39 部分受信記述子のデータ構造
    case 0xD5:
        return try UnhandledDescriptor(wrapper, "Series") // 図 6.2-40 シリーズ記述子のデータ構造
    case 0xD6:
        return try UnhandledDescriptor(wrapper, "EventGroup") // 図 6.2-41 イベントグループ記述子のデータ構造
    case 0xD7:
        return try UnhandledDescriptor(wrapper, "SITransmissionParameter") // 図 6.2-42 SI伝送パラメータ記述子のデータ構造
    case 0xD8:
        return try UnhandledDescriptor(wrapper, "BroadcasterName") // 図 6.2-43 ブロードキャスタ名記述子のデータ構造
    case 0xD9:
        return try UnhandledDescriptor(wrapper, "ComponentGroup") // 図 6.2-44 コンポーネントグループ記述子のデータ構造
    case 0xDA:
        return try UnhandledDescriptor(wrapper, "SIPrimeTS") // 図 6.2-45 SIプライムTS記述子のデータ構造
    case 0xDB:
        return try UnhandledDescriptor(wrapper, "BoardInformation") // 図 6.2-46 掲示板情報記述子のデータ構造
    case 0xDC:
        return try UnhandledDescriptor(wrapper, "LDTLinkage") // 図 6.2-47 LDTリンク記述子のデータ構造
    case 0xDD:
        return try UnhandledDescriptor(wrapper, "ConnectedTransmission") // 図 6.2-48 連結送信記述子のデータ構造
    case 0xCD:
        return try UnhandledDescriptor(wrapper, "TSInformation") // 図 6.2-49 TS情報記述子のデータ構造
    case 0xCE:
        return try UnhandledDescriptor(wrapper, "ExtendedBroadcaster") // 図 6.2-50 拡張ブロードキャスタ記述子のデータ構造
    case 0xCF:
        return try UnhandledDescriptor(wrapper, "LogoTransmission") // 図 6.2-51 ロゴ伝送記述子のデータ構造
    case 0xDE:
        return try UnhandledDescriptor(wrapper, "ContentAvailability") // 図 6.2-52 コンテント利用記述子のデータ構造
    case 0xF7:
        return try UnhandledDescriptor(wrapper, "CarouselCompatibleComposite") // 図 6.2-53 カルーセル互換複合記述子のデータ構造
    case 0xF8:
        return try UnhandledDescriptor(wrapper, "RestrictedPlayback") // 図 6.2-54 限定再生方式記述子のデータ構造
    case 0x28:
        return try UnhandledDescriptor(wrapper, "AVCVideo") // 図 6.2-55 AVCビデオ記述子のデータ構造
    case 0x2A:
        return try UnhandledDescriptor(wrapper, "AVCTimingHRD") // 図 6.2-56 AVCタイミングHRD記述子のデータ構造
    case 0xE0:
        return try UnhandledDescriptor(wrapper, "ServiceGroup") // 図 6.2-57 サービスグループ記述子のデータ構造



    case 0x1C:
        return try UnhandledDescriptor(wrapper, "MPEG-4Audio") // 図 6.2-58 MPEG-4オーディオ記述子のデータ構造
    case 0x2E:
        return try UnhandledDescriptor(wrapper, "MPEG-4AudioExtention") // 図 6.2-59 MPEG-4オーディオ拡張記述子のデータ構造
    case 0x05:
        return try UnhandledDescriptor(wrapper, "Registered") // 図 6.2-60 登録記述子のデータ構造
    case 0x66:
        return try UnhandledDescriptor(wrapper, "Broadcast") // 図 6.2-61 データブロードキャスト識別記述子のデータ構造
    case 0xF6:
        return try UnhandledDescriptor(wrapper, "AccessControl") // 図 6.2-62 アクセス制御記述子のデータ構造
    case 0xE1:
        return try UnhandledDescriptor(wrapper, "AreaInfomation") // 図 6.2-63 エリア放送情報記述子のデータ構造
    case 0x67:
        return try UnhandledDescriptor(wrapper, "") // 図 6.2-64 素材情報記述子のデータ構造
    case 0x38:
        return try UnhandledDescriptor(wrapper, "") // 図 6.2-65 HEVCビデオ記述子のデータ構造
    case 0x04:
        return try UnhandledDescriptor(wrapper, "") // 図 6.2-66 階層符号化記述子のデータ構造
    case 0x68:
        return try UnhandledDescriptor(wrapper, "") // 図 6.2-67 通信連携情報記述子のデータ構造
    case 0xF5:
        return try UnhandledDescriptor(wrapper, "") // 図 6.2-68 スクランブル方式記述子のデータ構造
    /*
    // INT で使用される記述子のデータ構造
    case 0x06:
         return try UnhandledDescriptor(wrapper, "") // 図 6.3-1 ターゲットスマートカード記述子のデータ構造
    case 0x09:
         return try UnhandledDescriptor(wrapper, "") // 図 6.3-2 ターゲットIPアドレス記述子のデータ構造
    case 0x0A:
         return try UnhandledDescriptor(wrapper, "") // 図 6.3-3 ターゲットIPv6アドレス記述子のデータ構造
    case 0x0C:
         return try UnhandledDescriptor(wrapper, "") // 図 6.3-4 IP/MACプラットフォーム名記述子のデータ構造
    case 0x0D:
         return try UnhandledDescriptor(wrapper, "") // 図 6.3-5 IP/MACプラットフォームプロバイダ名記述子のデータ構造
    case 0x13:
         return try UnhandledDescriptor(wrapper, "") // 図 6.3-6 IP/MACストリーム配置記述子のデータ構造
    */
        
    default:
        return try UnhandledDescriptor(wrapper)
    }
}
