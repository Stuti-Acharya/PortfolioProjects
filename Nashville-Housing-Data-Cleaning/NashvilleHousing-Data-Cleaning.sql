/*
=========================================================
NASHVILLE HOUSING DATA CLEANING
=========================================================

Purpose:
Clean and standardize the Nashville Housing dataset
for further analysis and visualization.

Cleaning Steps:
1. Inspect raw data
2. Standardize Sale Date
3. Populate missing Property Address
4. Split Property Address into Address and City
5. Split Owner Address into Address, City and State
6. Remove duplicate records
7. Remove unused columns
8. Verify cleaned dataset
=========================================================
*/


/*
=========================================================
1. INSPECT RAW DATA
=========================================================
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


/*
=========================================================
2. STANDARDIZE SALE DATE
=========================================================
*/

-- Check the existing SaleDate format

SELECT
    SaleDate,
    CONVERT(DATE, SaleDate) AS ConvertedSaleDate
FROM PortfolioProject.dbo.NashvilleHousing;


-- Convert SaleDate to DATE format

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);


-- Add a separate cleaned date column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted DATE;


-- Populate the new column

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);


/*
=========================================================
3. POPULATE MISSING PROPERTY ADDRESS
=========================================================
*/

-- Identify records with missing PropertyAddress

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


-- Find matching addresses using ParcelID

SELECT
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS UpdatedAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-- Populate missing PropertyAddress values

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


/*
=========================================================
4. SPLIT PROPERTY ADDRESS
=========================================================
*/

-- Check PropertyAddress

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;


-- Separate PropertyAddress into Address and City

SELECT
    SUBSTRING(
        PropertyAddress,
        1,
        CHARINDEX(',', PropertyAddress) - 1
    ) AS PropertySplitAddress,

    SUBSTRING(
        PropertyAddress,
        CHARINDEX(',', PropertyAddress) + 1,
        LEN(PropertyAddress)
    ) AS PropertySplitCity
FROM PortfolioProject.dbo.NashvilleHousing;


-- Add PropertySplitAddress column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


-- Populate PropertySplitAddress

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress =
    SUBSTRING(
        PropertyAddress,
        1,
        CHARINDEX(',', PropertyAddress) - 1
    );


-- Add PropertySplitCity column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


-- Populate PropertySplitCity

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity =
    SUBSTRING(
        PropertyAddress,
        CHARINDEX(',', PropertyAddress) + 1,
        LEN(PropertyAddress)
    );


/*
=========================================================
5. SPLIT OWNER ADDRESS
=========================================================
*/

-- Check OwnerAddress

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;


-- Separate OwnerAddress into Address, City and State

SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing;


-- Add OwnerSplitAddress column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);


-- Populate OwnerSplitAddress

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


-- Add OwnerSplitCity column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);


-- Populate OwnerSplitCity

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


-- Add OwnerSplitState column

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);


-- Populate OwnerSplitState

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState =
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


/*
=========================================================
6. REMOVE DUPLICATES
=========================================================
*/

WITH RowNumCTE AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY UniqueID
        ) AS RowNum
    FROM PortfolioProject.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE RowNum > 1;


/*
=========================================================
7. REMOVE UNUSED COLUMNS
=========================================================
*/

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,
            TaxDistrict,
            PropertyAddress,
            SaleDate;


/*
=========================================================
8. FINAL DATA VERIFICATION
=========================================================
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


/*
Check for remaining duplicate records
*/

WITH RowNumCTE AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                ParcelID,
                PropertySplitAddress,
                SalePrice,
                SaleDateConverted,
                LegalReference
            ORDER BY UniqueID
        ) AS RowNum
    FROM PortfolioProject.dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE RowNum > 1;


/*
Check for NULL PropertySplitAddress values
*/

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertySplitAddress IS NULL;


/*
=========================================================
END OF DATA CLEANING
=========================================================
*/