/***********************Viewing all columns and rows****************************/
USE PortfolioProject;

SELECT [Company]
      ,[Valuation]
      ,[Date_Joined]
      ,[Industry]
      ,[City]
      ,[Country]
      ,[Continent]
      ,[Year_Founded]
      ,[Funding]
      ,[Select_Investors]
  FROM [PortfolioProject].[dbo].[Unicorn_Companies]

/************************Creating a CTE***************************/

WITH New_Unicorn AS
(
SELECT [Company]
      ,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
      ,[Date_Joined]
      ,[Industry]
      ,[City]
      ,[Country]
      ,[Continent]
      ,[Year_Founded]
      ,REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M','') AS Funding
      ,[Select_Investors]
FROM [dbo].[Unicorn_Companies]
)
SELECT * FROM New_Unicorn  --CTE


/***********************Creating a Procedure****************************/


CREATE PROCEDURE New_Unicorn_Procedure AS
(
SELECT [Company]
      ,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
      ,[Date_Joined]
      ,[Industry]
      ,[City]
      ,[Country]
      ,[Continent]
      ,[Year_Founded]
      ,REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M','') AS Funding
      ,[Select_Investors]
FROM [dbo].[Unicorn_Companies]
)

New_Unicorn_Procedure   --Running the procedure


/***********************Converting Valuation to INT****************************/

SELECT Company, SUM(CAST(Valuation AS Int)) AS Valuation
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M','') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp 
GROUP BY Company
ORDER BY Valuation DESC


/***********************Converting Funding to INT****************************/

SELECT Company, CAST(SUM(Funding) AS int) AS Funding
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp 
GROUP BY Company, Funding
HAVING Funding=0
ORDER BY Funding DESC


SELECT Company, SUM(CAST(Valuation AS Int)) AS Valuation
FROM [dbo].[Unicorn_Companies]
GROUP BY Company, Valuation
HAVING Valuation > 95

SELECT Top 5 Company, City, Year_Founded
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp 
GROUP BY Company, City, Valuation, Year_Founded
HAVING Valuation > 45

--Top 5 industries with highest valuation (bar)
--Continent/Countries with the highest number of Unicorns (Map)
--Funding to Valuation ratio (scatter plot)
--Top 5 valued company in 00's, 2010', 90'
--Most frequent investors among Companies (Drill down to Continent, Country and City) (Pending)
--Top 5/10 companies by valuation (bar)
--Average duration of companies to reach unicorn
--Countries with average  valuation



--Top 5 industries with highest valuation (bar)
SELECT Top 5 Industry, SUM(CAST(Valuation AS Int)) AS Valuation
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp 
GROUP BY Industry
ORDER BY Valuation DESC

--Continent/Countries with the highest number of Unicorns (Map)

SELECT Continent, Country, Count(*) AS #_of_Unicorns
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors]
		,rn=ROW_NUMBER() OVER (PARTITION BY Continent ORDER BY Count(*)) 
		FROM [dbo].[Unicorn_Companies]) As Temp 
WHERE rn=1
GROUP BY Continent, Country
ORDER BY #_of_Unicorns DESC

-- Option 2
SELECT  Continent, 
		Country, 
		City, 
		COUNT(*) AS Total_Number, 
		ROW_NUMBER() OVER (PARTITION BY Continent ORDER BY Continent DESC) Row1
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp
GROUP BY Country, Continent, City
ORDER BY Total_Number DESC



--Funding to Valuation ratio (scatter plot)
SELECT Company, Valuation, Funding, (CAST(Valuation AS float)/NULLIF(CAST(Funding AS float),0)) AS Ratio
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','000000000') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B','000000000'),'M','000000'),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) AS Temp 
ORDER BY Ratio DESC


--Top 5 valued company in founded 00's, 2010', 90'
SELECT TOP 5 Company, Valuation
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) AS Temp 
WHERE Year_Founded BETWEEN 1980 AND 1989
--WHERE Year_Founded BETWEEN 1990 AND 1999
--WHERE Year_Founded BETWEEN 2000 AND 2009 
--WHERE Year_Founded BETWEEN 2010 AND 2019 
ORDER BY Valuation DESC



SELECT *
FROM [dbo].[Unicorn_Companies]
WHERE Country='India'


--Most frequent investors among Companies (Drill down to Continent, Country and City)
SELECT Select_Investors, 
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) AS Temp


New_Unicorn_Procedure

SELECT Top 5 Company, SUM(CAST(Valuation AS Int)) AS Valuation
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp 
GROUP BY Company
ORDER BY Valuation DESC

--Average duration of companies to reach unicorn
SELECT AVG(DATEPART(YEAR, [Date_Joined]) - [Year_Founded]) AS Years_taken
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp
ORDER BY Years_taken


--Countries with average valuation
SELECT Country, AVG(CAST(Valuation AS Int)) AS Average_Valuation
FROM (
		SELECT [Company]
		,REPLACE(REPLACE([Valuation],'$',''),'B','') AS Valuation
		,[Date_Joined]
		,[Industry]
		,[City]
		,[Country]
		,[Continent]
		,[Year_Founded]
		,REPLACE(REPLACE(REPLACE(REPLACE([Funding],'$',''),'B',''),'M',''),'Unknown','0') AS Funding
		,[Select_Investors] 
		FROM [dbo].[Unicorn_Companies]) As Temp
GROUP BY Country
ORDER BY Average_Valuation DESC