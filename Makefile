xcode:
	swift package generate-xcodeproj

build:
	swift build

build_docker:
	docker build --tag caption-decoder .
