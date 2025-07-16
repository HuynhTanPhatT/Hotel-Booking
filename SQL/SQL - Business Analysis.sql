	/* EDA */
SELECT *
FROM dbo.hotel_guest_booking;
SELECT *
FROM service_usage_info;
SELECT *
FROM payment_table;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Pending		417
   Confirmed	4139
   Cancelled	444 */
select updated_booking_status, count(*)
from hotel_guest_booking
group by updated_booking_status;


SELECT	room_type, 
		count(*) as numbers_rooms
FROM room_table
group by room_type;
/*	Deluxe			40
	Executive		44
	Presidential	45
	Standard		30
	Suite			41 
	Total			200  */
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* ADR by Room Type */
WITH ADR as (
SELECT	room_type,
		datediff(day,check_in, check_out) as stay_duration,
		price_per_night, updated_booking_status
FROM hotel_guest_booking
WHERE booking_flag is  null or booking_flag <> 'Double Booking' 
), 
ADR_room as (
SELECT	room_type,
		price_per_night, stay_duration, 
		stay_duration * price_per_night  as booking_revenue
FROM ADR
WHERE updated_booking_status = 'Confirmed' 
)
SELECT	room_type, 
		sum(booking_revenue) as room_revenue, 
		count(*) as sold_rooms,
		sum(booking_revenue) / count(*) as ADR
FROM ADR_room
GROUP BY room_type;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 /* % Occupancy Rate by Date */
/* Check In < Check Out => Check In + 1 Until Check Out - Check In = 1 */
WITH expand_booking_by_date as (
		SELECT	booking_id, room_number,
				check_in, 
				check_in as curr_check_in, --Thời điểm bắt đầu của một BookingID
				check_out,
				DATEDIFF(DAY, check_in,check_out) as stay_duration
		FROM hotel_guest_booking
		WHERE (updated_booking_status = 'Confirmed')
		AND (booking_flag is null or booking_flag <> 'Double Booking')
	UNION ALL
		SELECT	booking_id,room_number,
				check_in,
				DATEADD(DAY,1,curr_check_in) as occupied_check_in_by_bookingID, -- Tăng Ngày + 1 , nếu đáp ứng điều kiện < hơn Check Out hiện tại 1 ngày 
				check_out,
				stay_duration
		FROM expand_booking_by_date 
		WHERE curr_check_in < DATEADD(day,-1,check_out) -- Dừng đến khi Check Out > Check In 1 ngày 
)
SELECT *
FROM expand_booking_by_date
ORDER BY check_in asc;
/*SELECT	curr_check_in,
		COUNT(curr_check_in) as occupied_rooms_by_date,
		(SELECT COUNT(*) FROM room_table) as total_available_rooms,
		(COUNT(curr_check_in) * 100.0 / (SELECT COUNT(*) FROM room_table)) as occupancy_rate
FROM expand_booking_by_date
GROUP BY curr_check_in
ORDER BY curr_check_in asc;*/
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
