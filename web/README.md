# Fishing Booking Web Application

이 프로젝트는 [Next.js](https://nextjs.org/)로 구축된 낚시 예약 웹 애플리케이션입니다.

## 시작하기

개발 서버를 실행하세요:

```bash
npm run dev
# 또는
yarn dev
# 또는
pnpm dev
```

브라우저에서 [http://localhost:3000](http://localhost:3000)을 열어 결과를 확인하세요.

페이지를 수정하려면 `src/pages/index.tsx`를 편집하세요. 파일을 저장하면 페이지가 자동으로 업데이트됩니다.

## 프로젝트 구조

```
web/
├── src/
│   ├── components/     # React 컴포넌트
│   ├── pages/         # Next.js 페이지 및 API 라우트
│   └── styles/        # CSS 스타일 파일
├── public/            # 정적 파일
└── ...
```

## 기술 스택

- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: Styled Components
- **Real-time Communication**: Socket.IO, STOMP.js

## 스크립트

- `npm run dev` - 개발 서버 실행
- `npm run build` - 프로덕션 빌드
- `npm run start` - 프로덕션 서버 실행
- `npm run lint` - ESLint 실행

## Docker

Docker를 사용하여 애플리케이션을 실행할 수 있습니다:

```bash
docker build -t fishing-booking-web .
docker run -p 3000:3000 fishing-booking-web
```

## 더 알아보기

Next.js에 대해 더 알아보려면 다음 리소스를 확인하세요:

- [Next.js Documentation](https://nextjs.org/docs) - Next.js 기능 및 API에 대해 알아보세요.
- [Learn Next.js](https://nextjs.org/learn) - 대화형 Next.js 튜토리얼.

Next.js GitHub 저장소를 확인해보세요 - 여러분의 피드백과 기여를 환영합니다!
