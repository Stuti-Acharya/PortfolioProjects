# Nashville Housing Data Cleaning

## Overview

This is a simple SQL data cleaning project using the Nashville Housing dataset.

The purpose of this project was to practice cleaning and transforming raw data using SQL Server and prepare the dataset for further analysis.

## Tools Used

- SQL Server
- T-SQL

## Data Cleaning Tasks

The following data cleaning tasks were performed:

### 1. Standardized Sale Date

Converted the `SaleDate` column into a standard `DATE` format and created a cleaned date column.

### 2. Populated Missing Property Addresses

Used `ParcelID` to identify matching records and populate missing `PropertyAddress` values.

### 3. Split Property Address

Separated the `PropertyAddress` column into:

- Property Address
- Property City

### 4. Split Owner Address

Separated the `OwnerAddress` column into:

- Owner Address
- Owner City
- Owner State

### 5. Removed Duplicate Records

Used `ROW_NUMBER()` and a Common Table Expression (CTE) to identify and remove duplicate records.

### 6. Removed Unused Columns

Removed columns that were no longer needed after the cleaning process.

## SQL Concepts Used

- SELECT
- UPDATE
- ALTER TABLE
- DROP COLUMN
- JOIN
- Self JOIN
- CTEs
- ROW_NUMBER()
- CONVERT()
- ISNULL()
- SUBSTRING()
- CHARINDEX()
- LEN()
- REPLACE()
- PARSENAME()

## Project File

`NashvilleHousing-Data-Cleaning.sql`

## Purpose

This project was created to practice fundamental SQL data cleaning techniques and gain hands-on experience working with a real-world dataset.
