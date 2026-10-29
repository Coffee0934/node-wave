# Node Wave 2.2.2 

Node Wave는 DaVinci Resolve Fusion에서 이미지 출력 노드에 Root·Tip 리깅을 붙여, 키프레임 없이 실제 이미지 휘어짐을 만드는 플러그인입니다. MediaIn, Loader, 투명 PNG, Text+ 같은 2D 이미지 출력에 적용합니다. 오디오 전용 노드와 3D 데이터 출력에는 적용되지 않습니다

## 다운로드

| 운영체제 · 플러그인 · 버전 | 배포 파일 | 설치 안내 |
| --- | --- | --- |
| 🍎 **macOS · Node Wave 2.2.2** | [ZIP 다운로드](dist/macOS/NodeWave-2.2.2-macOS.zip?raw=1) | [macOS 설치 안내](docs/MACOS_INSTALL.md) |
| 🪟 **Windows · Node Wave 2.2.2** | [ZIP 다운로드](dist/Windows/Windows-NodeWave-2.2.2.zip?raw=1) | [Windows 설치 안내](docs/Windows-NodeWave-2.2.2.md) |

두 ZIP은 같은 변형 엔진과 전용 창을 사용합니다. 운영체제에 맞는 설치 안내만 다릅니다. 성능 모드나 화질 차이는 없습니다

## 사용 방법

### 1. 매크로처럼 노드로 추가하기 — 권장

1. 설치 안내에 따라 `NodeWaveDeform.fuse`를 넣고 DaVinci Resolve를 다시 실행합니다.
2. Fusion에서 이미지가 나오는 노드를 선택하고 노드 검색에서 **Node Wave Deform**을 추가해 출력 경로에 연결합니다.
3. 새 노드를 Viewer에 띄운 뒤 **Root**를 고정할 위치, **Tip**을 흔들릴 끝에 놓습니다.
4. Inspector에서 흔들림과 휘어짐 값을 조절합니다. 키프레임 없이 프레임에 따라 움직입니다.

### 2. 스크립트 창으로 적용하기 — 개발 중

1. Fusion에서 이미지가 나오는 노드를 선택합니다.
2. `작업 공간 > 스크립트 > Comp > NodeWaveController`를 열고 **리깅 만들기**를 누릅니다.
3. 생성된 **Node Wave Deform** 노드의 Root와 Tip을 배치한 뒤 전용 창에서 값을 바꾸고 **설정 적용**을 누릅니다. 원본·결과 미리보기와 한국어·영어 전환도 사용할 수 있습니다.

스크립트 창은 노드 생성과 설정을 돕는 기능으로 아직 개발 중입니다. **현재는 1번 노드 방식 사용을 권장합니다.** 두 방법 모두 같은 변형 엔진을 사용하며, 리깅 값은 노드에 저장됩니다.

## 기능과 성능

Root·Tip 포인트, 고정 영역, 휘어짐, 진폭·빈도·속도·방향·위상, 탄성·감쇠·지연·불규칙성, 프리셋 4개를 제공합니다. 엔진은 변형 영향 영역만 재샘플링하고 변형이 없으면 입력을 통과시킵니다. 미리보기는 요청할 때만 새로 만들며 창을 닫을 때 임시 이미지를 지웁니다. macOS에서는 `TMPDIR`, Windows에서는 `%TEMP%`를 우선 사용합니다. 자동 최적화가 움직임이나 최종 렌더 품질을 바꾸지 않습니다.

## 검증과 제한

`python3 tests/run_lua_tests.py`로 Fuse·스크립트 문법, 변형 흐름, macOS·Windows 경로 모의 테스트를 확인합니다. macOS Resolve 19.0.3에서는 이전 Node Wave 2.2 계열의 시간에 따른 출력 변화를 확인했습니다. 실제 Windows Resolve 실행 검증은 아직 완료되지 않았습니다. 다중 포인트, Object Mode, 저사양 노트북 벤치마크는 미완료입니다.

개발용 예제 `examples/NodeWaveTwoPoint.comp`는 개인 Mac 경로와 Resolve 캐시 정보를 포함하므로 공개 저장소와 배포 ZIP에서 제외합니다.

## 참고

- [Blackmagic Fusion Fuse SDK](https://documents.blackmagicdesign.com/UserManuals/Fusion_Fuse_SDK.pdf)
- [Blackmagic Fusion Scripting Guide](https://documents.blackmagicdesign.com/UserManuals/Fusion8_Scripting_Guide.pdf)
