USE classicmodels;

SELECT * FROM employees ;

## concat : 여러 텍스트 문자열이나 셀 범위의 내용을 하나로 합치는 함수
## full_name 이라는 성과 이름을 합친 셀을 조회했다
SELECT CONCAT(firstName, '/', lastName) AS full_name 
FROM employees;


## ifnull : 해당 컬럼의 값이 null 을 반환할때 다른 값으로 출력하게 한다
### ifnull(컬렴명, null 일 경우 대체값)
SELECT * FROM customers ;
 
SELECT
	customerName,
	CONCAT(addressLine1, ',', IFNULL (addressLine2, '')) AS full_address
FROM customers;
## customer 이름과 주소 1,2를 full_address라는 이름으로 
조회하는데, 주소2가 null 일 경우 빈칸을 출력한다


## concat_ws : null 값이 있어도 이를 무시하고 문자열을 연결한다
## concat_ws(구분자, 문자열, 문자열 ...bdai_hw)
SELECT
	customerName,
	CONCAT_WS(',', addressLine1, addressLine2) AS full_address
FROM customers;


## substring(문자열, 시작위치, 길이) 문자열에서 시작위치부터 길이 만큼 출력
SELECT * FROM products;
SELECT SUBSTRING(productCode,5,4) FROM products; 
-- 그러나 해당 함수를 조회했을 때 순서가 기존 테이블과 다르게 출력되었다
-- 그래서 EXPLAIN 함수를 사용하여 실행 계획을 조회하여 productLine이 인덱스로 사용되어
-- producLine의 오름차순으로 정렬되어 있음을 알 수 있었다
-- EXPLAIN SELECT SUBSTRING(productCode,5,4) FROM products; 


## substring + position
## position :  특정 문자열 위치를 반환하다 position('찾을 문자열' in 찾을곳)
SELECT
SUBSTRING(email, 1, POSITION('@' IN email) -1) AS user_id ## 이메일에서 아이디만 추출
FROM employees; 


## coalesce
## null 이 아닌 첫번째 값을 찾아내는 함수
## N개의 컬럼을 넣어서 순차적으로 검사할 수 있다
SELECT
COALESCE(addressLine2, addressLine1, city) ## addressLine1까지 null 이어야 city가 출력됨
FROM customers;



