# Hotel Booking Analysis - PowerBi Dashboard (02/2023 - 02/2025)

# Introduction
- A hotel in Vietnam (called XYZ) faces business challenges over the past two years, especially about **Occupancy Rate**. By analyzing data, we can provide  **Hotel Mangement Team** with actionable strategies to improve the situation in 2025.
# Dataset Overview
- There are 6 tables in a dataset providing insights into booking-related variables ( Confirmed, Pending, Cancelled Bookings), the type of deposite made (Bank Transfer, Cash, Credit Card, Crypto, Paypal) and  Check-in&out date. Additionally, other informations about customer: Phone, Email,...
# Data processing
1. Create general tables and merge them
  - "hotel_guest_booking": booking_table + room_table + service_table
  - "service_usage_info": service_usage_table + service_table
2. Data Anomaly
  - Identify cases where the same room number has more than 2 bookings on the same day
  - Double booking happens when the second guest arrives before the first guest has checked out
3. Dax Calculations
  - Employ some several DAX formulas to calculate **key performance indicators** (KPIs):
<details>
  <summary>Click to view examples of DAX formulas</summary>

  <br>

- **Gross Revenue**:  Room Revenue + Service Revenue

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

- **Revenue Loss**: The loss of potential booking revenue from customer cancellations

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

- **Occupancy Rate**:  Number of Occupied Rooms / Total Number of Available Rooms

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
VAR total_occupied_rooms = DISTINCTCOUNTNOBLANK('OR Table'[curr_check_in])
VAR operation_days = datediff(MIN('Booking Table'[check_in]), max('Booking Table'[check_out]),DAY) 
RETURN DIVIDE(total_occupied_rooms, operation_days)

```

</details>

# Key Insights

# Recommendations

# Conclusion
