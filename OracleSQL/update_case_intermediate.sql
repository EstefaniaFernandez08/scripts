--  execute the update script
UPDATE TBC_SPEND_FINAL
SET
-- update
INVOICE_PMT_TERMS_CDE = CASE 
    WHEN INVOICE_PMT_TERMS_CDE  = '8' THEN    '0008'
    WHEN INVOICE_PMT_TERMS_CDE  = '1' THEN    '0001'
    WHEN INVOICE_PMT_TERMS_CDE  = '9' THEN    '0009'
    WHEN INVOICE_PMT_TERMS_CDE  = '118' THEN  '0118'
    WHEN INVOICE_PMT_TERMS_CDE  = '6' THEN    '0006'
    WHEN INVOICE_PMT_TERMS_CDE  = '3' THEN    '0003'
    WHEN INVOICE_PMT_TERMS_CDE  = '4' THEN    '0004'
    WHEN INVOICE_PMT_TERMS_CDE  = '10' THEN   '0010'
    WHEN INVOICE_PMT_TERMS_CDE  = '117' THEN  '0117'
    WHEN INVOICE_PMT_TERMS_CDE  = '5' THEN    '0005'
    WHEN INVOICE_PMT_TERMS_CDE  = '107' THEN  '0107'
    WHEN INVOICE_PMT_TERMS_CDE  = '7' THEN    '0007'
    WHEN INVOICE_PMT_TERMS_CDE  = '12' THEN   '0012'
    WHEN INVOICE_PMT_TERMS_CDE  = '119' THEN  '0119'
    WHEN INVOICE_PMT_TERMS_CDE  = '22' THEN   '0022'
    WHEN INVOICE_PMT_TERMS_CDE  = '116' THEN  '0116'
    WHEN INVOICE_PMT_TERMS_CDE  = '19' THEN   '0019'
    WHEN INVOICE_PMT_TERMS_CDE  = '20' THEN   '0020'
    ELSE INVOICE_PMT_TERMS_CDE
END
-- select only the specified rows
WHERE INVOICE_PMT_TERMS_CDE IN ( 
    '8','1','9','118','6','3','4','10','117','5',
    '107','7','12','119','22','116','19','20')
    ;