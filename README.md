# Node Wave 2.3.0 preview — Fusion 관절 포인트 자동 흔들림

Node Wave는 DaVinci Resolve Fusion의 2D 이미지에 Root, 관절, Tip을 놓고 키프레임 없이 이미지를 휘게 만드는 플러그인입니다. After Effects의 퍼펫 메쉬를 생성하지 않습니다. Fusion 화면에서 옮기는 포인트를 따라 국소적인 픽셀 변형을 계산합니다. MediaIn, Loader, 투명 PNG, Text+처럼 이미지를 출력하는 노드에 적용합니다.

## 배포 파일

- [macOS ZIP 다운로드](dist/macOS/NodeWave-2.3.0-preview-macOS.zip?raw=1) — Mac 설치 안내 포함
- [Windows / Resolve 18 ZIP 다운로드](dist/Windows/NodeWave-2.3.0-preview-Windows.zip?raw=1) — Windows 설치 안내 포함

두 ZIP은 같은 변형 엔진과 한국어·영어 전용 창을 포함합니다. 운영체제별 설치 경로와 미리보기 임시 경로만 다릅니다. 이 버전은 **관절 기능 미리보기 배포본**입니다. 실제 Resolve에서 새 관절 기능의 화면 조작과 렌더를 확인하기 전까지 완성판으로 간주하지 마세요.

## 사용법

1. Fusion에서 이미지를 출력하는 노드를 선택합니다.
2. `작업 공간 > 스크립트 > Comp > NodeWaveController`에서 **리깅 만들기**를 누릅니다.
3. 생성된 `Node Wave Deform` 노드를 Viewer에 띄우고 Root와 Tip을 배치합니다.
4. **관절 추가**를 누르면 두 포인트 사이에 새 관절이 생깁니다. Viewer에서 관절을 끌어 원하는 굽힘 위치에 놓습니다. Root·Tip을 포함해 최대 6포인트까지 사용할 수 있습니다.
5. 설정을 조절하고 **설정 적용**을 누릅니다. 재생하거나 다른 프레임으로 이동하면 각 관절이 시간차를 두고 자동으로 움직입니다. **마지막 관절 제거**로 하나씩 되돌릴 수 있습니다.

관절 포인트는 체인 순서로 작동합니다: `Root → Joint 1 → … → Tip`. 여러 갈래의 머리카락이나 잎은 각각 별도 리깅을 사용하는 것이 적합합니다. 기존 2포인트 리깅은 같은 계산 경로를 유지합니다. `.setting` 매크로 없이 `scripts/NodeWaveController.lua`와 `fuses/NodeWaveDeform.fuse` 두 파일을 사용합니다.

## 계산 방식과 범위

메쉬나 물리 시뮬레이션 없이 관절별 흔들림을 프레임마다 한 번 계산합니다. 영향 반경(`Falloff`) 안의 픽셀만 관절 체인에 맞춰 재샘플링하고, 구간별 경계 검사로 영향 밖 계산을 건너뜁니다. 알파 채널은 함께 샘플링합니다. 같은 프레임은 같은 결과를 냅니다. **성능 모드나 화질 차등 설정은 없습니다.**

이 방식은 리본, 머리카락 한 가닥, 옷자락처럼 하나의 길을 따라 휘는 대상에 맞습니다. 넓은 천 전체나 분기된 관절 구조를 한 노드에서 조종하는 기능은 아직 없습니다. Object Mode도 미구현입니다.

## 검증 상태

Lua/Fuse 문법, 2포인트 기존 동작, 4·6포인트 변형, 관절 이동 효과, Root 고정, 동일 프레임 재현성, Mac·Windows 전용 창 모의 테스트를 통과했습니다 (`python3 tests/run_lua_tests.py`). macOS Resolve 19.0.3에서는 이전 2포인트 버전의 실제 출력 변화를 확인했습니다. **새 관절 기능은 실제 Resolve에서 아직 검증하지 못했으며, Windows Resolve 18도 현장 검증 전입니다.**

개발용 `examples/NodeWaveTwoPoint.comp`는 개인 Mac 경로와 캐시 정보를 포함하므로 공개 저장소·배포 ZIP에서 제외합니다.

## 공식 개발 문서

- [Blackmagic Fusion Fuse SDK](https://documents.blackmagicdesign.com/UserManuals/Fusion_Fuse_SDK.pdf)
- [Blackmagic Fusion Scripting Guide](https://documents.blackmagicdesign.com/UserManuals/Fusion8_Scripting_Guide.pdf)
