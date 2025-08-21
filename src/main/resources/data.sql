-- ========= 초기화: 자식 → 부모 순으로 =========
DELETE FROM save_width_bar   WHERE ym IN ('2025-08');
DELETE FROM save_length_bar  WHERE ym='2025-08' AND area='안서동';
DELETE FROM this_month_goal  WHERE period_ym='2025-08';
DELETE FROM saving_goal      WHERE period_ym='2025-08';
DELETE FROM monthly_charge   WHERE ym IN ('2025-07','2025-08');
DELETE FROM usage_log        WHERE DATE(ts)='2025-08-19';
DELETE FROM tip_rule;
DELETE FROM user_preference  WHERE user_id IN (SELECT id FROM gr_user WHERE email='test@example.com');
DELETE FROM alert            WHERE created_at BETWEEN '2025-07-01 00:00:00' AND '2025-08-31 23:59:59';
DELETE FROM gr_user          WHERE email='test@example.com';

-- ========= 사용자(자동증가 id 환경 호환) =========
INSERT INTO gr_user (email) VALUES ('test@example.com');

-- ========= 공통 유저 id 서브쿼리 =========
-- 모든 아래 INSERT에서는 다음 표현을 사용:
-- (SELECT id FROM gr_user WHERE email='test@example.com')

-- ========= 월별/일별 사용량 =========
INSERT INTO monthly_charge (user_id, ym, `day`, elec, gas)
SELECT id, '2025-07', 1, 12, 0 FROM gr_user WHERE email='test@example.com';
INSERT INTO monthly_charge (user_id, ym, `day`, elec, gas)
SELECT id, '2025-07', 2, 11, 0 FROM gr_user WHERE email='test@example.com';
INSERT INTO monthly_charge (user_id, ym, `day`, elec, gas)
SELECT id, '2025-07', 3, 15, 0 FROM gr_user WHERE email='test@example.com';
-- ...(중략) 동일 패턴으로 2025-07 4~31일까지
INSERT INTO monthly_charge (user_id, ym, `day`, elec, gas)
SELECT id, '2025-07', 31, 13, 0 FROM gr_user WHERE email='test@example.com';

-- 2025-08 (1~25)
INSERT INTO monthly_charge (user_id, ym, `day`, elec, gas)
SELECT id, '2025-08', 1, 10, 0 FROM gr_user WHERE email='test@example.com';
-- ...(중략) 동일 패턴으로 2~24
INSERT INTO monthly_charge (user_id, ym, `day`, elec, gas)
SELECT id, '2025-08', 25, 10, 0 FROM gr_user WHERE email='test@example.com';

-- ========= SaveWidthBar(가로바) =========
INSERT INTO save_width_bar (user_id, ym, category, target_amount, used_amount)
SELECT id, '2025-08', 'elec', 10000, 5380 FROM gr_user WHERE email='test@example.com';
INSERT INTO save_width_bar (user_id, ym, category, target_amount, used_amount)
SELECT id, '2025-08', 'gas', 30000, 20000 FROM gr_user WHERE email='test@example.com';

-- ========= SaveLengthBar(랭킹) =========
INSERT INTO save_length_bar (user_id, area, ym, success_count, total_count)
SELECT id, '안서동', '2025-08', 84, 100 FROM gr_user WHERE email='test@example.com';

-- 이웃들(고정 id가 없어도 됨: save_length_bar.user_id가 FK가 아니라면 아래 그대로 사용)
-- FK가 걸려 있다면, 더미 유저를 먼저 gr_user에 추가한 뒤 해당 id로 넣어야 합니다.
INSERT INTO save_length_bar (user_id, area, ym, success_count, total_count) VALUES
(1002,'안서동','2025-08',90,100),
(1003,'안서동','2025-08',17,100),
(1004,'안서동','2025-08',21,100),
(1005,'안서동','2025-08',19,100),
(1006,'안서동','2025-08',23,100);

-- ========= 이번 달 목표(슬라이더) =========
INSERT INTO this_month_goal (user_id, period_ym, goal_won)
SELECT id, '2025-08', 50000 FROM gr_user WHERE email='test@example.com';

-- ========= 대시보드 절약 목표 =========
INSERT INTO saving_goal (user_id, period_ym, saving_goal_won)
SELECT id, '2025-08', 50000 FROM gr_user WHERE email='test@example.com';

-- ========= TipService: 선호 + 룰 =========
INSERT INTO user_preference (user_id, housing_type, has_double_door, window_type)
SELECT id, '원룸', 0, '단창' FROM gr_user WHERE email='test@example.com';

-- 전기
INSERT INTO tip_rule (housing_type, has_double_door, window_type, utility, priority, message)
VALUES
('원룸', 0, '단창', 'ELEC', 0, '단창이면 낮 일사 차단! 블라인드/암막으로 에어컨 효율 업 🌞'),
(NULL  ,NULL, NULL , 'ELEC', 1, '에어컨 26~27℃ + 선풍기 병행으로 체감온도만 낮추기 ❄️'),
(NULL  ,NULL, NULL , 'ELEC', 2, '대기전력 멀티탭 OFF로 전기 누수 컷 🔌');

-- 가스
INSERT INTO tip_rule (housing_type, has_double_door, window_type, utility, priority, message)
VALUES
('원룸', NULL, NULL , 'GAS', 0, '보일러 외출/예약 모드로 불필요 가동 최소화 ⏱️'),
(NULL  ,NULL, '단창', 'GAS', 1, '창틀 틈 보수(실리콘/패킹)로 열손실 잡기 🔧'),
(NULL  ,NULL, NULL , 'GAS', 2, '온수는 가열 후 OFF, 샤워는 10분 내로 🚿');

-- ========= MetricsService 라인차트(하루치) =========
-- 첫 한 줄은 OK (user_id 서브쿼리)
INSERT INTO usage_log (user_id, ts, elec, gas)
SELECT id, TIMESTAMP '2025-08-19 00:00:00', 1, 0
FROM gr_user WHERE email='test@example.com';

-- 나머지 00~23시는 user_id 하드코딩(1) 제거 → 공통 서브쿼리로 일괄 삽입
INSERT INTO usage_log (user_id, ts, elec, gas)
SELECT gu.id, x.ts, x.elec, x.gas
FROM gr_user gu
JOIN (
  -- 00~05 저부하
  SELECT TIMESTAMP '2025-08-19 00:00:00' AS ts, 1 AS elec, 0 AS gas UNION ALL
  SELECT TIMESTAMP '2025-08-19 01:00:00', 1, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 02:00:00', 0, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 03:00:00', 0, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 04:00:00', 0, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 05:00:00', 1, 0 UNION ALL
  -- 06~09 출근/샤워 피크
  SELECT TIMESTAMP '2025-08-19 06:00:00', 1, 2 UNION ALL
  SELECT TIMESTAMP '2025-08-19 07:00:00', 2, 2 UNION ALL
  SELECT TIMESTAMP '2025-08-19 08:00:00', 2, 1 UNION ALL
  SELECT TIMESTAMP '2025-08-19 09:00:00', 2, 1 UNION ALL
  -- 10~16 주간 전기↑
  SELECT TIMESTAMP '2025-08-19 10:00:00', 3, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 11:00:00', 4, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 12:00:00', 4, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 13:00:00', 4, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 14:00:00', 4, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 15:00:00', 4, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 16:00:00', 3, 0 UNION ALL
  -- 17~21 저녁 피크
  SELECT TIMESTAMP '2025-08-19 17:00:00', 3, 1 UNION ALL
  SELECT TIMESTAMP '2025-08-19 18:00:00', 4, 1 UNION ALL
  SELECT TIMESTAMP '2025-08-19 19:00:00', 4, 2 UNION ALL
  SELECT TIMESTAMP '2025-08-19 20:00:00', 3, 2 UNION ALL
  SELECT TIMESTAMP '2025-08-19 21:00:00', 3, 1 UNION ALL
  -- 22~23 감소
  SELECT TIMESTAMP '2025-08-19 22:00:00', 2, 0 UNION ALL
  SELECT TIMESTAMP '2025-08-19 23:00:00', 1, 0
) x ON 1=1
WHERE gu.email='test@example.com';

-- 1) BILL 알림
INSERT INTO alert
(`user_id`,`category`,`level`,`title`,`subtitle`,`title_exp`,`created_at`,`is_read`,`yes_read`)
SELECT id,
       'BILL',
       '알림',
       '8월 중간 정산 알림',                 -- title (필수)
       '이번 달 중간 정산 안내',              -- subtitle (필수, 임의 문구)
       '8월 중간 정산 알림',                 -- title_exp (필수)
       STR_TO_DATE('2025-08-15 09:00:00.000000','%Y-%m-%d %H:%i:%s.%f'), -- DATETIME(6)
       b'0',                                  -- is_read (BIT(1))
       b'0'                                   -- yes_read (BIT(1))
FROM gr_user WHERE email='test@example.com';

-- 2) 전기 경고
INSERT INTO alert
(`user_id`,`category`,`level`,`title`,`subtitle`,`title_exp`,`created_at`,`is_read`,`yes_read`)
SELECT id,
       '전기',
       '경고',
       '저녁 시간대 전력 급증 감지',          -- title
       '8/19 20:05 전력 사용량 급증',          -- subtitle
       '8/19 저녁 시간대 전력 급증 감지',      -- title_exp
       STR_TO_DATE('2025-08-19 20:05:00.000000','%Y-%m-%d %H:%i:%s.%f'),
       b'0',
       b'0'
FROM gr_user WHERE email='test@example.com';
