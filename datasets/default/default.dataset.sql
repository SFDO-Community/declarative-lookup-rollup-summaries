BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"Description" VARCHAR(255), 
	"Fax" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"AccountNumber" VARCHAR(255), 
	"Phone" VARCHAR(255), 
	"Rating" VARCHAR(255), 
	"Site" VARCHAR(255), 
	"AccountSource" VARCHAR(255), 
	"Type" VARCHAR(255), 
	"AnnualRevenue" VARCHAR(255), 
	"BillingCity" VARCHAR(255), 
	"BillingCountry" VARCHAR(255), 
	"BillingGeocodeAccuracy" VARCHAR(255), 
	"BillingLatitude" VARCHAR(255), 
	"BillingLongitude" VARCHAR(255), 
	"BillingState" VARCHAR(255), 
	"BillingStreet" VARCHAR(255), 
	"BillingPostalCode" VARCHAR(255), 
	"CleanStatus" VARCHAR(255), 
	"DunsNumber" VARCHAR(255), 
	"Jigsaw" VARCHAR(255), 
	"NumberOfEmployees" VARCHAR(255), 
	"DLRS_Expct_Rev_from_Campaigns__c" VARCHAR(255), 
	"DLRS_Expct_Rev_from_Campaigns_last_year__c" VARCHAR(255), 
	"DLRS_Expct_Rev_from_Campaigns_this_year__c" VARCHAR(255), 
	"Industry" VARCHAR(255), 
	"NaicsCode" VARCHAR(255), 
	"NaicsDesc" VARCHAR(255), 
	"No_of_Applications_Accepted_Last_Year__c" VARCHAR(255), 
	"No_of_Accepted_Applications__c" VARCHAR(255), 
	"No_of_Applications_Submitted_Last_year__c" VARCHAR(255), 
	"No_of_Submitted_Applications_This_Year__c" VARCHAR(255), 
	"NumberOfLocations__c" VARCHAR(255), 
	"Ownership" VARCHAR(255), 
	"ShippingCity" VARCHAR(255), 
	"ShippingCountry" VARCHAR(255), 
	"ShippingGeocodeAccuracy" VARCHAR(255), 
	"ShippingLatitude" VARCHAR(255), 
	"ShippingLongitude" VARCHAR(255), 
	"ShippingState" VARCHAR(255), 
	"ShippingStreet" VARCHAR(255), 
	"ShippingPostalCode" VARCHAR(255), 
	"Sic" VARCHAR(255), 
	"SicDesc" VARCHAR(255), 
	"SLAExpirationDate__c" VARCHAR(255), 
	"TickerSymbol" VARCHAR(255), 
	"Tradestyle" VARCHAR(255), 
	"Website" VARCHAR(255), 
	"YearStarted" VARCHAR(255), 
	"DandbCompanyId" VARCHAR(255), 
	"OperatingHoursId" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES(1,'','','School 2','','','','','','','','','','','','','','','','Pending','','','','','','','','','','1.0','1.0','1.0','1.0','','','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(2,'','','Bright Students Academy','','','','','','','','','','','','','','','','Pending','','','','','','','','','','0.0','1.0','0.0','2.0','','','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(3,'','','Test Account Two','','','','','','','','','','','','','','','','Pending','','','','11000000.0','1330000.0','865000.0','','','','0.0','0.0','0.0','0.0','','','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(4,'','','School 1','','','','','','','','','','','','','','','','Pending','','','','','','','','','','1.0','1.0','1.0','2.0','','','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(5,'','','Test Account One','','','','','','','','','','','','','','','','Pending','','','','497125.0','422000.0','200000.0','','','','0.0','0.0','0.0','0.0','','','','','','','','','','','','','','','','','','','','');
CREATE TABLE "Application__c" (
	id INTEGER NOT NULL, 
	"Application_Status__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Start_Date__c" VARCHAR(255), 
	"Applying_School__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Application__c" VALUES(1,'Submitted','Test App6','2023-01-01','1');
INSERT INTO "Application__c" VALUES(2,'Accepted','Test App7','2023-02-01','1');
INSERT INTO "Application__c" VALUES(3,'Accepted','Fantastic Student','2023-09-01','2');
INSERT INTO "Application__c" VALUES(4,'Accepted','Test App8','2022-01-01','1');
INSERT INTO "Application__c" VALUES(5,'Submitted','Test App9','2022-02-01','1');
INSERT INTO "Application__c" VALUES(6,'Submitted','Test App5','2022-03-01','4');
INSERT INTO "Application__c" VALUES(7,'Accepted','Test App4','2022-03-01','4');
INSERT INTO "Application__c" VALUES(8,'Submitted','Average Student','2023-09-01','2');
INSERT INTO "Application__c" VALUES(9,'Submitted','Test App1','2023-01-29','4');
INSERT INTO "Application__c" VALUES(10,'Submitted','Test App2','2023-03-02','4');
INSERT INTO "Application__c" VALUES(11,'Accepted','Test App3','2023-01-01','4');
INSERT INTO "Application__c" VALUES(12,'Rejected','Poor Student','2023-09-01','2');
INSERT INTO "Application__c" VALUES(13,'Submitted','Above Average Student','2023-09-01','2');
CREATE TABLE "Campaign" (
	id INTEGER NOT NULL, 
	"IsActive" VARCHAR(255), 
	"ActualCost" VARCHAR(255), 
	"BudgetedCost" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"EndDate" VARCHAR(255), 
	"ExpectedResponse" VARCHAR(255), 
	"ExpectedRevenue" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"NumberSent" VARCHAR(255), 
	"StartDate" VARCHAR(255), 
	"Status" VARCHAR(255), 
	"Type" VARCHAR(255), 
	"Account__c" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Campaign" VALUES(1,'False','','','','','0.0','65125.0','Second Test Campaign','0.0','','Planned','Conference','5','');
INSERT INTO "Campaign" VALUES(2,'False','','','','','0.0','222000.0','Acct 1 Campaign in 2022','0.0','2022-05-01','Planned','Conference','5','');
INSERT INTO "Campaign" VALUES(3,'False','','','','','0.0','3000000.0','Third Test Campaign','0.0','','Planned','Conference','3','');
INSERT INTO "Campaign" VALUES(4,'False','','','','','0.0','665000.0','Campaign in 2023','0.0','2023-05-01','Planned','Conference','3','');
INSERT INTO "Campaign" VALUES(5,'False','','','','','0.0','465000.0','Campaign in 2022','0.0','2022-05-01','Planned','Conference','3','');
INSERT INTO "Campaign" VALUES(6,'False','','','','','0.0','3000000.0','Campaign in 2018','0.0','2018-05-01','Planned','Conference','3','');
INSERT INTO "Campaign" VALUES(7,'False','','','','','0.0','10000.0','One Test Campaign','0.0','','Planned','Conference','5','');
INSERT INTO "Campaign" VALUES(8,'False','','','','','0.0','3670000.0','Campaign in 2019','0.0','2019-05-01','Planned','Conference','3','');
INSERT INTO "Campaign" VALUES(9,'False','','','','','0.0','200000.0','Second Campaign in 2023','0.0','2023-05-01','Planned','Conference','3','');
INSERT INTO "Campaign" VALUES(10,'False','','','','','0.0','200000.0','Acct 1 Campaign in 2023','0.0','2023-05-01','Planned','Conference','5','');
CREATE TABLE "DandBCompany" (
	id INTEGER NOT NULL, 
	"DunsNumber" VARCHAR(255), 
	"Name" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Department__c" (
	id INTEGER NOT NULL, 
	"AVG__c" VARCHAR(255), 
	"CONCATENATE__c" VARCHAR(255), 
	"CONCATENATE_DISTINCT__c" VARCHAR(255), 
	"COUNT__c" VARCHAR(255), 
	"COUNT_DISTINCT__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"FIRST__c" VARCHAR(255), 
	"LAST__c" VARCHAR(255), 
	"MAX__c" VARCHAR(255), 
	"MIN__c" VARCHAR(255), 
	"SUM__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Department__c" VALUES(1,'4.666666666666667','Green;Red;Yellow;Green;Red;Yellow;Green;Red;Yellow','Green;Red;Yellow','9.0','3.0','Information Technology','Green','Yellow','10.0','1.0','42.0');
INSERT INTO "Department__c" VALUES(2,'5.75','Yellow;Red;Yellow;Green;Red;Yellow;Green;Red','Yellow;Red;Green','8.0','3.0','Finance','Yellow','Red','10.0','1.0','46.0');
INSERT INTO "Department__c" VALUES(3,'5.222222222222222','Red;Yellow;Green;Red;Yellow;Green;Red;Yellow;Green','Red;Yellow;Green','9.0','3.0','Human Resources','Red','Green','10.0','1.0','47.0');
INSERT INTO "Department__c" VALUES(4,'5.555555555555555','Yellow;Green;Red;Yellow;Green;Red;Yellow;Green;Red','Yellow;Green;Red','9.0','3.0','Research and Development','Yellow','Red','10.0','2.0','50.0');
INSERT INTO "Department__c" VALUES(5,'6.641666666666667','Red;Yellow;Green;Red;Green;Yellow;Red;Green;Yellow;Red;Green;Yellow','Red;Yellow;Green','12.0','3.0','Marketing','Red','Yellow','10.0','1.2','79.7');
CREATE TABLE "OperatingHours" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"TimeZone" VARCHAR(255), 
	PRIMARY KEY (id)
);
CREATE TABLE "Restriction__c" (
	id INTEGER NOT NULL, 
	"Number__c" VARCHAR(255), 
	"Picklist__c" VARCHAR(255), 
	"Department__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Restriction__c" VALUES(1,'1.2','Red','5');
INSERT INTO "Restriction__c" VALUES(2,'4.5','Yellow','5');
INSERT INTO "Restriction__c" VALUES(3,'6.0','Green','5');
INSERT INTO "Restriction__c" VALUES(4,'10.0','Red','5');
INSERT INTO "Restriction__c" VALUES(5,'2.0','Yellow','4');
INSERT INTO "Restriction__c" VALUES(6,'1.0','Green','1');
INSERT INTO "Restriction__c" VALUES(7,'9.0','Red','3');
INSERT INTO "Restriction__c" VALUES(8,'8.0','Yellow','2');
INSERT INTO "Restriction__c" VALUES(9,'5.0','Green','5');
INSERT INTO "Restriction__c" VALUES(10,'7.0','Red','4');
INSERT INTO "Restriction__c" VALUES(11,'10.0','Yellow','1');
INSERT INTO "Restriction__c" VALUES(12,'2.0','Green','3');
INSERT INTO "Restriction__c" VALUES(13,'4.0','Red','2');
INSERT INTO "Restriction__c" VALUES(14,'9.0','Yellow','5');
INSERT INTO "Restriction__c" VALUES(15,'10.0','Green','4');
INSERT INTO "Restriction__c" VALUES(16,'4.0','Red','1');
INSERT INTO "Restriction__c" VALUES(17,'10.0','Yellow','3');
INSERT INTO "Restriction__c" VALUES(18,'8.0','Green','2');
INSERT INTO "Restriction__c" VALUES(19,'8.0','Red','5');
INSERT INTO "Restriction__c" VALUES(20,'3.0','Yellow','4');
INSERT INTO "Restriction__c" VALUES(21,'6.0','Green','1');
INSERT INTO "Restriction__c" VALUES(22,'7.0','Red','3');
INSERT INTO "Restriction__c" VALUES(23,'3.0','Yellow','2');
INSERT INTO "Restriction__c" VALUES(24,'5.0','Green','5');
INSERT INTO "Restriction__c" VALUES(25,'8.0','Red','4');
INSERT INTO "Restriction__c" VALUES(26,'7.0','Yellow','1');
INSERT INTO "Restriction__c" VALUES(27,'7.0','Green','3');
INSERT INTO "Restriction__c" VALUES(28,'1.0','Red','2');
INSERT INTO "Restriction__c" VALUES(29,'6.0','Yellow','5');
INSERT INTO "Restriction__c" VALUES(30,'5.0','Green','4');
INSERT INTO "Restriction__c" VALUES(31,'1.0','Red','1');
INSERT INTO "Restriction__c" VALUES(32,'2.0','Yellow','3');
INSERT INTO "Restriction__c" VALUES(33,'5.0','Green','2');
INSERT INTO "Restriction__c" VALUES(34,'9.0','Red','5');
INSERT INTO "Restriction__c" VALUES(35,'3.0','Yellow','4');
INSERT INTO "Restriction__c" VALUES(36,'1.0','Green','1');
INSERT INTO "Restriction__c" VALUES(37,'2.0','Red','3');
INSERT INTO "Restriction__c" VALUES(38,'7.0','Yellow','2');
INSERT INTO "Restriction__c" VALUES(39,'7.0','Green','5');
INSERT INTO "Restriction__c" VALUES(40,'10.0','Red','4');
INSERT INTO "Restriction__c" VALUES(41,'2.0','Yellow','1');
INSERT INTO "Restriction__c" VALUES(42,'1.0','Green','3');
INSERT INTO "Restriction__c" VALUES(43,'10.0','Red','2');
INSERT INTO "Restriction__c" VALUES(44,'9.0','Yellow','5');
INSERT INTO "Restriction__c" VALUES(45,'2.0','Green','4');
INSERT INTO "Restriction__c" VALUES(46,'10.0','Red','1');
INSERT INTO "Restriction__c" VALUES(47,'7.0','Yellow','3');
COMMIT;
