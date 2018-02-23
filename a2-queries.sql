.print Question 1 -defourni

SELECT S.local_contact
FROM service_agreements S,accounts A,personnel P
WHERE S.master_account = A.account_no AND
S.waste_type = "hazardous waste" AND
A.account_mgr = P.pid AND
P.name = "Dan Brown";

-------------------------------------------------------------

.print Question 2 -defourni

SELECT A.customer_name, A.contact_info, P.name
FROM accounts A, personnel P 
WHERE A.customer_type = "industrial" AND
DATE(A.end_date) <= DATE('now','+30 day') AND
A.account_mgr = P.pid;

---------------------------------------------------------------

.print Question 3 -defourni

SELECT DISTINCT a.customer_name
FROM accounts A, service_agreements S
WHERE A.account_no = S.master_account AND
S.waste_type = "mixed waste"
EXCEPT
SELECT a.customer_name
FROM accounts A, service_agreements S
WHERE A.account_no = S.master_account AND
S.waste_type = "paper";

-----------------------------------------------------------------

.print Question 4 -defourni

SELECT M.manager_title AS "Account Type",COUNT(S.service_no) AS "Number of Services",(Sum(S.price)-Sum(S.internal_cost)) AS "Profit"
FROM account_managers M, service_agreements S, accounts A 
WHERE M.pid = A.account_mgr AND
S.master_account = A.account_no
GROUP BY (M.manager_title);

--------------------------------------------------------------------

.print Question 5 -defourni

SELECT P.name
FROM personnel P, service_fulfillments F
WHERE P.pid = F.driver_id
GROUP BY F.driver_id 
	HAVING COUNT(*) > 10;

---------------------------------------------------------------------------

.print Question 6 -defourni

SELECT C.container_id
FROM containers C, service_fulfillments F 
WHERE C.container_id = F.cid_drop_off AND
DATE(C.date_when_built) < DATE('now','-5 year')
GROUP BY F.cid_drop_off 
	HAVING COUNT(*) > 10;	
	
-----------------------------------------------------------------------------

.print Question 7 -defourni

SELECT container_id
FROM containers
EXCEPT
SELECT cid_drop_off
FROM service_fulfillments
UNION
SELECT C.container_id 
FROM containers C, service_fulfillments F1, service_fulfillments F2
WHERE C.container_id = F1.cid_drop_off AND
C.container_id = F2.cid_pick_up
GROUP BY C.container_id
	HAVING MAX(DATE(F1.date_time)) < MAX(DATE(F2.date_time));
	
------------------------------------------------------------------------------

.print Question 8 -defourni

SELECT driver_id
FROM (SELECT DISTINCT master_account, driver_id
FROM service_fulfillments)
GROUP BY driver_id
HAVING COUNT(master_account) IN (SELECT COUNT(master_account)
FROM (SELECT DISTINCT master_account from service_fulfillments WHERE driver_id = "23769"))

EXCEPT

SELECT DISTINCT driver_id
FROM service_fulfillments
WHERE master_account NOT IN(
	SELECT DISTINCT master_account
	FROM service_fulfillments
	WHERE driver_id = "23769")
;

-----------------------------------------------------------------------------

.print Question 9 -defourni

CREATE VIEW last2_inspections_of_company_trucks AS
SELECT * FROM(
SELECT T.truck_id AS truck_id,T.truck_type AS truck_type, MAX(DATE(M.service_date)) AS inspection_date
FROM maintenance_records M, trucks T
WHERE T.truck_id = M.truck_id AND
T.truck_id NOT IN (SELECT owned_truck_id FROM drivers) AND
M.service_date NOT IN (SELECT MAX(service_date) FROM maintenance_records GROUP BY(truck_id))
GROUP BY(T.truck_id)

UNION ALL

SELECT T.truck_id AS truck_id,T.truck_type AS truck_type, MAX(DATE(M.service_date)) AS inspection_date
FROM maintenance_records M, trucks T
WHERE T.truck_id = M.truck_id AND
T.truck_id NOT IN (SELECT owned_truck_id FROM drivers)
GROUP BY(T.truck_id)
)
ORDER BY(truck_id);

-------------------------------------------------------------------------------------

.print Question 10 -defourni

SELECT I1.truck_type AS "Truck Type", MAX(I1.inspection_date - I2.inspection_date) AS "MAX", MIN(I1.inspection_date - I2.inspection_date) AS "MIN", AVG(I1.inspection_date - I2.inspection_date) AS "AVG"
FROM last2_inspections_of_company_trucks I1, last2_inspections_of_company_trucks I2
WHERE I1.truck_type = I2.truck_type
AND (I1.inspection_date - I2.inspection_date) > 0
GROUP BY(I1.truck_type);
