# Flutter SDK가 포함된 공식 이미지를 기반으로 사용
FROM cirrusci/flutter:stable

# 작업 디렉토리 설정
WORKDIR /app

# 프로젝트 의존성 파일들을 먼저 복사
COPY pubspec.* ./

# 의존성 설치
RUN flutter pub get

# 프로젝트의 나머지 파일들 복사
COPY . .

# 앱 빌드 (원하는 플랫폼에 따라 명령어 선택)
# iOS 빌드
RUN flutter build ios --release --no-codesign

# Android 빌드
# RUN flutter build apk --release

# 웹 빌드
# RUN flutter build web

# 컨테이너 실행 시 기본 명령어 (개발 서버 실행)
CMD ["flutter", "run", "--no-sound-null-safety"] 