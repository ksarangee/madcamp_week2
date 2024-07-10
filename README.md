## tidbits 소개
<img width="104" alt="tidbitslogo" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/979feddf-2644-492d-8727-f7752580a9a9">

tidbits는 작지만 흥미로운 이야기들을 공유할 수 있는 커뮤니티 플랫폼입니다. 분야를 넘나드는 지식의 조각들을 만나보세요💡

## 팀원
KAIST 전산학부 19학번 김동연 <a href="https://github.com/doongyeon" target="_blank"><img src="https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white"></a>

이화여자대학교 영어교육과 20학번 김사랑 <a href="https://github.com/ksarangee" target="_blank"><img src="https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white"></a>

## 개발 환경
**Front-end** : Flutter

**IDE** : Visual Studio Code

**Back-end** : Flask

**DB** : MySQL

**CSP** : Amazon S3

## 어플의 구성

### 1️⃣ 로그인 페이지
- 카카오 sdk를 이용하여 로그인 기능을 수행합니다.

<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/eb9926ee-5855-4c79-a335-2dd82adafdbd">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/f4d1f723-4832-4536-9b31-4a5f1ae143ba">

### 2️⃣ 메인 페이지
- 4개의 위젯 스크린으로 구성되어 있습니다. 상단에 위치하는 명언은 5초에 한번씩 다른 명언으로 바뀝니다.
- 각각 Trending Posts, My Interests, Today’s Post, Random Post입니다.
- Trending Posts(인기 글) : 오늘 가장 조회수가 많은 글 10개를 순위별로 보여줍니다.
- My Interests(관심 카테고리) : 유저가 설정해둔 관심 카테고리에 해당하는 글들을 분류해서 보여줍니다.
- Today’s Post(오늘의 글) : 특정 글 하나를 모든 유저가 공통적으로 확인할 수 있는 공간입니다. 버튼을 누르면 해당 글의 상세 페이지로 이동합니다.
- Random Post(랜덤 글) : 글 목록에 있는 글 중 하나를 랜덤하게 보여주고 있고 새로고침 버튼을 누르면 다른 랜덤 글을 볼 수 있습니다. 버튼을 누르면 랜덤 글의 상세 페이지로 이동합니다.


<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/45875313-46b5-4981-aa86-5c9fb4e309e1">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/ece13aeb-46db-44de-8187-ad3f2e30fafa">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/4c5ee541-4ab6-4bd4-ac85-f46ded3c5303">

### 3️⃣ 검색 페이지
- 제목과 내용 두 가지 필터로 원하는 글을 검색할 수 있도록 했습니다.
- '+' 버튼을 눌러 원하는 글을 자유롭게 추가할 수 있습니다.

<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/5fdef6f0-035e-4b05-9d14-71726c1eb623">


### 4️⃣ 글 상세 페이지
- 글의 제목과 이미지, 내용들을 확인할 수 있습니다.
- 다른 사람들이 이 글에 남긴 반응들을 확인하고 자신의 반응도 남길 수 있습니다.
- 다른 사람들이 남긴 댓글을 확인하고 댓글을 작성할 수 있습니다. 잘못 작성한 댓글이 있다면 삭제할 수도 있습니다.
- 상단 오른쪽의 신고 버튼을 이용해 부적절한 내용이 있다면 글을 신고할 수 있습니다.
- 상단 오른쪽의 편집 버튼으로 누구나 글을 수정할 수 있습니다.

<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/35843e58-3789-4b9c-b393-9e2d6f1087f6">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/eb69a0e1-a909-492f-93c0-d22ff53a5345">


### 5️⃣ 글 작성, 편집 페이지
- 글의 카테고리와 제목, 내용을 새로 작성하거나 기존에 있는 글을 수정할 수 있습니다.
- 이미지를 URL을 이용하여 추가하거나 직접 이미지 파일을 업로드 할 수 있습니다.

<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/b035ae6f-76a7-4997-ba14-0c159e8499bd">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/aac64f98-fdb3-4ef7-b8ae-2dd5f705ae25">


### 6️⃣ 프로필 페이지
- 자신의 관심 카테고리를 수정할 수 있습니다.
- 지금까지 좋아요를 표시한 글들을 한번에 확인할 수 있습니다.
- 로그아웃이 가능합니다.

<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/6455f011-7ad0-4f14-a7bb-7f2b5606f4d5">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/9b79b61d-ebce-4d59-a49a-81c159eccf6c">
<img width="250" src="https://github.com/ksarangee/madcampW2_fe/assets/161582130/921680a5-f7a3-4640-baaf-c8adeb540764">

## ERD (Entity Relationship Diagram)
![social_app_schema](https://github.com/ksarangee/madcampW2_fe/assets/161582130/72436f98-8368-4dec-9f76-6c1a77725656)
