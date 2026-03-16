USE classicmodels;

SELECT * FROM orders;

## sql 날짜 함수 살펴 보는 것

SELECT 
	orderNumber, 
	orderDate,
	YEAR(orderDate) AS order_year, 
	MONTH(orderDate) AS order_month, 
	DAYNAME(orderDate) AS day_name
FROM
	orders
WHERE MONTH(orderDate) = '6';

## 날짜 더하기
### 주문일로부터 +2일 뒤 배송 예정일 구하기

SELECT 
	orderNumber,
	orderDate,
	DATE_ADD(orderDate, INTERVAL 2 DAY) AS estimated_delivery
FROM 
orders;

## 소요시간 구하기
WITH ship_cnt AS (
SELECT
	orderNumber,
	DATEDIFF(shippedDate, orderDate) AS days_to_ship
FROM
	orders
	)
SELECT 
	days_to_ship,
	COUNT(distinct orderNumber)
FROM ship_cnt
GROUP BY days_to_ship;

SELECT
	orderNumber,
	DATEDIFF(shippedDate, orderDate) AS days_to_ship
FROM
	orders;
	

## 배송이 지연된 경우만 추출

SELECT 
	orderNumber,
	orderDate,
	requiredDate,
	shippedDate
FROM orders
WHERE DATEDIFF(shippedDate, requiredDate) > 0;


## YOY(전년 동기 대비) MOM(전월 동월 대비)
## 전년 동월 비교
SELECT * from payments;

SELECT
	date_format(p.paymentDate, '%Y-%m') AS current_month,
	SUM(p.amount),
	DATE_FORMAT(DATE_SUB(p.paymentDate, INTERVAL 1 YEAR), '%Y-%m') AS PREV_year_month
FROM payments p
GROUP BY current_month;
#실행 불가-> CTE 사용하여 분해 필요
#cross join 진행

WITH monthlysales AS (
	## 매출 집계 테이블 필요
	select
		DATE_FORMAT(paymentDate, '%Y-%m') AS year_months,
		DATE_FORMAT(paymentDate, '%m') AS month_only,
		YEAR(paymentDate) AS YEAR_only,
		SUM(amount) AS revenue
	from
		payments
	GROUP BY year_months, month_only, year_only
	)
## 셀프 조인 이용하여 yoy계산
SELECT
	curr.year_months AS '현재_월',
	curr.revenue AS '현재_매출', 
	prevs.year_months AS '전년_동월',
	prevs.revenue AS '전년_매출'
FROM
	monthlysales curr
LEFT JOIN monthlysales prevs
	ON curr.month_only = prevs.month_only
	AND curr.year_only = prevs.year_only + 1;

