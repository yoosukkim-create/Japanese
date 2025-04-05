# 빌드 명령어   
# docker build --platform linux/arm64 -t flutter_japanese_app .

# 실행 명령어
# docker run -it flutter_japanese_app

# ARM64를 지원하는 공식 Flutter 이미지 사용
FROM --platform=linux/arm64 ghcr.io/cirruslabs/flutter:stable

# 작업 디렉토리 설정
WORKDIR /app

# 프로젝트 의존성 파일들을 먼저 복사
COPY pubspec.* ./

# 의존성 설치
RUN flutter pub get

# 프로젝트의 나머지 파일들 복사
COPY . .

# 앱 빌드 (원하는 플랫폼에 따라 명령어 선택)
# iOS 빌드 -> Docker 컨테이너에서는 IOS 빌드가 제한적...
#RUN flutter build ios --release --no-codesign

# Android 빌드
# RUN flutter build apk --release

# 웹 빌드
# RUN flutter build web

# 컨테이너 실행 시 기본 명령어 (개발 서버 실행)
CMD ["flutter", "run", "--no-sound-null-safety"] 