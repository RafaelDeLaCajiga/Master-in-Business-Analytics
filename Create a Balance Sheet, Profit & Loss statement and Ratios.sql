USE H_Accounting;
DROP PROCEDURE IF EXISTS Team18_bs2;
/* 
A2: Case H_Accounting
Authors: 
- Martina Aranda
- Rafael Cajiga
- Jenny Hultin
Begin Date: 12/02/2022
End Date: 12/04/2022
*/

-- Here is the Balance Sheet, the Profit & Losses, and the Ratios

DELIMITER $$
CREATE PROCEDURE Team18_bs2(varYear SMALLINT) 
BEGIN
-- Declare and define values for Balance Sheet
-- Used 'Previous' for previous year
DECLARE varCurrentAssets 				DOUBLE DEFAULT 0;
DECLARE varCurrentAssetsPrevious		DOUBLE DEFAULT 0; 
DECLARE varFixedAssets					DOUBLE DEFAULT 0;
DECLARE varFixedAssetsPrevious			DOUBLE DEFAULT 0;
DECLARE varDeferredAssets				DOUBLE DEFAULT 0;
DECLARE varDeferredAssetsPrevious		DOUBLE DEFAULT 0;
DECLARE varCurrentLiabilities			DOUBLE DEFAULT 0;
DECLARE varCurrentLiabilitiesPrevious	DOUBLE DEFAULT 0;
DECLARE varLongTermLiabilities			DOUBLE DEFAULT 0;
DECLARE varLongTermLiabilitiesPrevious	DOUBLE DEFAULT 0;
DECLARE varDeferredLiabilities			DOUBLE DEFAULT 0;
DECLARE varDeferredLiabilitiesPrevious	DOUBLE DEFAULT 0;
DECLARE varEquity						DOUBLE DEFAULT 0;
DECLARE varEquityPrevious				DOUBLE DEFAULT 0;
DECLARE varTotalAssets					DOUBLE DEFAULT 0;
DECLARE varTotalAssetsPrevious			DOUBLE DEFAULT 0;
DECLARE varTotalLiabilitiesAndEquity	DOUBLE DEFAULT 0;
DECLARE varTotalLiabilitiesAndEquityPrevious	DOUBLE DEFAULT 0;

-- Declare and define values for Profit and Losses 
-- Used 'Previous' for previous year
DECLARE varRevenue							DOUBLE DEFAULT 0;
DECLARE varRevenuePrevious					DOUBLE DEFAULT 0;
DECLARE varReturnsRefundsDiscounts			DOUBLE DEFAULT 0;
DECLARE varReturnsRefundsDiscountsPrevious	DOUBLE DEFAULT 0;
DECLARE varCOGS								DOUBLE DEFAULT 0;
DECLARE varCOGSPrevious						DOUBLE DEFAULT 0;
DECLARE varAdminExpenses					DOUBLE DEFAULT 0;
DECLARE varAdminExpensesPrevious			DOUBLE DEFAULT 0;
DECLARE varSellingExpenses					DOUBLE DEFAULT 0;
DECLARE varSellingExpensesPrevious			DOUBLE DEFAULT 0;
DECLARE varOtherExpenses					DOUBLE DEFAULT 0;
DECLARE varOtherExpensesPrevious			DOUBLE DEFAULT 0;
DECLARE varOtherIncome						DOUBLE DEFAULT 0;
DECLARE varOtherIncomePrevious				DOUBLE DEFAULT 0;
DECLARE varIncomeTax						DOUBLE DEFAULT 0;
DECLARE varIncomeTaxPrevious				DOUBLE DEFAULT 0;
DECLARE varOtherTax							DOUBLE DEFAULT 0;
DECLARE varOtherTaxPrevious					DOUBLE DEFAULT 0;
DECLARE varProfitLoss						DOUBLE DEFAULT 0;
DECLARE varProfitLossPrevious				DOUBLE DEFAULT 0;



-- Current Assets: Current Year, Used INFULL and ROUND
SELECT IFNULL(ROUND(SUM(jeli.debit)-SUM(jeli.credit),2),0)
INTO varCurrentAssets
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'CA'
AND YEAR(je.entry_date)= varYear
;

-- Current Assets: Previous Year, Decided to not include the INFULL for the Previous
SELECT ROUND(SUM(jeli.debit)-SUM(jeli.credit),2)
INTO varCurrentAssetsPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'CA'
AND YEAR(je.entry_date)= varYear-1
;

-- Fixed Assets: Current Year
SELECT IFNULL(ROUND(SUM(jeli.debit)-SUM(jeli.credit),2),0)
INTO varFixedAssets
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0 
AND je.debit_credit_balanced = 1
AND statement_section_code = 'FA'
AND YEAR(je.entry_date)= varYear
;

-- Fixed Assets: Previous Year
SELECT ROUND(SUM(jeli.debit)-SUM(jeli.credit),2)
INTO varFixedAssetsPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0 
AND je.debit_credit_balanced = 1
AND statement_section_code = 'FA'
AND YEAR(je.entry_date)= varYear-1
;

-- Deferred Assets: Current Year
SELECT IFNULL(ROUND(SUM(jeli.debit)-SUM(jeli.credit),2),0)
INTO varDeferredAssets
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0 
AND je.debit_credit_balanced = 1
AND statement_section_code = 'DA'
AND YEAR(je.entry_date)= varYear
;

-- Deferred Assets: Previous Year
SELECT ROUND(SUM(jeli.debit)-SUM(jeli.credit),2)
INTO varDeferredAssetsPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0 
AND je.debit_credit_balanced = 1
AND statement_section_code = 'DA'
AND YEAR(je.entry_date)= varYear-1
;

-- Current Liabilities Current Year
SELECT IFNULL(ROUND(SUM(jeli.credit)-SUM(jeli.debit),2),0)
INTO varCurrentLiabilities
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'CL'
AND YEAR(je.entry_date)= varYear
;

-- Current Liabilities Previous Year
SELECT ROUND(SUM(jeli.credit)-SUM(jeli.debit),2)
INTO varCurrentLiabilitiesPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'CL'
AND YEAR(je.entry_date)= varYear-1
;    

-- Long- Term Liabilities Current Year
SELECT IFNULL(ROUND(SUM(jeli.credit)-SUM(jeli.debit),2),0)
INTO varLongTermLiabilities
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'LLL'
AND YEAR(je.entry_date)= varYear
;

-- Long- Term Liabilities Previous Year 
SELECT ROUND(SUM(jeli.credit)-SUM(jeli.debit),2)
INTO varLongTermLiabilitiesPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'LLL'
AND YEAR(je.entry_date)= varYear-1
;

-- Defered Liabilities Current Year
SELECT IFNULL(ROUND(SUM(jeli.credit)-SUM(jeli.debit),2),0)
INTO varDeferredLiabilities
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'DL'
AND YEAR(je.entry_date)= varYear
;
        
-- Defered Liabilities Previous Year 
SELECT ROUND(SUM(jeli.credit)-SUM(jeli.debit),2)
INTO varDeferredLiabilitiesPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'DL'
AND YEAR(je.entry_date)= varYear -1
;

-- Equity Current Year
SELECT IFNULL(ROUND(SUM(jeli.credit)-SUM(jeli.debit),2),0)
INTO varEquity
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'EQ'
AND YEAR(je.entry_date)= varYear
;

-- Equity Previous Year
SELECT ROUND(SUM(jeli.credit)-SUM(jeli.debit),2)
INTO varEquityPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code = 'EQ'
AND YEAR(je.entry_date)= varYear-1
;

-- Total Assets: Current Year
SELECT IFNULL(ROUND(SUM(jeli.debit)-SUM(jeli.credit),2),0)
INTO varTotalAssets
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code IN ('CA', 'FA', 'DA')
AND YEAR(je.entry_date)= varYear
;

-- Total Assets: Previous Year
SELECT ROUND(SUM(jeli.debit)-SUM(jeli.credit),2)
INTO varTotalAssetsPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code IN ('CA', 'FA', 'DA')
AND YEAR(je.entry_date)= varYear-1
;

-- Total Liabilities & Equity: Current Year
SELECT IFNULL(ROUND(SUM(jeli.credit)-SUM(jeli.debit),2),0)
INTO varTotalLiabilitiesAndEquity
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code IN ('EQ', 'CL', 'LLL', 'DL')
AND YEAR(je.entry_date)= varYear
;

-- Total Liabilities & Equity: Previous Year
SELECT ROUND(SUM(jeli.credit)-SUM(jeli.debit),2)
INTO varTotalLiabilitiesAndEquityPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.balance_sheet_section_id
WHERE balance_sheet_section_id <> 0
AND je.debit_credit_balanced = 1
AND statement_section_code IN ('EQ', 'CL', 'LLL', 'DL')
AND YEAR(je.entry_date)= varYear-1
;
-- Calculate the sales for the current year and store it into the created variable
SELECT
SUM(jeli.credit) INTO varRevenue
FROM journal_entry_line_item AS jeli 
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = 'REV'
;

-- Revenue of previous year
SELECT SUM(jeli.credit)
INTO varRevenuePrevious 
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear - 1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = 'REV'
;

-- Calculate the cost of returns, refunds and discounts
SELECT SUM(jeli.debit)
INTO varReturnsRefundsDiscounts 
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = 'RET';

-- Returns, Refund and discounts of previous year
SELECT SUM(jeli.debit)
INTO varReturnsRefundsDiscountsPrevious 
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear - 1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = 'RET'
;

-- GOGS	
SELECT SUM(jeli.debit)
INTO varCOGS
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id            
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = 'COGS'
;

-- COGS Previous Year
SELECT SUM(jeli.debit)
INTO varCOGSPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id            
WHERE YEAR(je.entry_date) = varYear - 1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = 'COGS'
;

-- Admin Expenses
SELECT SUM(jeli.debit) INTO varAdminExpenses
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('GEXP')
;

-- Admin Expenses Previous
SELECT SUM(jeli.debit) INTO varAdminExpensesPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear-1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('GEXP')
;

-- Selling Expenses
SELECT SUM(jeli.debit) INTO varSellingExpenses
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('SEXP')
;

-- Previous Selling Expenses
SELECT SUM(jeli.debit) INTO varSellingExpensesPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear-1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('SEXP')
;

-- Other Expenses
SELECT SUM(jeli.debit) INTO varOtherExpenses
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('OEXP')
;

-- Previous Other Expenses
SELECT SUM(jeli.debit) INTO varOtherExpensesPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear-1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('OEXP')
;

-- Other Income
SELECT SUM(jeli.credit) INTO varOtherIncome
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('OI')
;

-- Previous Other Income
SELECT SUM(jeli.credit) INTO varOtherIncomePrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear -1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('OI')
;

-- Income Tax
SELECT SUM(jeli.debit) INTO varIncomeTax
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('INCTAX')
;

-- Previous Income Tax
SELECT SUM(jeli.debit) INTO varIncomeTaxPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear -1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('INCTAX')
;

-- Other Taxes
SELECT SUM(jeli.debit) INTO varOtherTax
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('OTHTAX')
;

-- Previous Other Taxes
SELECT SUM(jeli.debit) INTO varOtherTaxPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear -1
AND a.profit_loss_section_id <> 0
AND ss.statement_section_code = ('OTHTAX')
;

-- Profit/Loss
SELECT SUM(jeli.credit) INTO varProfitLoss
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear
AND a.profit_loss_section_id <> 0
;

-- Profit/Loss Previous
SELECT SUM(jeli.credit) INTO varProfitLossPrevious
FROM journal_entry_line_item AS jeli
INNER JOIN `account` AS a ON a.account_id = jeli.account_id
INNER JOIN journal_entry AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN statement_section AS ss ON ss.statement_section_id = a.profit_loss_section_id
WHERE YEAR(je.entry_date) = varYear-1 
AND a.profit_loss_section_id <> 0
;


DROP TABLE IF EXISTS H_Accounting.mrivera1_tmp;
-- Created a 4 column table (Accounts, Current Year, Previous Year, and the Percentage of Change) 
-- which will be called for when running the procedures
CREATE TABLE H_Accounting.mrivera1_tmp
(	`Account` VARCHAR(100),
	Current_Year VARCHAR(100),
	Previous_Year VARCHAR(100),
	Percentage_Change VARCHAR(100)
);
-- These are the columns titles we used
INSERT INTO H_Accounting.mrivera1_tmp (`Account`, Current_Year, Previous_Year, Percentage_Change)
-- Balance Sheet Values

VALUES
('Balance Sheet', '', '', ''), -- title for balance sheet
('Current Assets', COALESCE(varCurrentAssets, 0), COALESCE(varCurrentAssetsPrevious, 0), 
	ROUND((((varCurrentAssets - varCurrentAssetsPrevious)/varCurrentAssetsPrevious) * 100),2)),

('Fixed Assets', COALESCE(varFixedAssets, 0), COALESCE(varFixedAssetsPrevious, 0), 
	ROUND((((varFixedAssets - varFixedAssetsPrevious)/varFixedAssetsPrevious) * 100),2)),

('Deferred Assets', COALESCE(varDeferredAssets, 0), COALESCE(varDeferredAssetsPrevious, 0), 
	ROUND((((varDeferredAssets - varDeferredAssetsPrevious)/varDeferredAssetsPrevious) * 100),2)),

('Current Liabilities', COALESCE(varCurrentLiabilities, 0), COALESCE(varCurrentLiabilitiesPrevious, 0), 
	ROUND((((varCurrentLiabilities - varCurrentLiabilitiesPrevious)/varCurrentLiabilitiesPrevious) * 100),2)),

('Long-Term Liabilities', COALESCE(varLongTermLiabilities, 0), COALESCE(varLongTermLiabilitiesPrevious, 0), 
	ROUND(((varLongTermLiabilities - varLongTermLiabilitiesPrevious)/varLongTermLiabilitiesPrevious * 100),2)),
    
('Deferred Liabilities', COALESCE(varDeferredLiabilities, 0), COALESCE(varDeferredLiabilitiesPrevious, 0), 
	ROUND((((varDeferredLiabilities - varDeferredLiabilitiesPrevious)/varDeferredLiabilitiesPrevious) * 100),2)),
    
('Equity', COALESCE(varEquity, 0), COALESCE(varEquityPrevious, 0), 
	ROUND((((varEquity - varEquityPrevious)/varEquityPrevious) * 100),2)),    
    
('Total Assets', COALESCE(varTotalAssets, 0), COALESCE(varTotalAssetsPrevious, 0), 
	ROUND((((varTotalAssets - varTotalAssetsPrevious)/varTotalAssetsPrevious) * 100),2)),  

('Total Liabilities And Equity', COALESCE(varTotalLiabilitiesAndEquity, 0), COALESCE(varTotalLiabilitiesAndEquityPrevious, 0), 
	ROUND((((varTotalLiabilitiesAndEquity - varTotalLiabilitiesAndEquityPrevious)/varTotalLiabilitiesAndEquityPrevious) * 100),2)),
    ('','','',''),
    
('Income Statement', '', '', ''), -- title for income statement

('Revenue', format(COALESCE(varRevenue,0),0), format(COALESCE(varRevenuePrevious,0),0), format(((varRevenue-varRevenuePrevious)/varRevenuePrevious)*100,2)),
('Returns, Refunds, Discounts', format(COALESCE(varReturnsRefundsDiscounts,0),0),format(COALESCE(varReturnsRefundsDiscountsPrevious,0),0), " "),
('Cost of goods sold', format(COALESCE(varCOGS,0),0),format(COALESCE(varCOGSPrevious,0),0), format(((varCOGS-varCOGSPrevious)/varCOGSPrevious)*100,2)),
('Gross Margin',
    format((varRevenue - IFNULL(varReturnsRefundsDiscounts,0) -varCOGS),0), 
    format((varRevenuePrevious - IFNULL(varReturnsRefundsDiscountsPrevious,0)- varCOGSPrevious),0),
    format((((varRevenue - IFNULL(varReturnsRefundsDiscounts,0) - varCOGS) - (varRevenuePrevious - IFNULL(varReturnsRefundsDiscountsPrevious,0) -varCOGSPrevious))
    /(varRevenuePrevious - IFNULL(varReturnsRefundsDiscountsPrevious,0) -varCOGSPrevious))*100,2)),
('Administrative Expenses',format(COALESCE(varAdminExpenses,0),0), format(COALESCE(varAdminExpensesPrevious,0),0), " "),
('Selling Expenses',format(COALESCE(varSellingExpenses,0),0), format(COALESCE(varSellingExpensesPrevious,0),0), format(((varSellingExpenses-varSellingExpensesPrevious)/varSellingExpensesPrevious)*100,2)),
('Other Expenses', format(COALESCE(varOtherExpenses,0),0), format(COALESCE(varOtherExpensesPrevious,0),0), format(((varOtherExpenses-varOtherExpensesPrevious)/varOtherExpensesPrevious)*100,2)),
('Other Income' , format(COALESCE(varOtherIncome,0),0), format(COALESCE(varOtherIncomePrevious,0),0), format(((varOtherIncome-varOtherIncomePrevious)/varOtherIncomePrevious)*100,2)),
('Income Tax', format(COALESCE(varIncomeTax,0),0), format(COALESCE(varIncomeTaxPrevious,0),0), format(((varIncomeTax-varIncomeTaxPrevious)/varIncomeTaxPrevious)*100,2)),
('Other Tax', format(COALESCE(varOtherTax,0),0), format(COALESCE(varOtherTaxPrevious,0),0), format(((varOtherTax-varOtherTaxPrevious)/varOtherTaxPrevious)*100,2)),
('Profit for the year', 
    (varRevenue - IFNULL(varReturnsRefundsDiscounts,0) - varCOGS -IFNULL(varAdminExpenses,0) - IFNULL(varSellingExpenses,0) 
    - IFNULL(varOtherExpenses,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0)),
    
    (varRevenuePrevious - IFNULL(varReturnsRefundsDiscountsPrevious,0) - varCOGSPrevious - IFNULL(varAdminExpensesPrevious,0) - 
    IFNULL(varSellingExpensesPrevious,0) - IFNULL(varOtherExpensesPrevious,0) + IFNULL(varOtherIncomePrevious,0) - IFNULL(varIncomeTaxPrevious,0) - IFNULL(varOtherTaxPrevious,0)),
    
    ((varRevenue - IFNULL(varReturnsRefundsDiscounts,0) - varCOGS -IFNULL(varAdminExpenses,0) - IFNULL(varSellingExpenses,0) 
    - IFNULL(varOtherExpenses,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0))-((varRevenuePrevious - IFNULL(varReturnsRefundsDiscountsPrevious,0) - varCOGSPrevious - IFNULL(varAdminExpensesPrevious,0) - 
    IFNULL(varSellingExpensesPrevious,0) - IFNULL(varOtherExpensesPrevious,0) + IFNULL(varOtherIncomePrevious,0) - IFNULL(varIncomeTaxPrevious,0) - IFNULL(varOtherTaxPrevious,0)))/(varRevenuePrevious - IFNULL(varReturnsRefundsDiscountsPrevious,0) - varCOGSPrevious - IFNULL(varAdminExpensesPrevious,0) - 
    IFNULL(varSellingExpensesPrevious,0) - IFNULL(varOtherExpensesPrevious,0) + IFNULL(varOtherIncomePrevious,0) - IFNULL(varIncomeTaxPrevious,0) - IFNULL(varOtherTaxPrevious,0))*100)),
('','','',''),

('Ratios', '', '', ''), -- Ratios titles 
('Current Ratio',
	ROUND((COALESCE(varCurrentAssets, 0)/COALESCE(varCurrentLiabilities, 0)),2),
    ROUND((COALESCE(varCurrentAssetsPrevious, 0)/COALESCE(varCurrentLiabilitiesPrevious, 0)),2),
    ROUND(((COALESCE(varCurrentAssets, 0)/COALESCE(varCurrentLiabilities, 0))-(COALESCE(varCurrentAssetsPrevious, 0)/COALESCE(varCurrentLiabilitiesPrevious, 0)))/
    (COALESCE(varCurrentAssetsPrevious, 0)/COALESCE(varCurrentLiabilitiesPrevious, 0)))),
('Debt Ratio',
	ROUND((COALESCE(varCurrentLiabilities, 0)/COALESCE(varCurrentAssets, 0)),2),
    ROUND((COALESCE(varCurrentLiabilitiesPrevious, 0)/COALESCE(varCurrentAssetsPrevious, 0)),2),
    ROUND(((COALESCE(varCurrentLiabilities, 0)/COALESCE(varCurrentAssets, 0))-(COALESCE(varCurrentLiabilitiesPrevious, 0)/COALESCE(varCurrentAssetsPrevious, 0)))/
    (COALESCE(varCurrentLiabilitiesPrevious, 0)/COALESCE(varCurrentAssetsPrevious, 0))))
    ;
    -- We were unable to add more ratios
    -- We didn't have enough time to complete the Cash Flow so we decided to not included in this procedure, sorry
SELECT *
FROM  H_Accounting.mrivera1_tmp;  

   END$$
    
    DELIMITER ;

call h_accounting.Team18_bs2(2017);
