/* Cleaning Data in SQL Queries */

-- Standardize Date Format
Alter Table NashvilleHousing
add SaleDateUpdated Date;

update NashvilleHousing
set NashvilleHousing.SaleDateUpdated = convert(Date, SaleDate);

select *
from NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
select a.ParcelID, a.propertyaddress, b.parcelID, b.propertyAddress, isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a 
join NashvilleHousing b 
on a.parcelID = b.parcelID and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null

--Updating Property Address
update a 
set propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a 
join NashvilleHousing b 
on a.parcelID = b.parcelID and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null

select * from NashvilleHousing;

----------------------------------------------------------------------------------------------------------
-- Breaking down Property Address into Individual Columns (Address, City, State)
select 
    SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) - 1) as Address,
	SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) + 1, len(propertyaddress)) as City 
from NashvilleHousing

Alter table nashvillehousing
add PropertySplitAddress Nvarchar(255);

Alter table nashvillehousing
add PropertySplitCity Nvarchar(255);

update nashvillehousing
set propertysplitaddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',',propertyaddress) - 1)

update nashvillehousing
set propertysplitcity = SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) + 1, len(propertyaddress))

select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------------
-- Breaking Down Owner Address into Individual Columns (Address, City, State)
select 
    PARSENAME(REPLACE(owneraddress, ',', '.'),3),
	PARSENAME(REPLACE(owneraddress, ',', '.'),2),
	PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
from NashvilleHousing

Alter table nashvillehousing
add OwnerSplitAddress Nvarchar(255);

Alter table nashvillehousing
add OwnerSplitCity Nvarchar(255);

Alter table nashvillehousing
add OwnerSplitState Nvarchar(5);

update nashvillehousing
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'),3)

update nashvillehousing
set OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'),2)

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(owneraddress, ',', '.'),1)

select * from NashvilleHousing

---------------------------------------------------------------------------------------------
-- Changing Y and N to Yes and No in "SoldAsVacant" column
select distinct(soldasvacant)
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = (case when SoldAsVacant = 'N' then 'No'
						 when SoldAsVacant = 'Y' then 'Yes'
						 else SoldAsVacant
						 end)

---------------------------------------------------------------------------------------
-- Remove duplicate rows
with RowNUMCTE as(
select *, ROW_NUMBER() OVER (PARTITION BY parcelid, propertyaddress, saledate, legalreference order by uniqueid) row_num
from NashvilleHousing)

Delete 
from RowNUMCTE
where row_num > 1

--------------------------------------------------------------------------------------
-- Removing unused columns
select * from NashvilleHousing

Alter table nashvillehousing
drop column propertyaddress, saledate, owneraddress, taxdistrict

