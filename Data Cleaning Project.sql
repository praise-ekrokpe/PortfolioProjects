--Standardize date format
SELECT SaleDate, CONVERT(DATE, SaleDate) 
FROM PortfolioProject..nashville_housing

--Create and update column
ALTER TABLE PortfolioProject..nashville_housing
ADD SaleDateConverted DATE

UPDATE PortfolioProject..nashville_housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--Populate property address
SELECT *
FROM PortfolioProject..nashville_housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..nashville_housing a
JOIN PortfolioProject..nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out property address into seperate columns
SELECT PropertyAddress
FROM PortfolioProject..nashville_housing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS address
FROM PortfolioProject..nashville_housing

ALTER TABLE PortfolioProject..nashville_housing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..nashville_housing
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Breaking out property address into seperate columns

SELECT OwnerAddress
FROM PortfolioProject..nashville_housing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..nashville_housing

ALTER TABLE PortfolioProject..nashville_housing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject..nashville_housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject..nashville_housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Changing Y and N to Yes and No in the SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = 
CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject..nashville_housing

--Delete duplicate columns

WITH RowNumber_CTE AS
(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY
		ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference
	ORDER BY UniqueID ) AS RowNumber
FROM PortfolioProject..nashville_housing
)

DELETE
FROM RowNumber_CTE
WHERE RowNumber > 1

--Delete unused columns
SELECT *
FROM PortfolioProject..nashville_housing

ALTER TABLE PortfolioProject..nashville_housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict