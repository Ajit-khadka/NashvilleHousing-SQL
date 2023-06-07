/*
Cleaning Data
*/

SELECT * 
FROM PortfolioProject..NashVilleHousing

--Date format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashVilleHousing

Update PortfolioProject..NashVilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE PortfolioProject..NashVilleHousing
ADD FilteredSaleDate Date;

Update PortfolioProject..NashVilleHousing
SET FilteredSaleDate = CONVERT(Date,SaleDate)

SELECT FilteredSaleDate 
FROM PortfolioProject..NashVilleHousing

--Populating PropertyAddress

SELECT * 
FROM PortfolioProject..NashVilleHousing
--Where PropertyAddress IS NULL
ORDER BY ParcelID

SELECT PropertyAddress
FROM PortfolioProject..NashVilleHousing
Where PropertyAddress IS NULL

--Checking dublicates

--SELECT ParcelID, COUNT(*) AS Count
--FROM PortfolioProject..NashVilleHousing
--GROUP BY ParcelID
--HAVING COUNT(*) > 1

--If parcelID are found same containing one null PropertyAddress it is updated with another parcel id's PropertyAddress

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashVilleHousing AS A
JOIN PortfolioProject..NashVilleHousing AS B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET A.PropertyAddress =  ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM  PortfolioProject..NashVilleHousing AS A
JOIN PortfolioProject..NashVilleHousing AS B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

-- Spliting PropertyAddress into Address, City name and State

SELECT PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashVilleHousing

--ALTER TABLE PortfolioProject..NashVilleHousing
--ADD PropertySplitAddress varchar(255)

ALTER TABLE PortfolioProject..NashVilleHousing
ADD PropertySplitAddress varchar(255),
    City varchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ),
    City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

-- Spliting OwnerAddress

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS OwnerState
FROM PortfolioProject..NashVilleHousing

ALTER TABLE PortfolioProject..NashVilleHousing
ADD OwnerSplitAddress varchar(255),
    OwnerCity varchar(255),
	OwnerState varchar(255);

UPDATE PortfolioProject..NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) ,
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);
	
-- SoldAsVacant -> Converting Y to Yes and N to NO

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS Count
FROM PortfolioProject..NashVilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SElECT SoldAsVacant,
  CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END 
FROM PortfolioProject..NashVilleHousing    

UPDATE PortfolioProject..NashVilleHousing 
SET SoldAsVacant = CASE 
	 WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END 

--Removing Duplicates

WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference 
ORDER BY UniqueID) AS row_num
FROM PortfolioProject..NashVilleHousing 
--ORDER BY ParcelID
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Deleting unused columns

ALTER TABLE PortfolioProject..NashVilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

SELECT * 
FROM PortfolioProject..NashVilleHousing


