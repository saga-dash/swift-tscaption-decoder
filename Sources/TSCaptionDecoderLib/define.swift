// 
//  define.swift
//  TSCaptionDecoderLib
//
//  Created by saga-dash on 2018/07/08.
//


import Foundation

public enum ControlCode: UInt8, Codable {
    case NULL   = 0x00
    case BEL    = 0x07
    case APB    = 0x08
    case APF    = 0x09
    case APD    = 0x0A
    case APU    = 0x0B
    case CS     = 0x0C
    case APR    = 0x0D
    case LS1    = 0x0E
    case LS0    = 0x0F
    case PAPF   = 0x16
    case CAN    = 0x18
    case SS2    = 0x19
    case ESC    = 0x1B
    case APS    = 0x1C
    case SS3    = 0x1D
    case RS     = 0x1E
    case US     = 0x1F
    case SP     = 0x20
    case DEL    = 0x7F
    case BKF    = 0x80
    case RDF    = 0x81
    case GRF    = 0x82
    case YLF    = 0x83
    case BLF    = 0x84
    case MGF    = 0x85
    case CNF    = 0x86
    case WHF    = 0x87
    case SSZ    = 0x88
    case MSZ    = 0x89
    case NSZ    = 0x8A
    case SZX    = 0x8B
    case COL    = 0x90
    case FLC    = 0x91
    case CDC    = 0x92
    case POL    = 0x93
    case WMM    = 0x94
    case MACRO  = 0x95
    case HLC    = 0x97
    case RPC    = 0x98
    case SPL    = 0x99
    case STL    = 0x9A
    case CSI    = 0x9B
    case TIME   = 0x9D
    //    case 10/0   = 0xA0
    //    case 15/15  = 0xFF
    // 出力用に文字を定義
    case CHAR   = 0x10
    case DRCS   = 0x11
}
enum CSIChar: UInt8 {
    case SWF    = 0x53
    case CCC    = 0x54
    case RCS    = 0x6E
    case ACPS   = 0x61
    case SDF    = 0x56
    case SDP    = 0x5F
    case SSM    = 0x57
    case PLD    = 0x5B
    case PLU    = 0x5C
    case SHS    = 0x58
    case SVS    = 0x59
    case GSM    = 0x42
    case GAA    = 0x5D
    case SRC    = 0x5E
    case TCC    = 0x62
    case CFS    = 0x65
    case ORN    = 0x63
    case MDF    = 0x64
    case XCS    = 0x66
    case PRA    = 0x68
    case ACS    = 0x69
    case UED    = 0x6A
    case SCS    = 0x6F
}
enum CharSet {
    case GSet
    case DRCS
}
enum CharTableGset: UInt8 {
    case JIS_KANJI1     = 0x39 //JIS互換漢字1面
    case JIS_KANJI2     = 0x3A //JIS互換漢字2面
    case KIGOU          = 0x3B //追加記号
    case ASCII          = 0x4A //英数
    case HIRA           = 0x30 //平仮名
    case KANA           = 0x31 //片仮名
    case KANJI          = 0x42 //漢字
    case MOSAIC_A       = 0x32 //モザイクA
    case MOSAIC_B       = 0x33 //モザイクB
    case MOSAIC_C       = 0x34 //モザイクC
    case MOSAIC_D       = 0x35 //モザイクD
    case PROP_ASCII     = 0x36 //プロポーショナル英数
    case PROP_HIRA      = 0x37 //プロポーショナル平仮名
    case PROP_KANA      = 0x38 //プロポーショナル片仮名
    case JISX_KANA      = 0x49 //JIX X0201片仮名
}
enum CharTableDRCS: UInt8 {
    case DRCS_0         = 0x40 //DRCS-0
    case DRCS_1         = 0x41 //DRCS-1
    case DRCS_2         = 0x42 //DRCS-2
    case DRCS_3         = 0x43 //DRCS-3
    case DRCS_4         = 0x44 //DRCS-4
    case DRCS_5         = 0x45 //DRCS-5
    case DRCS_6         = 0x46 //DRCS-6
    case DRCS_7         = 0x47 //DRCS-7
    case DRCS_8         = 0x48 //DRCS-8
    case DRCS_9         = 0x49 //DRCS-9
    case DRCS_10        = 0x4A //DRCS-10
    case DRCS_11        = 0x4B //DRCS-11
    case DRCS_12        = 0x4C //DRCS-12
    case DRCS_13        = 0x4D //DRCS-13
    case DRCS_14        = 0x4E //DRCS-14
    case DRCS_15        = 0x4F //DRCS-15
    case MACRO          = 0x70 //マクロ
}

//From: up0511mod
let AsciiTable = [
    "！", "”", "＃", "＄", "％", "＆", "’",
    "（", "）", "＊", "＋", "，", "－", "．", "／",
    "０", "１", "２", "３", "４", "５", "６", "７",
    "８", "９", "：", "；", "＜", "＝", "＞", "？",
    "＠", "Ａ", "Ｂ", "Ｃ", "Ｄ", "Ｅ", "Ｆ", "Ｇ",
    "Ｈ", "Ｉ", "Ｊ", "Ｋ", "Ｌ", "Ｍ", "Ｎ", "Ｏ",
    "Ｐ", "Ｑ", "Ｒ", "Ｓ", "Ｔ", "Ｕ", "Ｖ", "Ｗ",
    "Ｘ", "Ｙ", "Ｚ", "［", "￥", "］", "＾", "＿",
    "‘", "ａ", "ｂ", "ｃ", "ｄ", "ｅ", "ｆ", "ｇ",
    "ｈ", "ｉ", "ｊ", "ｋ", "ｌ", "ｍ", "ｎ", "ｏ",
    "ｐ", "ｑ", "ｒ", "ｓ", "ｔ", "ｕ", "ｖ", "ｗ",
    "ｘ", "ｙ", "ｚ", "｛", "｜", "｝", "￣"
]
let HiraTable = [
    "ぁ", "あ", "ぃ", "い", "ぅ", "う", "ぇ",
    "え", "ぉ", "お", "か", "が", "き", "ぎ", "く",
    "ぐ", "け", "げ", "こ", "ご", "さ", "ざ", "し",
    "じ", "す", "ず", "せ", "ぜ", "そ", "ぞ", "た",
    "だ", "ち", "ぢ", "っ", "つ", "づ", "て", "で",
    "と", "ど", "な", "に", "ぬ", "ね", "の", "は",
    "ば", "ぱ", "ひ", "び", "ぴ", "ふ", "ぶ", "ぷ",
    "へ", "べ", "ぺ", "ほ", "ぼ", "ぽ", "ま", "み",
    "む", "め", "も", "ゃ", "や", "ゅ", "ゆ", "ょ",
    "よ", "ら", "り", "る", "れ", "ろ", "ゎ", "わ",
    "ゐ", "ゑ", "を", "ん", "　", "　", "　", "ゝ",
    "ゞ", "ー", "。", "「", "」", "、", "・"
]
let KanaTable = [
    "ァ", "ア", "ィ", "イ", "ゥ", "ウ", "ェ",
    "エ", "ォ", "オ", "カ", "ガ", "キ", "ギ", "ク",
    "グ", "ケ", "ゲ", "コ", "ゴ", "サ", "ザ", "シ",
    "ジ", "ス", "ズ", "セ", "ゼ", "ソ", "ゾ", "タ",
    "ダ", "チ", "ヂ", "ッ", "ツ", "ヅ", "テ", "デ",
    "ト", "ド", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ",
    "バ", "パ", "ヒ", "ビ", "ピ", "フ", "ブ", "プ",
    "ヘ", "ベ", "ペ", "ホ", "ボ", "ポ", "マ", "ミ",
    "ム", "メ", "モ", "ャ", "ヤ", "ュ", "ユ", "ョ",
    "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ヮ", "ワ",
    "ヰ", "ヱ", "ヲ", "ン", "ヴ", "ヵ", "ヶ", "ヽ",
    "ヾ", "ー", "。", "「", "」", "、", "・"
]
//デフォルトマクロ文(NULは効果がないと規定されている)
let DefaultMacro: [[UInt8]] = [
[ 0x1B,0x24,0x39,0x1B,0x29,0x4A,0x1B,0x2A,0x30,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x24,0x39,0x1B,0x29,0x31,0x1B,0x2A,0x30,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x24,0x39,0x1B,0x29,0x20,0x41,0x1B,0x2A,0x30,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x32,0x1B,0x29,0x34,0x1B,0x2A,0x35,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x32,0x1B,0x29,0x33,0x1B,0x2A,0x35,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x32,0x1B,0x29,0x20,0x41,0x1B,0x2A,0x35,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x20,0x41,0x1B,0x29,0x20,0x42,0x1B,0x2A,0x20,0x43,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x20,0x44,0x1B,0x29,0x20,0x45,0x1B,0x2A,0x20,0x46,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x20,0x47,0x1B,0x29,0x20,0x48,0x1B,0x2A,0x20,0x49,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x20,0x4A,0x1B,0x29,0x20,0x4B,0x1B,0x2A,0x20,0x4C,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x20,0x4D,0x1B,0x29,0x20,0x4E,0x1B,0x2A,0x20,0x4F,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x24,0x39,0x1B,0x29,0x20,0x42,0x1B,0x2A,0x30,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x24,0x39,0x1B,0x29,0x20,0x43,0x1B,0x2A,0x30,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x24,0x39,0x1B,0x29,0x20,0x44,0x1B,0x2A,0x30,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x31,0x1B,0x29,0x30,0x1B,0x2A,0x4A,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ],
    [ 0x1B,0x28,0x4A,0x1B,0x29,0x32,0x1B,0x2A,0x20,0x41,0x1B,0x2B,0x20,0x70,0x0F,0x1B,0x7D ]
]
