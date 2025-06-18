/*
cleaning data in SQL Queries
*/

select *
from PortfolioProject.dbo.NashvilleHousing

--standardize data format
select SaleDateConverted, convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate=CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=CONVERT(Date,SaleDate)

--populate Property Address Data
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID]<>b.[UniqueID]
 where a.PropertyAddress is null

--breaking out address into individual columns(address,city,state)
select propertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(propertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(propertyAddress))

select *
from PortfolioProject.dbo.NashvilleHousing

select ownerAddress
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(replace(ownerAddress,',','.'),3),
PARSENAME(replace(ownerAddress,',','.'),2),
PARSENAME(replace(ownerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(replace(ownerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(replace(ownerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(replace(ownerAddress,',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing

--remove duplicates
with RowNumCTE as (
select *, 
 ROW_NUMBER() over (
 partition by parcelID,
   propertyAddress,
   SalePrice,
   SaleDate,
   LegalReference
   order by 
      UniqueID
        ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num>1

select *
from PortfolioProject.dbo.NashvilleHousing

--delete unused columns
select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column ownerAddress, TaxDistrict,PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate