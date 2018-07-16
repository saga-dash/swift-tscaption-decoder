xcode:
	swift package generate-xcodeproj

build:
	swift build -c release

build_docker:
	docker build --tag caption-decoder .
