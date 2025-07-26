# Hotel Booking Analysis - PowerBi Dashboard (02/2023 - 02/2025)
<img width="1166" height="655" alt="image" src="https://github.com/user-attachments/assets/47fba6fb-ab9b-485e-bb49-51eb1141eda2" />

# Introduction
- This project presents PowerBi dashboards developed to analyze **hotel booking trends** and **suggest strategies** throughout insightful data. The dataset used for analyzing a Vietnam Hotel (called Hotel XYZ) a span of two years. Throught this analysis, the goal is to present a overview of booking behaviors, identify trends.
- Target: Hotel Management Team
- Area: VietNam
# Dataset Overview
- There are 6 tables in a dataset providing insights into booking-related variables ( Confirmed, Pending, Cancelled Bookings), the type of deposite made (Bank Transfer, Cash, Credit Card, Crypto, Paypal) and  Check-in&out date. Additionally, other informations about customer: Phone, Email,...
# Data processing
1. Create a general table and Merge Tables by SQL
- "hotel_guest_booking": booking_table + room_table + service_table
- "service_usage_info": service_usage_table + service_table
2. Data Anomaly by SQL
- Identify cases where the same room number has more than 2 bookings on the same day
- Double booking happens when the second guest arrives before the first guest has checked out
3. Dax Calculations
- Employ some several DAX formulas to calculate **key performance indicators** (KPIs):
<details>
  <summary>Click to view examples of DAX formulas</summary>

  <br>

- **Gross Revenue**: The total revenue of room and service

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
booking_revenue + ancillary_revenue</pre>
```

- **Cancelled Booking**: The number of cancelled bookings.

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

- **Revenue Loss**: The loss of potential revenue from customer's cancellation

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
- **Avg. Length of Stay**: The stay duration of customers

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
- **Occupancy Rate**:

```dax
% Occupancy Rate by date = 
VAR total_occupied_rooms = sum('OR_room_type'[occupied_rooms])
VAR total_available_rooms = 200
VAR operation_days = total_available_rooms * DISTINCTCOUNT(OR_room_type[curr_check_in])
RETURN
DIVIDE(total_occupied_rooms,operation_days)

% Occupancy Rate by Room Type = 
VAR total_occupied_rooms = sum('OR_room_type'[occupied_rooms])
VAR total_available_rooms = sum('OR_room_type'[available_rooms])
RETURN
DIVIDE(total_occupied_rooms,total_available_rooms)
```


</details>

# Key Insights

# Recommendations

# Conclusion
