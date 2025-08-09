# Hotel Booking Analysis (02/2023 - 02/2025)
# Introduction
- A hotel in Vietnam (called XYZ) faces business challenges over the past two years, especially about **Occupancy Rate**. By analyzing data, we can provide  **Hotel Mangement Team** with actionable strategies to improve the situation in 2025.
# Dataset Overview
- The dataset contains 6 tables providing insights into booking-related variables (Cofirmed, Pending, Cancelled Bookings), check-in and check-out dates, and customer information such as (Phone, Email). Additionally, it includes **service-related details** (service price, payment type, usage) and **room-related details** (price per night, room type, room number).
# Data processing
Using SQL to detect `Data Anomalies`
  - Identify **booking cases** where the same room number has more than `2 bookings` on the same day => 🚩Flag: Double Booking
  - Detect bookings with **Pending** or **Cancelled** status that still show service usage in the hotel => Update Booking Status
  - Identify cases where the second guest checks in before the first guest has checked out => 🚩Flag: Double Booking

# DAX Calculations & Formulas
Employ some several DAX formulas to calculate **key performance indicators** (KPIs):
<details>
  <summary>Click to view examples of DAX formulas</summary>

  <br>

- **Gross Revenue**:
```dax
Gross Revenue = 
VAR booking_revenue = 
CALCULATE(
    SUMX(booking_table,
    booking_table[price_per_night] * booking_table[stay_duration]))
VAR ancillary_revenue = 
CALCULATE(
    SUMX(detailed_service_usage_table,
    detailed_service_usage_table[price] * detailed_service_usage_table[quantity]))
RETURN 
booking_revenue + ancillary_revenue
```

- **Cancelled Booking**: 

```dax
Cancelled Bookings = 
VAR cancellation = 
CALCULATE(
    COUNTROWS(booking_table),
    FILTER(booking_table,
    booking_table[booking_status] = "Cancelled" &&
    (booking_table[booking_flag] <> "Double Booking" || ISBLANK(booking_table[booking_flag]))))
RETURN
- cancellation
```

- **Revenue Loss**:

```dax
Revenue Loss = 
VAR revenue_loss = 
CALCULATE(
    SUMX(booking_table,
    booking_table[price_per_night] * booking_table[stay_duration]),
    FILTER(booking_table, 
    booking_table[booking_status] = "Cancelled" &&
    (booking_table[booking_flag] <> "Double Booking" ||ISBLANK(booking_table[booking_flag]))
    ))
RETURN
- revenue_loss
```
- **Avg. Length of Stay**: Total Number Of Room Nights / Total Number Of Bookings

```dax
Averge Length of Stay = 
DIVIDE(
    CALCULATE(SUM(booking_table[stay_duration]),
    FILTER(booking_table,
    (ISBLANK(booking_table[booking_flag]) || booking_table[booking_flag] <> "Double Booking") &&
    booking_table[booking_status] = "Confirmed")),
    CALCULATE(COUNTROWS(booking_table),
    FILTER(booking_table,
    booking_table[booking_status] = "Confirmed" &&
    (ISBLANK(booking_table[booking_flag]) || booking_table[booking_flag] <> "Double Booking"))))
```
- **Avg. Daily Rate**: Room Revenues / Room Sold
```dax
Avg Daily Rate (ADR) = DIVIDE(
    CALCULATE(
        SUMX(booking_table,
        booking_table[price_per_night] * booking_table[stay_duration]),
        FILTER(booking_table,
        booking_table[booking_status] = "Confirmed" &&
        (ISBLANK(booking_table[booking_flag]) || booking_table[booking_flag] <> "Double Booking"))),
    CALCULATE(
        SUMX(booking_table,
        booking_table[stay_duration]),
        FILTER(booking_table,
        booking_table[booking_status] = "Confirmed" &&
        (ISBLANK(booking_table[booking_flag]) ||booking_table[booking_flag] <> "Double Booking"))))
```

- **Occupancy Rate**: Rooms Sold / Room Available

```dax
% Occupancy Rate by date = 
  VAR total_occupied_rooms = COUNTROWS('OR Table')
  VAR total_available_rooms = max('OR Table'[available_rooms])
  VAR operation_days = total_available_rooms * DISTINCTCOUNT('OR Table'[curr_check_in])
  RETURN
  DIVIDE(total_occupied_rooms,operation_days)

% Occupancy Rate by Room Type = 
  VAR total_occupied_rooms = COUNTROWS('OR Table')
  VAR available_rooms = MAX('OR Table'[available_room_types])
  VAR operation_days = available_rooms * CALCULATE(DISTINCTCOUNT('OR Table'[curr_check_in]))
  RETURN DIVIDE(total_occupied_rooms, operation_days)

% Occupancy Rate by room_number = 
  VAR total_occupied_rooms = COUNTROWS('OR Table') 
  VAR operation_days = 
    CALCULATE(
        DISTINCTCOUNT('Dim Date'[Date]) * COUNTROWS(VALUES('OR Table'[room_number])))
  RETURN DIVIDE(total_occupied_rooms, operation_days)
```

</details>

# Key Insights 
1. **Bookings**: Customer tends to book a room in the half year later (especially on Summer or Winter). However, these months often have higher cancellation than others
2. **Gross Revenue**: Các tháng 6,7,9,12 có lượng doanh thu ổn định và vượt mức trung bình trong 2 năm. Tháng 5 vừa thấp  về lượt đặt phòng  mà còn cả ở doanh thu. Điều này có thể đến từ việc sắp vào mùa cao điểm, nên Khách Hàng không có xu hướng đặt phòng vào tháng 5.
3. **Occupancy Rate**: 
1. Phòng không bán được → Tận dụng kém tài nguyên
2. ADR cao/thấp không phải vấn đề → Vấn đề là không tận dụng mùa cao điểm
3. Phòng bán không hiệu quả hoặc sai thời điểm
Root Cause: the %Occupancy is low, not because of ADR or Cancelled Bookings, bookings and sold room are low - appropriate selling for room number => miss the increase %OR and revenue in peak seasoa

# Recommendations
- Hotel Management:
  1. 
# Conclusion

<img width="1164" height="655" alt="image" src="https://github.com/user-attachments/assets/02981cc5-6826-4c4f-a3e0-c6f7685a07d5" />

<img width="1162" height="652" alt="image" src="https://github.com/user-attachments/assets/bad975b2-ac10-4cc1-91b2-d515f901309e" />

