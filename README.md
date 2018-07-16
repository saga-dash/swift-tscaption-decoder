# swift-caption-decoder

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
.build/release/CaptionDecoder -c subtitle -f ./a.ts
```
- 標準入力(未検証)
```
recpt1 --b25 --strip 27 - - | .build/release/CaptionDecoder -c subtitle
or
cat ./a.ts | .build/release/CaptionDecoder -c teletext
```

## Help

```
.build/release/CaptionDecoder --help
Usage:

    $ .build/release/CaptionDecoder

Options:
    -f  --file # ない場合標準入力を待機
    -c  --componentType - subtitle, subtitle{1-7}, teletext, teletext{1-7}
```
