/* Mục đích : tối ưu doanh thu, giảm tỷ lệ hủy phòng và cải thiện trải nghiệm khách hàng.*/
SELECT *
FROM dbo.hotel_guest_booking;
SELECT *
FROM service_usage_info;
SELECT *
FROM payment_table;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
select updated_booking_status, count(*)
from hotel_guest_booking
group by updated_booking_status;
/* Pending		1124
   Confirmed	2740
   Cancelled	1134 */

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
/* 1. Phòng nào có tỷ lệ lấp đầy thấp nhất */
WITH occupancy_rate_by_room as (
SELECT	room_number,
		check_in, check_out,
		updated_booking_status,
		(CASE
			WHEN updated_booking_status = 'Confirmed' then 1
			ELSE 0 end) as occupied_rooms
FROM hotel_guest_booking
WHERE booking_flag is null or booking_flag <> 'Double Booking'
),
operation_days as (
select	room_number,
		count(distinct(check_in)) as operation_days
from occupancy_rate_by_room
group by room_number
), 
room_availabel as (
SELECT	room_number, 
		count(*) as num_rooms
FROM room_table
GROUP BY room_number
),
summarize_room_number as(
SELECT	ORB.room_number,
		OD.operation_days, 
		sum(occupied_rooms) as total_occupied_rooms
FROM occupancy_rate_by_room ORB
JOIN operation_days OD
ON ORB.room_number = OD.room_number
GROUP BY ORB.room_number, OD.operation_days
)
SELECT	SRN.room_number, SRN.operation_days, SRN.total_occupied_rooms,
		RA.num_rooms, 
		round((SRN.total_occupied_rooms * 100.0 / (RA.num_rooms * SRN.operation_days)),2) as occupancy_rate
FROM summarize_room_number SRN
JOIN room_availabel RA
ON SRN.room_number = RA.room_number
ORDER BY  occupancy_rate asc;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* 1.1: Tỷ lệ lấp đầy theo tuần  của Khách sạn XYZ */
With day_of_the_Week as (
select	DATENAME(weekday, check_in) as day_name,
		(CASE
			WHEN DATENAME(weekday, check_in) = 'Monday' then 1
			WHEN DATENAME(weekday, check_in) = 'Tuesday' then 2
			WHEN DATENAME(weekday, check_in) = 'Wednesday' then 3
			WHEN DATENAME(weekday, check_in) = 'Thursday' then 4
			WHEN DATENAME(weekday, check_in) = 'Friday' then 5
			WHEN DATENAME(weekday, check_in) = 'Saturday' then 6
			WHEN DATENAME(weekday, check_in) = 'Sunday' then 7
		END) as day_number,
		check_in, check_out,
		updated_booking_status,
		(CASE
			WHEN updated_booking_status = 'Confirmed' then 1
			ELSE 0 end) as occupied_rooms

from hotel_guest_booking
where booking_flag is null or booking_flag <> 'Double Booking'
)
select *
from day_of_the_Week;

/* 1.2: Tỷ lệ lấp đầy theo mùa  của Khách sạn XYZ */
With occupancy_rate_by_season as (
SELECT	check_in, check_out,
		(CASE
			WHEN month(check_in) in (11,12) and year(check_in) = 2023  then CONCAT('winter',year(check_in))
			WHEN month(check_in) in (11,12) and year(check_in) > 2023 then CONCAT('winter',year(check_in))
			WHEN month(check_in) in (1,2) and year(check_in) = 2023 then CONCAT('winter',year(check_in))
			WHEN month(check_in) in (1,2) and year(check_in) > 2023 then CONCAT('winter',year(check_in) -1)
			WHEN month(check_in) in (3,4,5) then concat('spring', year(check_in))
			WHEN month(check_in) in (6,7,8) then  concat('summer',year(check_in))
		 ELSE concat('autumn', year(check_in)) End) as season,
		 updated_booking_status,
		(CASE
			WHEN updated_booking_status = 'Confirmed' then DATEDIFF(day, check_in, check_out)
			ELSE NULL END) as occupied_nights
from hotel_guest_booking
where booking_flag is null or booking_flag <> 'Double Booking'
--order by year(check_in), MONTH(check_in) asc
),
seasonal_operation_days as (
select	season,
		count(distinct(check_in)) as operation_days,
		sum(occupied_nights) as total_occupied_night_rooms ,
		cast(right(season,4) as INT) as season_year,
		(CASE
			WHEN left(season, len(season)  -4) = 'spring' then 1
			WHEN left(season, len(season) -4) = 'summer' then 2
			WHEN left(season, len(season) -4) = 'autumn' then 3
			WHEN left(season, len(season) -4) = 'winter' then 4 END) as season_sort
from occupancy_rate_by_season
group by season 
),
room_available as (
select count(*) as num_rows
from room_table
)
select	season,
		operation_days, total_occupied_night_rooms,
		num_rows * operation_days as room_available,
		round(total_occupied_night_rooms * 100.0 / (r.num_rows * operation_days),2) as occupancy_rate_by_season
from seasonal_operation_days s
cross join room_available r
order by s.season_year, s.season_sort asc;




/* 1.3: Tỷ lệ lấp đầy theo năm của Khách sạn XYZ: *theo số ngày của tổng tháng của từng mùa */
With occupancy_rate_by_year as (
select	check_in, check_out,
		format(check_in,'yyyy-MM') as year_month, 
		updated_booking_status,
		(CASE 
			WHEN updated_booking_status  = 'Confirmed' then DATEDIFF(day, check_in, check_out)
		  ELSE 0 END) as occupied_nights_rooms
from hotel_guest_booking
where booking_flag is null or booking_flag <> 'Double Booking'
),
summarize_info as (
select	year_month,
		count(distinct(check_in)) as operation_days,
		sum(occupied_nights_rooms) as total_occupied_night_rooms
from occupancy_rate_by_year
group by year_month
),
room_available as (
select count(*) as room_available
from room_table
)
select *, 
		round(total_occupied_night_rooms * 100.0 / (room_available * operation_days),2) as occupancy_rate
from summarize_info
cross join room_available
order by year_month asc;


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* 2: Những dịch vụ nào được sử dụng nhiều nhất */
select	service_name,
		sum(total_price) as revenues,
		count(*) as number_of_service_sales
from service_usage_info
group by service_name




