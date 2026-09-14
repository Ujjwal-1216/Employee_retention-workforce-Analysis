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
