-- create/drop table
--CREATE TABLE DF_TBC_SPEND_FINAL AS
SELECT 
    ASSETID,
    FISCAL_YEAR,
    FISCAL_MONTH,
    FILE_NAME,
    SUPPLIER_ERP,
    SUPPLIER_NORMALIZED,
    SOURCE_DATA,
    SOURCE_SYSTEM,
    TOTAL_SPEND_USD
FROM TBC_SPEND_FINAL
WHERE FISCAL_YEAR = 'FY_2023';

DROP TABLE DF_TBC_SPEND_FINAL;

-- 1.1. Create the server-side table structure
CREATE TABLE DF_TBC_UPDATE_TABLE

(
    ASSETID VARCHAR2(4000 BYTE),
    FILE_NAME VARCHAR2(4000 BYTE),	
    SUPPLIER_ERP VARCHAR2(4000 BYTE),
    SUPPLIER_NORMALIZED VARCHAR2(4000 BYTE),
    SOURCE_DATA VARCHAR2 (4000 BYTE),
    SOURCE_SYSTEM VARCHAR2 (4000 BYTE),
    TOTAL_SPEND_USD NUMBER(38,2)
);
-- 3. drop the update table
DROP TABLE DF_TBC_UPDATE_TABLE;

-- row_count  and distinct count 
SELECT
    FISCAL_YEAR,
    SOURCE_DATA,
    COUNT(SOURCE_DATA) AS ROW_COUNT,
    COUNT(DISTINCT SUPPLIER_NORMALIZED) AS DISTINCT_NORMALIZED
FROM DF_TBC_SPEND_FINAL
GROUP BY 
    FISCAL_YEAR,
    SOURCE_DATA
;

SELECT
    SOURCE_DATA,
    COUNT(SOURCE_DATA) AS ROW_COUNT,
    COUNT(DISTINCT SUPPLIER_NORMALIZED) AS DISTINCT_NORMALIZED
FROM DF_TBC_UPDATE_TABLE
GROUP BY 
    SOURCE_DATA
;

-- data 
SELECT
    ASSETID,
    FILE_NAME,
    SUPPLIER_ERP,
    SUPPLIER_NORMALIZED,
    SUM(TOTAL_SPEND_USD) AS TOTAL_SPEND_USD,
    COUNT(ASSETID) AS ROW_COUNT
FROM DF_TBC_SPEND_FINAL
WHERE FISCAL_YEAR = 'FY_2023' AND SOURCE_DATA = 'Concur'
GROUP BY 
    ASSETID,
    FILE_NAME,
    SUPPLIER_ERP,
    SUPPLIER_NORMALIZED
ORDER BY TOTAL_SPEND_USD DESC;

-- count the distinct supplier normalized and return how many represent the top 50% of total spend
WITH TotalSpend AS (
    SELECT 
        SUM(TOTAL_SPEND_USD) AS TOTAL_SPEND
    FROM 
        TBC_SPEND_FINAL
    WHERE 
        SOURCE_DATA = 'Concur' 
        AND FISCAL_YEAR = 'FY_2023'
), SupplierSpend AS (
    SELECT 
        SUPPLIER_NORMALIZED,
        SUM(TOTAL_SPEND_USD) AS SUPPLIER_SPEND
    FROM 
        TBC_SPEND_FINAL
    WHERE 
        SOURCE_DATA = 'Concur' 
        AND FISCAL_YEAR = 'FY_2023'
    GROUP BY 
        SUPPLIER_NORMALIZED
), CumulativeSpend AS (
    SELECT 
        SUPPLIER_NORMALIZED,
        SUPPLIER_SPEND,
        SUM(SUPPLIER_SPEND) OVER (ORDER BY SUPPLIER_SPEND DESC) AS CUMULATIVE_SPEND
    FROM 
        SupplierSpend
)
SELECT 
    (SELECT COUNT(DISTINCT SUPPLIER_NORMALIZED) FROM SupplierSpend) AS DISTINCT_NORMALIZED,
    (SELECT COUNT(DISTINCT SUPPLIER_NORMALIZED) FROM CumulativeSpend, TotalSpend WHERE CUMULATIVE_SPEND <= (TotalSpend.TOTAL_SPEND / 2)) AS TOP_50_PERCENT_SUPPLIERS
FROM 
    DUAL;

--test the merge statement

MERGE INTO DF_TBC_SPEND_FINAL FINAL
USING (
    SELECT 
        ASSETID, FILE_NAME, SUPPLIER_ERP, SUPPLIER_NORMALIZED 
    FROM 
        DF_TBC_UPDATE_TABLE
) SIDE
ON (FINAL.ASSETID = SIDE.ASSETID AND
    FINAL.FILE_NAME = SIDE.FILE_NAME AND
    FINAL.SUPPLIER_ERP = SIDE.SUPPLIER_ERP)
WHEN MATCHED THEN
    UPDATE SET FINAL.SUPPLIER_NORMALIZED = SIDE.SUPPLIER_NORMALIZED;
    
    
    

-- confirm the shared values among the final spend table and update table
SELECT
    COUNT(*),
    SUM(SOURCE.TOTAL_SPEND_USD)
FROM DF_TBC_SPEND_FINAL SOURCE
INNER JOIN DF_TBC_UPDATE_TABLE SIDE 
ON (
    SOURCE.ASSETID = SIDE.ASSETID AND
    SOURCE.FILE_NAME = SIDE.FILE_NAME AND
    SOURCE.SUPPLIER_ERP = SIDE.SUPPLIER_ERP)
;




