
/* Table*/
SELECT *
FROM dbo.hotel_guest_booking;
SELECT *
FROM service_usage_info;
SELECT *
FROM payment_table;

--Check Data Type
select column_name, data_type
from information_schema.COLUMNS
where table_name = 'hotel_guest_booking' and table_schema = 'dbo';

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name = 'service_usage_info' and TABLE_SCHEMA = 'dbo';

select column_name, data_type
from INFORMATION_SCHEMA.COLUMNS
where table_name = 'payment_table' and TABLE_SCHEMA = 'dbo';
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Xác định các trường hợp trong một ngày cùng 1 phòng có 2 hoặc hơn lượng bookings */
with filter_conf as (
SELECT	
		H1.full_name, 
		H1.booking_id, H1.customer_id, H1.room_id,
		H1.check_in, H1.check_out, 
		H1.room_number, H1.room_type, 
		H1.status, H1.room_status, H1.booking_flag
FROM hotel_guest_booking H1
JOIN
		(select check_in, room_number
		from hotel_guest_booking
		group by check_in, room_number
		having count(room_number) >=2 ) H2
ON H1.check_in = H2.check_in
and H1.room_number = H2.room_number),
count_conf_each_date as (
SELECT	*,
		COUNT(check_in) OVER (PARTITION BY check_in, room_number) as count_check_in_confirmed
FROM filter_conf
WHERE status ='Confirmed'
)
SELECT	full_name, booking_id, customer_id, room_id,
		check_in, check_out, 
		room_number, room_type, 
		status, room_status, booking_flag
FROM count_conf_each_date
WHERE count_check_in_confirmed >=2
ORDER BY check_in asc;


/* Tạo bảng booking_flag - Gắn Flag Double Booking cho các trường hợp 1 ngày có 2 booking cùng 1 phòng */
SELECT *
FROM payment_table
WHERE booking_id IN (488, 947, 1765, 105, 4205, 2504, 4948, 2062, 2514, 3220, 1661, 3197, 2547, 2772, 4655, 4789, 2376, 4992, 2353, 2845)
ORDER BY  booking_id asc;

SELECT *
FROM service_usage_info
WHERE booking_id IN (488, 947, 1765,2062, 2514, 1661,  2547,  4789, 4992, 2353) -- No: 488 & 2353
ORDER BY booking_id asc;

ALTER TABLE hotel_guest_booking
ADD booking_flag varchar(50);

UPDATE  hotel_guest_booking
SET booking_flag = 'Double Booking'
WHERE booking_id IN (
  488, 947, 1765, 105, 4205, 2504, 4948, 2062, 2514, 3220,
  1661, 3197, 2547, 2772, 4655, 4789, 2376, 4992, 2353, 2845
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Pending & Cancelled có trong payment_table (2.694 rows) */
SELECT	B1.payment_id, B2.customer_id, B1.booking_id, B2.room_id,
		B1.payment_method, B2.status as booking_status , B2.room_status,
		B2.check_in, B2.check_out, datediff(day, B2.check_in, B2.check_out) as stay_duration, B1.payment_date,
		B2.room_number, B2.room_type, B2.price_per_night, B1.amount, B3.service_name, B2.booking_flag
FROM payment_table B1
JOIN hotel_guest_booking  B2
ON B1.booking_id = B2.booking_id
JOIN service_usage_info B3
ON B1.booking_id = B3.booking_id
WHERE B2.status <> 'Confirmed' 
ORDER BY  B2.customer_id, B2.check_in asc;


/* Đánh dấu lại các booking_id này vào bảng hotel_guest_booking */
--1.110 Unique ID
UPDATE hotel_guest_booking
SET booking_flag = 'Pending/Cancelled But Paid'
WHERE booking_id in (	SELECT	B1.booking_id
						FROM payment_table B1
						JOIN hotel_guest_booking  B2
						ON B1.booking_id = B2.booking_id
						JOIN service_usage_info B3
						ON B1.booking_id = B3.booking_id
						WHERE B2.status <> 'Confirmed');


/* Thêm 1 cột updated_booking status */
ALTER TABLE hotel_guest_booking
ADD updated_booking_status VARCHAR(50);

UPDATE hotel_guest_booking
SET updated_booking_status = 
	(CASE
		WHEN booking_id IN (SELECT	B1.booking_id
							FROM service_usage_info B1
							JOIN hotel_guest_booking B2
							ON B1.booking_id  = B2.booking_id
							WHERE B2.booking_flag = 'Pending/Cancelled But Paid') then 'Confirmed'
	ELSE  hotel_guest_booking.status END);
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Kiểm tra lại  các trường hợp trong một ngày cùng 1 phòng có 2 hoặc hơn lượng bookings
sau khi tạo cột updated_booking_status */
--48 rows - 24 cases
WITH filter_conf as (
SELECT	
		H1.full_name, 
		H1.booking_id, H1.customer_id, H1.room_id,
		H1.check_in, H1.check_out, 
		H1.room_number, H1.room_type, 
		H1.updated_booking_status, H1.room_status, H1.booking_flag
FROM hotel_guest_booking H1
JOIN
		(select check_in, room_number
		from hotel_guest_booking
		group by check_in, room_number
		having count(room_number) >=2 ) H2
ON H1.check_in = H2.check_in
and H1.room_number = H2.room_number
),
count_conf_each_date as (
SELECT	*,
		COUNT(check_in) OVER (PARTITION BY check_in, room_number) as count_check_in_confirmed --phải thêm dòng room_number tránh tình trạng khác booking có room_number khác bị ảnh hưởng
FROM filter_conf
WHERE updated_booking_status ='Confirmed'
)
SELECT	full_name, booking_id, customer_id, room_id,
		check_in, check_out, 
		room_number, room_type, 
		updated_booking_status, room_status, booking_flag
FROM count_conf_each_date
WHERE count_check_in_confirmed >=2 
ORDER BY check_in asc;


/*Bởi vì đã cập nhật lại cột booking_status mới -> cho nên là sẽ có thể xuất hiện các trường hợp double booking mới 
- Trước tiên mình sẽ update lại trạng thái booking_flag */
UPDATE hotel_guest_booking
SET booking_flag = 'Double Booking'
WHERE booking_id IN (
 105, 1765, 4205, 2504, 840, 1336, 2485, 4899, 3921, 7,
 2062, 4948, 1419, 1453, 3220, 2514, 4598, 601, 1000, 4009,
 1619, 3775, 3246, 4733, 1661, 3197, 882, 1929, 2547, 2772,
 4038, 1985, 4655, 4789, 2376, 4992, 4633, 4328, 3425, 4611,
 236, 4688, 4475, 2340);


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Booking Flag: Double Booking cho các trường hợp có khách hàng sau đến check-in 
khi thời gian cư trú của khách hàng trước vẫn còn */

UPDATE hotel_guest_booking
SET booking_flag = 'Double Booking'
WHere booking_id in (
Select	B1.booking_id
from hotel_guest_booking b1
join hotel_guest_booking b2
on b1.room_number = b2.room_number
and b1.booking_id <> b2.booking_id
and b1.check_in < b2.check_out
and b2.check_in < b1.check_out
and b1.updated_booking_status = 'Confirmed'
and b2.updated_booking_status  = 'Confirmed'
where b1.booking_flag = 'Double Booking' --room_number = ??
);

select *
from hotel_guest_booking
where booking_flag = 'Double Booking'
order by room_number, check_in asc;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Update  Room Status của từng room_number dựa trên check_in và updated_booking_status 
2 trạng thái cho room_status = 'Booked' || 'Available' */
