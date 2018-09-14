// 
//  util.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/25.
//


import Foundation

public func getHeader(_ data: Data, _ _header: TransportPacket? = nil, isPes: Bool = false) throws -> TransportPacket {
    guard let header = _header else {
        return try TransportPacket(data, isPes: isPes)
    }
    return header
}

public func convertJSTStr(_ date: Date?) -> String? {
    guard let date = date else {
        return nil
    }
    let f = DateFormatter()
    f.timeStyle = .medium
    f.dateStyle = .medium
    f.locale = Locale(identifier: "ja_JP")
    return f.string(from: date)
}
// 修正ユリウス日+現在時刻をDateに
public func convertMJD(_ time: UInt64) -> Date? {
    if time == 0xFFFFFFFFFF {
        return nil
    }
    let MJD = Double(time>>24)
    let _year = Double(Int((MJD - 15078.2) / 365.25))
    let _month = Int((MJD-14956.1-Double(Int(_year * 365.25)))/30.6001)
    let day = Int(MJD-14956.0-Double(Int(_year * 365.25))-Double(Int(Double(_month) * 30.6001)))
    let K = _month == 14 || _month == 15 ? 1 : 0
    let year = Int(_year) + K + 1900
    let month = Int(_month) - 1 - K * 12
    let _date = convertARIBTime(UInt32(time&0xFFFFFFFF))
    let dateComponets = DateComponents(calendar: Calendar.current, timeZone: TimeZone(identifier: "Asia/Tokyo")!, year: year, month: month, day: day, hour: _date.hour, minute: _date.minute, second: _date.second)
    return dateComponets.date
}
// 下位6桁の16進数で現在時刻を表すARIBTimeをDateに
// 0x204000 → 20時40分00秒
public func convertARIBTime(_ time: UInt32) -> DateComponents {
    let _hour: Int = Int((time&0xFF0000)>>16)
    let hour: Int = (_hour>>4)*10 + _hour&0x0F
    let _minute: Int = Int((time&0x00FF00)>>8)
    let minute: Int = (_minute>>4)*10 + _minute&0x0F
    let _second: Int = Int(time&0x0000FF)
    let second: Int = (_second>>4)*10 + _second&0x0F
    let date = DateComponents(hour: hour, minute: minute, second: second)
    return date
}
// 33bit -> timeString
public func convertTimeStamp(_ time: UInt64?) -> String? {
    guard let time = time else {
        return nil
    }
    var ts = Double(time)
    var sec = floor(ts/90000)
    ts -= sec * 90000
    var min = floor(sec/60)
    sec -= min * 60
    let hour = floor(min/60)
    min -= hour * 60
    return "\(String(format: "%02.0f", hour)):\(String(format: "%02.0f", min)):\(String(format: "%02.0f", sec)).\(String(format: "%03.0f", ts/90))"
}
// 6byte -> PCR
public func pickPCR(_ time: [UInt8]?) -> UInt64? {
    guard let time = time else {
        return nil
    }
    //print("0x" + time.map({"\(String(format: "%02x", $0))"}).joined(separator: ""))
    let pcr33: UInt64 = UInt64(time[0])<<25 | UInt64(time[1])<<17 | UInt64(time[2])<<9 | UInt64(time[3])<<1 | UInt64(time[4]&0x80)>>7
    let _: UInt16 = UInt16(time[4]&0x01)<<8 | UInt16(time[5]) //pcr9
    return pcr33
}
// 5byte -> PTS, DTS
public func pickTimeStamp(_ time: [UInt8]?) -> UInt64? {
    guard let time = time else {
        return nil
    }
    //print("0x" + time.map({"\(String(format: "%02x", $0))"}).joined(separator: ""))
    let timestamp: UInt64 = UInt64(time[0]&0x0E)<<29 | UInt64(time[1])<<22 | UInt64(time[2]&0xFE)<<14 | UInt64(time[3])<<7 | UInt64(time[4]&0xFE)>>1
    return timestamp
}
