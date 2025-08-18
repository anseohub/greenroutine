INSERT IGNORE INTO gr_user (id, email)
VALUES (1, 'test@example.com');

INSERT INTO monthly_charge (`user_id`, `ym`, `day`, `elec`, `gas`) VALUES
(1, '2025-08', 1, 10, 500),
(1, '2025-08', 2, 20,   0),
(1, '2025-08', 3, 30, 300)
ON DUPLICATE KEY UPDATE
  elec = VALUES(elec),
  gas  = VALUES(gas);


--1(세 번째 값) → 그 달의 며칠인지
--10(네 번째 값) → 전기사용량
--500(다섯 번째 값) → 가스요금
