/*
Cleaning Data in SQL Queries
*/

SELECT * 
FROM [Analyst Portfolio Project]..[NashvilleHousing]



 --------------------------------------------------------------------------------------------------------------------------

------------------------------------ Populate Property Address data--------------------------------------------------
SELECT * 
FROM [Analyst Portfolio Project]..[NashvilleHousing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.UniqueID, A.ParcelID, A.PropertyAddress, B.UniqueID, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Analyst Portfolio Project]..[NashvilleHousing] A --- OG Table
JOIN [Analyst Portfolio Project]..[NashvilleHousing] B --- Replica/Reference
ON A.ParcelID = B.ParcelID
AND A.UniqueID != B.UniqueID
WHERE A.PropertyAddress IS NULL
--Where PropertyAddress is null

----Update OG Table
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Analyst Portfolio Project]..[NashvilleHousing] A ---
JOIN [Analyst Portfolio Project]..[NashvilleHousing] B ---
ON A.ParcelID = B.ParcelID
AND A.UniqueID != B.UniqueID
WHERE A.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [Analyst Portfolio Project]..[NashvilleHousing]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address 
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Analyst Portfolio Project]..[NashvilleHousing]
--Where PropertyAddress is null
--order by ParcelID

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


------- Owner Address Redress with PARSENAME
SELECT OwnerAddress
FROM [Analyst Portfolio Project]..[NashvilleHousing]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM [Analyst Portfolio Project]..[NashvilleHousing]

---------------------------------
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

--------------------------------
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


SELECT *
FROM [Analyst Portfolio Project]..[NashvilleHousing]
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Analyst Portfolio Project]..[NashvilleHousing]
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 0 THEN 'No'
	   WHEN SoldAsVacant = 1 THEN 'YES'
	   END AS SoldAsVacant2
FROM [Analyst Portfolio Project]..[NashvilleHousing]

ALTER TABLE NashvilleHousing
ALTER COLUMN SoldAsVacant NVARCHAR(255)

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'No'
	   WHEN SoldAsVacant = 1 THEN 'YES'
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *,
ROW_NUMBER()
OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) Row_Num
FROM [Analyst Portfolio Project]..[NashvilleHousing]
ORDER BY ParcelID

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER()
OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) Row_Num
FROM [Analyst Portfolio Project]..[NashvilleHousing]
--ORDER BY ParcelID
)

/* SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
*/

DELETE
FROM RowNumCTE
WHERE Row_Num > 1
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE [Analyst Portfolio Project]..[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
