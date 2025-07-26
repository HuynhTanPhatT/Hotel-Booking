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
<summary> Click to view examples of DAX formulas </summary>
# Key Insights

# Recommendations

# Conclusion
