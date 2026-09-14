# Employee_retention-workforce-Analysis
HR Analytics project analyzing employee tenure, retention, early exits, and workforce trends using SQL and Power BI
# Employee Tenure, Retention & Workforce Analysis

## Project Overview

This HR Analytics project analyzes employee tenure, workforce exits, and early employee retention to identify where employees are leaving early and which job functions require greater HR attention.

The project focuses on understanding employee exit patterns, identifying high-impact and high-risk job functions, and translating the analysis into actionable HR recommendations.

## Business Objective

The objective of this project is to:

- Analyze employee tenure and workforce exits
- Identify early employee exits, particularly during the first year
- Understand when employees are most likely to leave
- Identify departments and job functions with higher early-exit risk
- Distinguish between high-risk and high-impact employee groups
- Provide actionable recommendations for improving early retention
- ## Tools & Technologies

- **SQL (MySQL)** — Data cleaning, validation, tenure analysis, retention analysis, and workforce trend analysis
- **Power BI** — Interactive dashboard and HR reporting
- **DAX** — HR measures and calculated columns
- **Excel** — Supporting data analysis and calculations
- ****
- ## Analysis Performed

### 1. Data Quality & Preparation
- Identified duplicate employee records
- Validated employee IDs and date fields
- Checked Start Date and Exit Date consistency
- Identified inconsistencies between employee status and exit dates
- Standardized dates and categorical fields

### 2. Employee Tenure Analysis
- Calculated employee tenure using Start Date and Exit Date
- Compared average tenure between active employees and employees with recorded exits
- Analyzed tenure across departments
- Created tenure bands to understand workforce distribution

### 3. Early Retention Analysis
- Identified employees who exited within their first year
- Analyzed early exits by tenure period
- Examined exits during the first 3, 6, 9, and 12 months
- Analyzed early exits by department and job function

### 4. Workforce & Exit Trends
- Analyzed annual hiring trends
- Analyzed annual recorded exit trends
- Examined changes in workforce size over time
- Compared exit volume and recorded exit rates across departments

### 5. HR Action Analysis
- Compared early-exit rate across job functions
- Compared early-exit volume across job functions
- Combined risk and impact using an Impact vs Risk analysis
- Identified job functions requiring targeted HR attention
- ## Key Findings

- The dataset contains **3,000 unique employee records** after duplicate removal.
- There are **1,533 recorded exits**, giving a **51.10% recorded exit rate**.
- Employees with recorded exits had substantially lower average tenure than active employees (**1.41 years vs 3.85 years**).
- **47.23% of recorded exits occurred within the first year** of employment.
- Among first-year exits, **59.11% occurred within the first six months**.
- **37.29% of first-year exits occurred within the first three months**.
- Production accounted for **68.15% of exits occurring within the first three months**.
- Laborer roles represented a major share of early exits by volume, while some smaller job functions showed higher early-exit rates.
- The Impact vs Risk analysis helped distinguish job functions with high exit risk from those with high exit volume.
- Training outcomes did not show a consistent enough relationship with early exits to be treated as a primary driver.
- ## HR Recommendations

Based on the analysis, the following actions could help improve early employee retention:

1. **Strengthen the first 90 days**
   - Introduce structured onboarding and regular 30/60/90-day check-ins.
   - Identify early warning signs before employees leave.

2. **Focus on high-volume roles**
   - Prioritize roles such as Laborer where the number of early exits creates a significant workforce impact.

3. **Investigate high-risk roles**
   - Review job functions with elevated early-exit rates, particularly where both risk and exit volume are meaningful.

4. **Improve role-specific retention**
   - Conduct stay interviews and exit-interview analysis for high-priority roles.
   - Investigate workload, supervision, job expectations, compensation, and career-growth factors.

5. **Monitor new-hire cohorts**
   - Track early exits by hiring year and role to identify changes in retention patterns.

6. **Use HR dashboards for ongoing monitoring**
   - Monitor early-exit rate, exit volume, tenure, and department/job-function trends regularly rather than relying only on annual analysis.
  
## Power BI Dashboard

The project includes an interactive Power BI dashboard with three pages:

### Overview
Provides a high-level view of:
- Total employees
- Recorded exits
- Recorded exit rate
- Average tenure
- Hiring trends
- Employee tenure distribution
- Department-level exit rate and exit volume

### Early Retention
Focuses on:
- Early exits
- Early exit rate
- Early-exit timing
- Early exits by department
- Top job functions by early-exit volume

### HR Action View
Focuses on:
- Early-exit rate by job function
- Early-exit volume by job function
- Impact vs Risk analysis
- Department and job-function filtering

## Project Files

- `SQL/` — SQL analysis and queries
- `PowerBI/` — Power BI dashboard
- `Data/` — Project dataset
## Project Outcome

This project demonstrates how HR data can be transformed into actionable workforce insights using SQL and Power BI.

The analysis identified a strong concentration of employee exits during the early stages of employment, with the first six months representing a particularly important retention period.

The final dashboard helps HR teams move from simply measuring exits to identifying **where the retention problem is greatest and which employee groups should receive priority attention**.

### Key HR Focus

**Early onboarding → First 90 days → High-impact roles → Targeted retention actions**
