
NDK_IMAGE := different/alpine-android-ndk:r25b
IMAGE_EXISTS := $(shell docker images -q ${NDK_IMAGE})
BUILD_DIR := ./build

build: deps
	mkdir -p build
	docker run --rm --mount source=$(PWD),destination=/source,type=bind \
  --workdir=/source ${NDK_IMAGE} ndk-build -e NDK_PROJECT_PATH=. -e \
	APP_BUILD_SCRIPT=Android.mk -e NDK_APP_DST_DIR=${BUILD_DIR} NDK_APP_OUT=${BUILD_DIR} \
	APP_PLATFORM=android-21 APP_ABI='armeabi-v7a arm64-v8a' APP_STL=none

deps:
ifeq ($(IMAGE_EXISTS),)
	$(info pulling docker build image)
	docker pull ${NDK_IMAGE}
endif

all: clean format deps build

local:
	mkdir -p build
	$(CXX) src/main_fix.cpp src/elffix/fix.cpp -O2 -o $(BUILD_DIR)/sofix

format:
	find src/ -regex '.*\.\(c\|h\|cpp\)'  -exec clang-format -style=file -i {} \;

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}