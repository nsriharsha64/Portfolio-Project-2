--Cleaning The Data In Sql Queries

Select *
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$

Update Nashville_housing_data_2013_201$
SET SaleDate = CONVERT(Date, SaleDate)

Alter Table Nashville_housing_data_2013_201$
Add SaleDateConverted Date;

Update Nashville_housing_data_2013_201$
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

Select *
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$
--where PropertyAddress is null
order by Parcel_ID


Select a.Parcel_ID, a.PropertyAddress, b.Parcel_ID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$ a
Join [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$ b
on a.Parcel_ID = b.Parcel_ID
and a.Unique_ID <> b.Unique_ID
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$ a
Join [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$ b
on a.Parcel_ID = b.Parcel_ID
and a.Unique_ID <> b.Unique_ID
where a.PropertyAddress is null

--Breaking out Address into individual columns(Address, State, City)

Select PropertyAddress
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$
--where PropertyAddress is null
--order by Parcel_ID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress)) as Address
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$

Alter Table Nashville_housing_data_2013_201$
Add PropertySplitAddress nvarchar(255);

Update Nashville_housing_data_2013_201$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table Nashville_housing_data_2013_201$
Add PropertySplitCity nvarchar(255);

Update Nashville_housing_data_2013_201$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,LEN(PropertyAddress))

Select *
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$

Select Address
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$


Select
PARSENAME(REPLACE(Address, ',', '.'), 3)
,PARSENAME(REPLACE(Address, ',', '.'), 2)
,PARSENAME(REPLACE(Address, ',', '.'), 1)
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$

Alter Table Nashville_housing_data_2013_201$
Add OwnerSplitAddress nvarchar(255);

Update Nashville_housing_data_2013_201$
SET OwnerSplitAddress = PARSENAME(REPLACE(Address, ',', '.'), 3)

Alter Table Nashville_housing_data_2013_201$
Add OwnerSplitCity nvarchar(255);

Update Nashville_housing_data_2013_201$
SET OwnerSplitCity = PARSENAME(REPLACE(Address, ',', '.'), 2)

Alter Table Nashville_housing_data_2013_201$
Add OwnerSplitState nvarchar(255);

Update Nashville_housing_data_2013_201$
SET OwnerSplitState = PARSENAME(REPLACE(Address, ',', '.'), 1)


Select *
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$


--Change Y and N to Yes and No in 'Sold as vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$

Update Nashville_housing_data_2013_201$
SET SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End 


--Remove Duplicates

With RowNumCTE as(
Select *,
ROW_NUMBER() Over(
Partition by Parcel_ID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 Legal_Reference
			 Order By
					Unique_ID
			) row_num
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



--Removing Unused Columns

Select *
From [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$


Alter Table [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$
Drop Column PropertyAddress, Address, TaxDistrict

Alter Table [Portfolio Project (1)].dbo.Nashville_housing_data_2013_201$
Drop Column SaleDate