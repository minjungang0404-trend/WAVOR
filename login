<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>WAVOR - Official Entry</title>
    <style>
        /* 1. 화면 잘림 방지 및 이미지 기반 그라데이션 */
        body, html {
            margin: 0; padding: 0; width: 100%; min-height: 100%;
            font-family: 'Apple SD Gothic Neo', sans-serif;
            background: linear-gradient(180deg, #D6249F, #FF3366, #ED9121);
            display: flex; justify-content: center; align-items: center;
            color: white; overflow-x: hidden;
        }

        .phone-container {
            width: 100%; max-width: 450px; min-height: 100vh;
            display: flex; flex-direction: column; align-items: center;
            padding: 40px 20px; box-sizing: border-box; position: relative;
        }

        /* 2. WAVOR 로고 섹션 (이미지 1번 스타일) */
        .header { margin-top: 60px; text-align: center; margin-bottom: auto; }
        .header h1 { font-size: 65px; font-weight: 900; margin: 0; letter-spacing: -2px; }
        .header p { font-size: 16px; opacity: 0.9; margin-top: 10px; }

        /* 3. 섹션 컨트롤 (로그인 / 약관) */
        .auth-card {
            width: 100%; display: none; flex-direction: column; gap: 15px;
            background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(15px);
            padding: 25px; border-radius: 25px; border: 1px solid rgba(255, 255, 255, 0.2);
            box-sizing: border-box; margin-bottom: 40px;
        }
        .active-section { display: flex; animation: fadeIn 0.5s; }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        /* 4. 버튼 및 입력창 스타일 (이미지 4번 스타일) */
        .btn-google {
            background: white; color: #333; border: none; padding: 18px;
            border-radius: 15px; font-size: 16px; font-weight: bold;
            display: flex; align-items: center; justify-content: center; gap: 12px;
            cursor: pointer; width: 100%; transition: 0.3s;
        }

        .terms-text {
            height: 200px; overflow-y: auto; font-size: 13px; line-height: 1.6;
            background: rgba(0,0,0,0.1); padding: 15px; border-radius: 10px; margin-bottom: 15px;
        }

        /* 5. 보상 알림 (럭셔리 모달) */
        #reward-pop {
            display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
            background: white; color: #333; padding: 35px; border-radius: 30px;
            text-align: center; width: 80%; max-width: 320px; z-index: 100;
        }
    </style>
</head>
<body>

    <div class="phone-container">
        <div class="header">
            <h1>WAVOR</h1>
            <p>Catch Your Wave, Define Your Vibe</p>
        </div>

        <!-- 섹션 1: 구글 로그인 (가장 먼저 수행) -->
        <div id="section-login" class="auth-card active-section">
            <button class="btn-google" id="google-login-btn">
                <img src="https://upload.wikimedia.org/wikipedia/commons/5/53/Google_Icons-09.svg" width="20">
                Google 계정으로 시작하기
            </button>
            <p style="font-size: 13px; text-align: center; opacity: 0.8;">신규 가입 시 100P가 즉시 적립됩니다.</p>
        </div>

        <!-- 섹션 2: 이용약관 동의 (로그인 후에만 등장) -->
        <div id="section-terms" class="auth-card">
            <h3 style="margin-top:0">서비스 이용약관 동의</h3>
            <div class="terms-text">
                <strong>제 1 장 총 칙</strong><br>
                본 약관은 'Creator K'가 운영하는 'WAVOR' 이용에 관한 사항을 규정합니다. 본 서비스는 만 19세 이상의 성인만을 대상으로 합니다.<br><br>
                <strong>제 4 조 기망 행위 책임</strong><br>
                미성년자가 허위 정보를 입력하여 가입할 경우 민법 제17조에 따라 환불 및 모든 법적 책임은 유저에게 귀속됩니다.
            </div>
            <label style="display:flex; align-items:center; gap:10px; font-size:14px; cursor:pointer;">
                <input type="checkbox" id="terms-cb"> 약관을 모두 확인했으며 동의합니다.
            </label>
            <button class="btn-google" id="agree-btn" style="margin-top:15px; background:#333; color:white" disabled>WAVOR 입성하기</button>
        </div>
    </div>

    <!-- 펄스 지급 성공 모달 -->
    <div id="reward-pop">
        <h2 style="color: #FF3366; margin:0">100P 지급 완료!</h2>
        <p style="margin: 20px 0; font-size: 15px;">강민준 어드민님의 특별 환영 선물!<br>지금 바로 웨이브를 시작하세요.</p>
        <button class="btn-google" style="background:#333; color:white" onclick="location.href='main.html'">대시보드로 이동</button>
    </div>

    <!-- Firebase SDK 및 로직 -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-app.js";
        import { getAuth, signInWithPopup, GoogleAuthProvider } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-auth.js";
        import { getFirestore, doc, getDoc, setDoc, updateDoc } from "https://www.gstatic.com/firebasejs/10.11.1/firebase-firestore.js";

        // 민준님의 설정값 적용
        const firebaseConfig = {
            apiKey: "AIzaSyAs_RfXHZl73ilrXn-18vKVVMqu2C7AINk",
            authDomain: "wavor-25e69.firebaseapp.com",
            projectId: "wavor-25e69",
            storageBucket: "wavor-25e69.firebasestorage.app",
            appId: "1:55424852930:web:9c384925db9f145e12bdc3"
        };

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app);
        const provider = new GoogleAuthProvider();

        let currentUser = null;

        // 1. 구글 로그인 실행
        document.getElementById('google-login-btn').onclick = async () => {
            try {
                const result = await signInWithPopup(auth, provider);
                currentUser = result.user;

                // DB에서 기존 유저인지 확인
                const userDoc = await getDoc(doc(db, "users", currentUser.uid));

                if (!userDoc.exists()) {
                    // 신규 유저라면 -> 약관 동의 섹션으로 이동
                    document.getElementById('section-login').classList.remove('active-section');
                    document.getElementById('section-terms').classList.add('active-section');
                } else {
                    // 이미 가입된 유저라면 바로 대시보드행
                    location.href = 'main.html';
                }
            } catch (e) { alert("로그인 실패: " + e.message); }
        };

        // 2. 약관 동의 및 최종 가입 (펄스 지급)
        const cb = document.getElementById('terms-cb');
        const agreeBtn = document.getElementById('agree-btn');

        cb.onchange = () => { agreeBtn.disabled = !cb.checked; };

        agreeBtn.onclick = async () => {
            if (!currentUser) return;

            // Firestore에 유저 정보 및 초기 100P 저장
            await setDoc(doc(db, "users", currentUser.uid), {
                name: currentUser.displayName,
                email: currentUser.email,
                pulse: 100, // 가입 축하 100P
                level: "Lv.1 ORIGIN",
                termsAgreed: true,
                joinDate: new Date()
            });

            document.getElementById('section-terms').style.opacity = '0.3';
            document.getElementById('reward-pop').style.display = 'block';
        };
    </script>
</body>
</html>
