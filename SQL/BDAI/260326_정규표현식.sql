SELECT * FROM customers;

## 정규표현식 - 패턴을 찾는 것
## LIKE -> 숫자가 포함된 모든 행을 찾아줘, 어떠한 패턴을 찾아줘 하지만 한계가 존재함. 구현하기 어려운 부분이 분명 존재한다. 변칙적
## REGEXP를 사용하여 복잡한 패턴 찾기 -> REGEXP, Regular Expression

## 정규표현식 . 임의의 문자 하나, 
## ^abc -> abc로 시작하는 문자열
## & ㅜㅁㄴ자열의 끝 -> abc$로 끝나는 문자열
## * 앞의 문자가 0번 이상 반복
## + 앞의 문자가 1번 이상 반복
## gpt로 검색해서 필요한 것을 사용하면 된다.

SELECT * FROM customers;

## 유효하지 않은 전화 패턴 탐지
## 특수문자, 잘못된 전화번호 등은 다 정리해서 국가코드 없이. 예를 들어 숫자 2~3자리 - 3~4자리 - 수자 4자리 형식 아닌것은 다 잘못된정보다 체크하는 것

SELECT
	customerName,
	phone
FROM customers
WHERE phone NOT REGEXP '^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}' ; ## 이형식이 아닌애들을 골라냄


## 회사 메일중 잘못된 주소로 가입한 사람
SELECT
	employeeNUmber,
	email
FROM employees
WHERE email NOT REGEXP '@classicmodelcars\.com$';


## 배송이 단순히 늦었다가 아닌, 고객의 세그먼트 vip 고객인데 배송이 실제로 늦어서 우리 회사가 환불을 해야하는것 아닌가? 알고 싶은 것
## 고객에 따라 세그먼트를 구분할 수 있다. VIP Regular / 배송기한을 하루라도 늦으면 문제가 있다. / 일반 고객은 배송이 3일인데 vip는 1일 이내로 가야한다.
## 패널티를 계산하여 -> 실제 주문금액에서 손실액 10% 가 나올 수 있다
## 이슈가 있는 데이터를 찾아보는 것

## -> CTE(Common Table Expression(공통 테이블 식)의 약자로, "쿼리 안에서 임시로 이름표를 붙여놓은 결과물")로 데이터 정리가 필요. 매출에 대한 데이터 정리 필요
SELECT * FROM customers; 

WITH OrderTotals AS (
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS totalamount
FROM orderdetails
GROUP BY orderNumber )
SELECT * FROM ordertotals;

## 고객 등급 나누기
SELECT * FROM customers; 

WITH OrderTotals AS (
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS totalamount
FROM orderdetails
GROUP BY orderNumber )
SELECT 
	o.orderNumber,
	c.customerName,
	## 고객사 등급 나누기
	if(c.customerName REGEXP 'Gifts|Diecast', 'VIP', 'Regular') AS cutomer_tier
	
FROM orders AS o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderTotals ot ON o.orderNumber = ot.orderNumber;


## 배송 소요시간 구하기
SELECT * FROM customers; 

WITH OrderTotals AS (
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS totalamount
FROM orderdetails
GROUP BY orderNumber )
SELECT 
	o.orderNumber,
	c.customerName,
	## 고객사 등급 나누기
	if(c.customerName REGEXP 'Gifts|Diecast', 'VIP', 'Regular') AS cutomer_tier,
	## 배송소요시간
	COALESCE(CAST(DATEDIFF(o.shippedDate, o.orderDate) AS CHAR),'In transit') AS shipping_days,
	case
		## 아직 배송 전인데 약속 날짜가 지난 경우
		when o.shippedDate IS NULL AND o.requiredDate < CURRENT_DATE() then 'EXPEDITED'
		## 아직 배송 전인데 좀 여유가 있다.
		 when o.shippedDate IS NULL then 'On Schedule'
		## vip 하루라도 늦은 경우
		 when c.customerName REGEXP 'Gift|Diecast' AND DATEDIFF(o.shippedDate, o.requiredDate) > 0 then 'CRITICAL DELAY'
		## 일반 고객
		when DATEDIFF(o.shippedDate, o.requiredDate) > 3 then 'MAJOR DELAY'
		ELSE 'On Time'
	end AS sla_status
FROM orders AS o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderTotals ot ON o.orderNumber = ot.orderNumber;


