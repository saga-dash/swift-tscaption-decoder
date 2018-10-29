# swift-tscaption-decoder

A description of this package.

## Build

```
make build
or
swift build -c release
```

## Run

- ファイルを指定して実行
```
.build/release/TSCaptionDecoder -c subtitle -f ./a.ts
```
- 標準入力(未検証)
```
recpt1 --b25 --strip 27 - - | .build/release/TSCaptionDecoder -c subtitle
or
cat ./a.ts | .build/release/TSCaptionDecoder -c teletext
```

## Help

```
.build/release/TSCaptionDecoder --help
Usage:

    $ .build/release/TSCaptionDecoder

Options:
    -f  --file # ない場合標準入力を待機
    -c  --componentTag - subtitle, subtitle{1-7}, teletext, teletext{1-7}
```

## Output

- Unit
    - str: 字幕文字列(空文字)
    - eventId: EIT-PのeventId
    - serviceId: EIT-PのserviceIdから変換
    - pts: PresentationTimeStamp(MPEG2-TS)
    - appearanceTime: ToTとPCRから計算
    - control: ARIB8文字デコード
