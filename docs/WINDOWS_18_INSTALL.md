# Node Wave 2.2.2 — Windows / DaVinci Resolve 18 설치·사용 안내

이 압축파일에는 전용 창 `NodeWaveController.lua`와 이미지 변형 엔진 `NodeWaveDeform.fuse`가 들어 있습니다. 두 파일이 모두 필요합니다. `.setting` 매크로는 사용하지 않습니다.

## 설치

1. DaVinci Resolve를 종료합니다.
2. 파일 탐색기 주소창에 아래 경로를 붙여 넣고 Enter를 누릅니다. 폴더가 없으면 만듭니다. `NodeWaveDeform.fuse`를 복사합니다. Windows가 관리자 권한을 요청할 수 있습니다.

   `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Fuses`

3. 파일 탐색기 주소창에 아래 경로를 붙여 넣고 Enter를 누릅니다. 폴더가 없으면 만듭니다. `NodeWaveController.lua`를 복사합니다.

   `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp`

4. DaVinci Resolve를 다시 실행합니다. 새 Fuse는 실행 시작 시 목록에 등록됩니다.

이 경로는 DaVinci Resolve용입니다. 독립 실행형 Fusion Studio의 설치 경로와 다릅니다.

## 사용

1. Resolve에서 영상을 타임라인에 놓고 Fusion 페이지를 엽니다.
2. MediaIn, Loader, Text+ 등 **이미지를 출력하는 노드**를 선택합니다. 오디오 전용 노드나 3D 출력 노드에는 적용되지 않습니다.
3. 상단 메뉴의 `Workspace(작업 공간) > Scripts(스크립트) > Comp > NodeWaveController`를 실행합니다.
4. `리깅 만들기`를 누릅니다. 생성된 `Node Wave Deform` 노드를 Viewer에 띄우고 Root와 Tip을 이미지에 맞게 드래그합니다.
5. 전용 창에서 값을 정하고 `설정 적용`을 누릅니다. 타임라인의 다른 프레임으로 이동하여 흔들림을 확인합니다. 별도 키프레임은 필요하지 않습니다.
6. 창의 `원본 / 결과`와 `새로고침`으로 선택한 프레임을 비교합니다. 오른쪽 위 버튼으로 한국어/영어를 전환할 수 있습니다.

투명 배경의 머리카락, 리본, 옷 조각 같은 이미지에서 변형을 확인하기 쉽습니다. 창을 닫아도 리깅 노드와 결과는 남습니다.

## 문제 해결

- **스크립트 메뉴에 보이지 않음:** `.lua` 파일이 `Scripts\Comp`에 있는지 확인하고 Resolve를 다시 실행합니다.
- **리깅 만들기 후 엔진을 찾지 못함:** `.fuse` 파일이 `Fuses`에 있는지 확인하고 Resolve를 다시 실행합니다.
- **움직임이 보이지 않음:** `Node Wave Deform`이 MediaIn/Loader와 MediaOut 사이에 연결되었는지 확인합니다. `Amplitude`, `Frequency`, `Speed`가 0보다 큰지 확인하고, Root/Tip을 이미지의 고정점과 끝점에 놓습니다. 0프레임과 25프레임을 비교해 보세요.
- **미리보기가 비어 있음:** 리깅을 선택하고 `새로고침`을 누릅니다. Windows 사용자 임시 폴더(`%TEMP%`)에 파일을 저장할 수 있는지도 확인합니다. Fusion Viewer에서도 최종 결과를 볼 수 있습니다.
- **전용 창이 실행되지 않음:** Resolve 18의 정확한 버전 및 무료판/Studio판을 확인합니다. UIManager 스크립트 접근은 버전과 라이선스에 영향을 받을 수 있습니다.

## 검증 범위

Lua/Fuse 문법, 변형 처리, 전용 창 동작과 Windows 스타일 임시 경로 및 `file:///C:/...` 미리보기 주소는 자동 테스트를 통과했습니다. Windows에서는 `%TEMP%`를 먼저 사용합니다. 실제 **Windows의 DaVinci Resolve 18에서 실행하는 현장 테스트는 아직 수행하지 못했습니다.** 따라서 모든 18.x 빌드의 동작을 보증하지 않습니다. 문제가 있으면 Resolve 18의 세부 버전, 무료판/Studio판, 나타난 오류 문구를 기록해 주세요.

## 제거

Resolve를 종료한 뒤 설치한 `NodeWaveController.lua`와 `NodeWaveDeform.fuse`를 각각 위 폴더에서 삭제하고 Resolve를 다시 실행합니다. 기존 프로젝트에서 Node Wave 노드를 사용했다면 제거 전에 프로젝트를 복사해 보관하세요.

## 참고 문서

- Blackmagic Fusion Fuse SDK: https://documents.blackmagicdesign.com/UserManuals/Fusion_Fuse_SDK.pdf
- Blackmagic Fusion Scripting Guide: https://documents.blackmagicdesign.com/UserManuals/Fusion8_Scripting_Guide.pdf

---

## English quick start

1. Quit DaVinci Resolve. Copy `NodeWaveDeform.fuse` to `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Fuses` (create the folder if needed; administrator permission may be requested).
2. Copy `NodeWaveController.lua` to `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp` (create the folder if needed).
3. Relaunch Resolve 18. In the Fusion page, select an image-producing node, then open `Workspace > Scripts > Comp > NodeWaveController` and click **Create Rig**.
4. View the new `Node Wave Deform` node, drag Root and Tip over the image, adjust settings, and click **Apply**. Move to another frame to see the automatic motion. The top-right button switches between Korean and English.
5. This package has passed source-level and simulated Windows-path tests, but has not yet been run on an actual Windows Resolve 18 installation. If the UI does not open, check the exact 18.x release and whether it is Free or Studio.
