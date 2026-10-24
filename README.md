# Node Wave 2.2.2 — Fusion 2포인트 자동 흔들림

Node Wave는 DaVinci Resolve Fusion에서 이미지 출력 노드에 Root·Tip 리깅을 붙여, 키프레임 없이 실제 이미지 휘어짐을 만드는 플러그인입니다. MediaIn, Loader, 투명 PNG, Text+ 같은 2D 이미지 출력에 적용합니다. 오디오 전용 노드와 3D 데이터 출력에는 적용되지 않습니다.

## 배포 파일

- [macOS 배포 ZIP 다운로드](dist/macOS/NodeWave-2.2.2-macOS.zip?raw=1) — `docs/MACOS_INSTALL.md` 포함
- [Windows / DaVinci Resolve 18 배포 ZIP 다운로드](dist/Windows/NodeWave-2.2.2-Windows.zip?raw=1) — `docs/WINDOWS_18_INSTALL.md` 포함

두 ZIP은 같은 변형 엔진과 전용 창을 사용합니다. 운영체제에 맞는 설치 안내만 다릅니다. 성능 모드나 화질 차이는 없습니다.

## 기본 사용법

1. Fusion에서 이미지를 출력하는 노드를 선택합니다.
2. `작업 공간 > 스크립트 > Comp > NodeWaveController`를 열고 **리깅 만들기**를 누릅니다.
3. 생성된 Node Wave Deform을 Viewer에 띄워 Root와 Tip을 조절합니다.
4. 전용 창에서 값을 바꾸고 **설정 적용**을 누릅니다. 원본·결과 미리보기와 프레임 새로고침으로 비교할 수 있습니다.
5. 오른쪽 위 버튼으로 한국어와 영어를 전환할 수 있습니다.

`.setting` 매크로는 사용하지 않습니다. 전용 창은 `scripts/NodeWaveController.lua`, 실제 변형 엔진은 `fuses/NodeWaveDeform.fuse`입니다. 두 파일이 모두 필요합니다. 리깅 값은 노드에 저장되므로 창을 닫아도 결과가 유지됩니다.

## 기능과 성능

Root·Tip 포인트, 고정 영역, 휘어짐, 진폭·빈도·속도·방향·위상, 탄성·감쇠·지연·불규칙성, 프리셋 4개를 제공합니다. 엔진은 변형 영향 영역만 재샘플링하고 변형이 없으면 입력을 통과시킵니다. 미리보기는 요청할 때만 새로 만들며 창을 닫을 때 임시 이미지를 지웁니다. macOS에서는 `TMPDIR`, Windows에서는 `%TEMP%`를 우선 사용합니다. 자동 최적화가 움직임이나 최종 렌더 품질을 바꾸지 않습니다.

## 검증과 제한

`python3 tests/run_lua_tests.py`로 Fuse·스크립트 문법, 변형 흐름, macOS·Windows 경로 모의 테스트를 확인합니다. macOS Resolve 19.0.3에서는 이전 Node Wave 2.2 계열의 시간에 따른 출력 변화를 확인했습니다. 실제 Windows Resolve 18 실행 검증은 아직 완료되지 않았습니다. 다중 포인트, Object Mode, 저사양 노트북 벤치마크는 미완료입니다.

개발용 예제 `examples/NodeWaveTwoPoint.comp`는 개인 Mac 경로와 Resolve 캐시 정보를 포함하므로 공개 저장소와 배포 ZIP에서 제외합니다.

## 참고

- [Blackmagic Fusion Fuse SDK](https://documents.blackmagicdesign.com/UserManuals/Fusion_Fuse_SDK.pdf)
- [Blackmagic Fusion Scripting Guide](https://documents.blackmagicdesign.com/UserManuals/Fusion8_Scripting_Guide.pdf)
