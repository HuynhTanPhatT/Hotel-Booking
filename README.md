# Hotel Booking Analysis - PowerBi Dashboard (02/2023 - 02/2025)
<img width="1166" height="655" alt="image" src="https://github.com/user-attachments/assets/47fba6fb-ab9b-485e-bb49-51eb1141eda2" />

# Introduction
- This project presents PowerBi dashboards developed to analyze **hotel booking trends** and **suggest strategies** throughout insightful data. The dataset used for analyzing a Vietnam Hotel (called Hotel XYZ) a span of two years. Throught this analysis, the goal is to present a overview of booking behaviors, identify trends.
- Target: Hotel Management Team
- Area: VietNam
# Dataset Overview
- There are 6 dataset providing insights into several booking-related variables, such as booking status (cancelled, pending bookings, confirmed bookings) , room status (booked, available) , room & service prices ,etc. Other data includes information about customer information, check in and check out, also  the type of deposite made,...
# Data processing
Data Anomoly by SQL:
1. Identify cases where the same room number has more than 2 bookings on the same day
2. double booking happens when the second guest arrives before the first guest has checked out
