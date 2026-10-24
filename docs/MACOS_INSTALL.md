# Node Wave 2.3.0 preview — macOS 설치·사용 안내

압축파일의 `NodeWaveController.lua`는 전용 창, `NodeWaveDeform.fuse`는 실제 이미지 변형 엔진입니다. 두 파일을 모두 설치해야 합니다. `.setting` 매크로는 필요하지 않습니다.

## 설치

1. DaVinci Resolve를 종료합니다.
2. Finder에서 `이동 > 폴더로 이동…`을 열고 아래 경로를 붙여 넣습니다. 폴더가 없으면 만듭니다. `NodeWaveDeform.fuse`를 복사합니다.

   `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Fuses`

3. 같은 방법으로 아래 경로를 열고 `NodeWaveController.lua`를 복사합니다.

   `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Comp`

4. DaVinci Resolve를 다시 실행합니다. 새 Fuse가 실행 시작 시 등록됩니다.

위 경로는 **DaVinci Resolve**의 사용자별 설치 위치입니다. 독립 실행형 Fusion Studio의 경로와 다릅니다.

## 사용

1. Fusion 페이지에서 MediaIn, Loader, Text+처럼 이미지를 출력하는 노드를 선택합니다.
2. `작업 공간 > 스크립트 > Comp > NodeWaveController`를 실행하고 `리깅 만들기`를 누릅니다.
3. 생성된 `Node Wave Deform` 노드를 Viewer에 띄우고 Root와 Tip을 이미지의 고정점과 흔들릴 끝점에 놓습니다.
4. `관절 추가`를 누르고 새 Joint 포인트를 Viewer에서 끌어 원하는 굽힘 위치에 놓습니다. Root와 Tip을 포함해 최대 6포인트입니다. `마지막 관절 제거`로 되돌릴 수 있습니다.
5. 전용 창에서 값을 설정한 다음 `설정 적용`을 누릅니다. 다른 프레임으로 이동하면 포인트별 시간차가 있는 흔들림이 생깁니다.
6. `원본 / 결과`와 `새로고침`으로 원하는 프레임을 비교합니다. 창 오른쪽 위 버튼으로 한국어와 영어를 바꿀 수 있습니다.

전용 창을 닫아도 리깅은 프로젝트에 남습니다. 미리보기는 macOS의 임시 폴더(`TMPDIR`)에 저장되고 창을 닫을 때 지워집니다. 최종 영상은 Fusion 노드에서 렌더링합니다.

## 문제 해결

- **스크립트가 메뉴에 없음:** `.lua` 파일 위치를 확인하고 Resolve를 다시 실행합니다.
- **리깅을 만들 수 없음:** `.fuse` 파일 위치를 확인하고 Resolve를 다시 실행합니다. 이미지를 출력하는 노드를 선택했는지도 확인합니다.
- **움직임이 안 보임:** `Node Wave Deform`이 출력 경로에 연결됐는지 확인합니다. Root·관절·Tip을 대상 이미지에 놓고 `Amplitude`, `Frequency`, `Speed`가 0보다 큰지 확인합니다. 0프레임과 25프레임을 비교합니다.
- **관절 추가가 안 됨:** 새 `.fuse`와 `.lua`를 모두 복사한 뒤 Resolve를 다시 실행합니다. 예전 엔진이 등록된 세션에서는 새 포인트를 만들 수 없습니다.
- **미리보기가 비어 있음:** 리깅을 선택한 뒤 `새로고침`을 누릅니다. Fusion Viewer에서도 결과를 확인할 수 있습니다.

## 검증 범위

macOS Resolve 19.0.3에서 이전 2포인트 버전의 출력 변화를 확인했습니다. 이번 2.3.0 관절 기능은 문법·렌더 모의 테스트와 Mac 경로 테스트를 통과했지만, Resolve에 설치해 화면 조작과 실제 렌더를 확인하지는 못했습니다. 새 엔진은 설치 후 Resolve를 다시 실행해야 등록됩니다.

## 제거

Resolve를 종료하고 위 두 위치에서 `NodeWaveDeform.fuse`와 `NodeWaveController.lua`를 삭제한 뒤 Resolve를 다시 실행합니다. 기존 프로젝트에서 해당 노드를 사용한다면 제거 전에 프로젝트를 복사해 보관하세요.

---

## English quick start

Quit Resolve. Copy `NodeWaveDeform.fuse` to `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Fuses` and `NodeWaveController.lua` to `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Comp`. Create the folders if needed, then relaunch Resolve. On the Fusion page, select an image-producing node and open `Workspace > Scripts > Comp > NodeWaveController`. Click **Create Rig**, position Root and Tip, then click **Add Joint** and drag each new point in the Viewer. Up to four joints can be added. Click **Apply** to update motion. The top-right button switches the UI between Korean and English.
