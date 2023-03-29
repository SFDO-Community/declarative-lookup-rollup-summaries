BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"NumberOfLocations__c" VARCHAR(255), 
	"SLAExpirationDate__c" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES(1,'Sample Account for Entitlements','','','');
CREATE TABLE "Contact" (
	id INTEGER NOT NULL, 
	"DLRS_All_OCRs__c" VARCHAR(255), 
	"DLRS_CountOCRs__c" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ReportsToId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Contact" VALUES(1,'Business User;Evaluator;Executive Sponsor','3.0','False','test','False','False','two','','');
INSERT INTO "Contact" VALUES(2,'Evaluator;Executive Sponsor','2.0','False','test','False','False','three','','');
INSERT INTO "Contact" VALUES(3,'Decision Maker;Evaluator;Decision Maker;Executive Sponsor','4.0','False','test','False','False','one','','');
CREATE TABLE "OpportunityContactRole" (
	id INTEGER NOT NULL, 
	"IsPrimary" VARCHAR(255), 
	"Role" VARCHAR(255), 
	"ContactId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "OpportunityContactRole" VALUES(1,'False','Decision Maker','3');
INSERT INTO "OpportunityContactRole" VALUES(2,'False','Evaluator','1');
INSERT INTO "OpportunityContactRole" VALUES(3,'False','Executive Sponsor','3');
INSERT INTO "OpportunityContactRole" VALUES(4,'False','Executive Sponsor','2');
INSERT INTO "OpportunityContactRole" VALUES(5,'False','Executive Sponsor','1');
INSERT INTO "OpportunityContactRole" VALUES(6,'False','Decision Maker','3');
INSERT INTO "OpportunityContactRole" VALUES(7,'False','Business User','1');
INSERT INTO "OpportunityContactRole" VALUES(8,'False','Evaluator','2');
INSERT INTO "OpportunityContactRole" VALUES(9,'False','Evaluator','3');
COMMIT;
