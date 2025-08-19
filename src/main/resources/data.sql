INSERT IGNORE INTO gr_user (id, email)
VALUES (1, 'test@example.com');

INSERT INTO monthly_charge (`user_id`, `ym`, `day`, `elec`, `gas`) VALUES
(1, '2025-08', 1, 10, 10),
(1, '2025-08', 2, 20, 15),
(1, '2025-08', 3, 20, 15)
ON DUPLICATE KEY UPDATE
  elec = VALUES(elec),
  gas  = VALUES(gas);

-- 절약 목표
INSERT INTO save_width_bar (user_id, ym, category, target_amount, used_amount)
VALUES
(1, '2025-08', 'elec', 10000, 5380),  -- 전기: 목표 10,000 / 사용 5,380
(1, '2025-08', 'gas',  30000, 20000)  -- 가스: 목표 30,000 / 사용 20,000
ON DUPLICATE KEY UPDATE
  target_amount = VALUES(target_amount),
  used_amount   = VALUES(used_amount);

-- 세로바(랭킹)
-- 내 기록: 84%
INSERT INTO save_length_bar (user_id, area, ym, success_count, total_count)
VALUES (1, '안서동', '2025-08', 84, 100)
ON DUPLICATE KEY UPDATE
  area          = VALUES(area),
  success_count = VALUES(success_count),
  total_count   = VALUES(total_count);

-- 동네 유저들 (평균 28%, 내 위로 90% 1명)
INSERT INTO save_length_bar (user_id, area, ym, success_count, total_count) VALUES
(2 , '안서동', '2025-08', 90, 100),
(3 , '안서동', '2025-08', 17, 100),
(4 , '안서동', '2025-08', 19, 100),
(5 , '안서동', '2025-08', 13, 100),
(6 , '안서동', '2025-08', 17, 100),
(7 , '안서동', '2025-08', 21, 100),
(8 , '안서동', '2025-08', 14, 100),
(9 , '안서동', '2025-08', 23, 100),
(10, '안서동', '2025-08', 22, 100),
(11, '안서동', '2025-08', 24, 100),
(12, '안서동', '2025-08', 19, 100),
(13, '안서동', '2025-08', 16, 100),
(14, '안서동', '2025-08', 17, 100),
(15, '안서동', '2025-08', 24, 100)
ON DUPLICATE KEY UPDATE
  area          = VALUES(area),
  success_count = VALUES(success_count),
  total_count   = VALUES(total_count);

  -- elec=200(kWh) → 200*106=21,200원
  -- gas =30(m³)   → 30*960 =28,800원
  -- 합계 50,000원 - 무시해도 될 값? 혹시 몰라 넣어둠
  INSERT INTO monthly_charge (user_id, ym, day, elec, gas)
  VALUES (1, '2025-07', NULL, 200, 30)
  ON DUPLICATE KEY UPDATE
    elec = VALUES(elec),
    gas  = VALUES(gas);

  -- 이번 달 목표 초기값
  -- 처음 0원으로 시작 > 이후 1,000~200,000 입력
  INSERT INTO this_month_goal (user_id, period_ym, goal_won)
  VALUES (1, '2025-08', 0)
  ON DUPLICATE KEY UPDATE
    goal_won = VALUES(goal_won);
