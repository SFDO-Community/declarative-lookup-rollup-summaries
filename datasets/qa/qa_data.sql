BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"Type" VARCHAR(255), 
	"Industry" VARCHAR(255), 
	"AnnualRevenue" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES(1,'Apple','','','','0.0','');
INSERT INTO "Account" VALUES(2,'Google','','','','100000.0','');
INSERT INTO "Account" VALUES(3,'Slack','','','','0.0','');
INSERT INTO "Account" VALUES(4,'Mulesoft','','','','0.0','');
INSERT INTO "Account" VALUES(5,'Sonos','','','','0.0','');
INSERT INTO "Account" VALUES(6,'Salesforce','','','','0.0','');
INSERT INTO "Account" VALUES(7,'Microsoft','','','','0.0','');
CREATE TABLE "Case" (
	id INTEGER NOT NULL, 
	"IsEscalated" VARCHAR(255), 
	"Subject" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"Type" VARCHAR(255), 
	"Priority" VARCHAR(255), 
	"Reason" VARCHAR(255), 
	"Origin" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ContactId" VARCHAR(255), 
	"ParentId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Case" VALUES(1,'False','At least one case','It''s a case.','','Medium','','Web','6','1','');
CREATE TABLE "Contact" (
	id INTEGER NOT NULL, 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Email" VARCHAR(255), 
	"MobilePhone" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ReportsToId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Contact" VALUES(1,'False','Parker','False','False','Harris','','','','6','');
CREATE TABLE "Lead" (
	id INTEGER NOT NULL, 
	"Company" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"DoNotCall" VARCHAR(255), 
	"FirstName" VARCHAR(255), 
	"HasOptedOutOfEmail" VARCHAR(255), 
	"HasOptedOutOfFax" VARCHAR(255), 
	"IsConverted" VARCHAR(255), 
	"IsUnreadByOwner" VARCHAR(255), 
	"LastName" VARCHAR(255), 
	"Status" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Lead" VALUES(1,'Salesforce','CEO of Salesforce','False','Marc','False','False','False','False','Benioff','Open - Not Contacted');
CREATE TABLE "Opportunity" (
	id INTEGER NOT NULL, 
	"Amount" VARCHAR(255), 
	"CloseDate" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"IsPrivate" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"StageName" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	"ContactId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Opportunity" VALUES(1,'20000.0','2022-07-04','','False','Sonos Oct','Id. Decision Makers','5','');
INSERT INTO "Opportunity" VALUES(2,'20000.0','2022-07-05','','False','Sonos Nov','Id. Decision Makers','5','');
INSERT INTO "Opportunity" VALUES(3,'20000.0','2022-07-06','','False','Sonos Dec','Id. Decision Makers','5','');
INSERT INTO "Opportunity" VALUES(4,'20000.0','2022-07-03','','False','Sonos Sep','Prospecting','5','');
INSERT INTO "Opportunity" VALUES(5,'20000.0','2022-07-07','','False','Sonos Jan','Id. Decision Makers','5','');
INSERT INTO "Opportunity" VALUES(6,'20000.0','2022-07-08','','False','Sonos Feb','Id. Decision Makers','5','');
INSERT INTO "Opportunity" VALUES(7,'20000.0','2022-07-09','','False','Sonos Mar','Prospecting','5','');
INSERT INTO "Opportunity" VALUES(8,'20000.0','2022-07-10','','False','Sonos Apr','Id. Decision Makers','5','');
INSERT INTO "Opportunity" VALUES(9,'15000.0','2022-06-21','','False','Salesforce Sep','Prospecting','6','');
INSERT INTO "Opportunity" VALUES(10,'15000.0','2022-06-22','','False','Salesforce Oct','Prospecting','6','');
INSERT INTO "Opportunity" VALUES(11,'15000.0','2022-06-23','','False','Salesforce Nov','Negotiation/Review','6','');
INSERT INTO "Opportunity" VALUES(12,'15000.0','2022-06-24','','False','Salesforce Dec','Value Proposition','6','');
INSERT INTO "Opportunity" VALUES(13,'15000.0','2022-06-25','','False','Salesforce Jan','Value Proposition','6','');
INSERT INTO "Opportunity" VALUES(14,'15000.0','2022-06-26','','False','Salesforce Feb','Negotiation/Review','6','');
INSERT INTO "Opportunity" VALUES(15,'15000.0','2022-06-27','','False','Salesforce Mar','Negotiation/Review','6','');
INSERT INTO "Opportunity" VALUES(16,'15000.0','2022-06-28','','False','Salesforce Apr','Negotiation/Review','6','');
INSERT INTO "Opportunity" VALUES(17,'15000.0','2022-06-29','','False','Salesforce May','Negotiation/Review','6','');
INSERT INTO "Opportunity" VALUES(18,'15000.0','2022-06-30','','False','Salesforce Jun','Prospecting','6','');
INSERT INTO "Opportunity" VALUES(19,'25000.0','2022-07-11','','False','Microsoft May','Id. Decision Makers','7','');
INSERT INTO "Opportunity" VALUES(20,'25000.0','2022-07-12','','False','Microsoft Jun','Prospecting','7','');
INSERT INTO "Opportunity" VALUES(21,'25000.0','2022-07-13','','False','Microsoft Jul','Qualification','7','');
INSERT INTO "Opportunity" VALUES(22,'25000.0','2022-07-14','','False','Microsoft Aug','Qualification','7','');
INSERT INTO "Opportunity" VALUES(23,'25000.0','2022-07-15','','False','Microsoft Sep','Qualification','7','');
INSERT INTO "Opportunity" VALUES(24,'25000.0','2022-07-16','','False','Microsoft Oct','Qualification','7','');
INSERT INTO "Opportunity" VALUES(25,'25000.0','2022-07-17','','False','Microsoft Nov','Qualification','7','');
INSERT INTO "Opportunity" VALUES(26,'25000.0','2022-07-18','','False','Microsoft Dec','Prospecting','7','');
INSERT INTO "Opportunity" VALUES(27,'25000.0','2022-07-19','','False','Microsoft Jan','Negotiation/Review','7','');
INSERT INTO "Opportunity" VALUES(28,'25000.0','2022-07-20','','False','Microsoft Feb','Negotiation/Review','7','');
INSERT INTO "Opportunity" VALUES(29,'5000.0','2022-06-04','','False','Apple Apr','Value Proposition','1','');
INSERT INTO "Opportunity" VALUES(30,'5000.0','2022-06-01','','False','Apple Jan','Prospecting','1','');
INSERT INTO "Opportunity" VALUES(31,'5000.0','2022-06-02','','False','Apple Feb','Qualification','1','');
INSERT INTO "Opportunity" VALUES(32,'5000.0','2022-06-03','','False','Apple Mar','Needs Analysis','1','');
INSERT INTO "Opportunity" VALUES(33,'5000.0','2022-06-05','','False','Apple May','Id. Decision Makers','1','');
INSERT INTO "Opportunity" VALUES(34,'5000.0','2022-06-06','','False','Apple Jun','Perception Analysis','1','');
INSERT INTO "Opportunity" VALUES(35,'5000.0','2022-06-07','','False','Apple Jul','Negotiation/Review','1','');
INSERT INTO "Opportunity" VALUES(36,'5000.0','2022-06-08','','False','Apple Aug','Qualification','1','');
INSERT INTO "Opportunity" VALUES(37,'5000.0','2022-06-09','','False','Apple Sep','Qualification','1','');
INSERT INTO "Opportunity" VALUES(38,'5000.0','2022-06-10','','False','Apple Oct','Qualification','1','');
INSERT INTO "Opportunity" VALUES(39,'10000.0','2022-06-11','','False','Google Nov','Prospecting','2','');
INSERT INTO "Opportunity" VALUES(40,'10000.0','2022-06-12','','False','Google Dec','Prospecting','2','');
INSERT INTO "Opportunity" VALUES(41,'10000.0','2022-06-13','','False','Google Jan','Prospecting','2','');
INSERT INTO "Opportunity" VALUES(42,'10000.0','2022-06-14','','False','Google Feb','Value Proposition','2','');
INSERT INTO "Opportunity" VALUES(43,'10000.0','2022-06-15','','False','Google Mar','Value Proposition','2','');
INSERT INTO "Opportunity" VALUES(44,'10000.0','2022-06-16','','False','Google Apr','Value Proposition','2','');
INSERT INTO "Opportunity" VALUES(45,'10000.0','2022-06-17','','False','Google May','Value Proposition','2','');
INSERT INTO "Opportunity" VALUES(46,'10000.0','2022-06-18','','False','Google Jun','Prospecting','2','');
INSERT INTO "Opportunity" VALUES(47,'10000.0','2022-06-19','','False','Google Jul','Prospecting','2','');
INSERT INTO "Opportunity" VALUES(48,'10000.0','2022-06-20','','False','Google Aug','Prospecting','2','');
INSERT INTO "Opportunity" VALUES(49,'40000.0','2022-07-31','','False','Slack Jan','Prospecting','3','');
INSERT INTO "Opportunity" VALUES(50,'40000.0','2022-08-01','','False','Slack Feb','Negotiation/Review','3','');
INSERT INTO "Opportunity" VALUES(51,'40000.0','2022-08-02','','False','Slack Mar','Prospecting','3','');
INSERT INTO "Opportunity" VALUES(52,'40000.0','2022-08-03','','False','Slack Apr','Qualification','3','');
INSERT INTO "Opportunity" VALUES(53,'40000.0','2022-08-07','','False','Slack Aug','Prospecting','3','');
INSERT INTO "Opportunity" VALUES(54,'40000.0','2022-08-04','','False','Slack May','Qualification','3','');
INSERT INTO "Opportunity" VALUES(55,'40000.0','2022-08-05','','False','Slack Jun','Qualification','3','');
INSERT INTO "Opportunity" VALUES(56,'40000.0','2022-08-06','','False','Slack Jul','Prospecting','3','');
INSERT INTO "Opportunity" VALUES(57,'40000.0','2022-08-08','','False','Slack Sep','Id. Decision Makers','3','');
INSERT INTO "Opportunity" VALUES(58,'40000.0','2022-08-09','','False','Slack Oct','Prospecting','3','');
INSERT INTO "Opportunity" VALUES(59,'30000.0','2022-07-21','','False','Mulesoft Mar','Prospecting','4','');
INSERT INTO "Opportunity" VALUES(60,'30000.0','2022-07-22','','False','Mulesoft Apr','Prospecting','4','');
INSERT INTO "Opportunity" VALUES(61,'30000.0','2022-07-23','','False','Mulesoft May','Prospecting','4','');
INSERT INTO "Opportunity" VALUES(62,'30000.0','2022-07-24','','False','Mulesoft Jun','Id. Decision Makers','4','');
INSERT INTO "Opportunity" VALUES(63,'30000.0','2022-07-25','','False','Mulesoft Jul','Id. Decision Makers','4','');
INSERT INTO "Opportunity" VALUES(64,'30000.0','2022-07-26','','False','Mulesoft Aug','Qualification','4','');
INSERT INTO "Opportunity" VALUES(65,'30000.0','2022-07-27','','False','Mulesoft Sep','Qualification','4','');
INSERT INTO "Opportunity" VALUES(66,'30000.0','2022-07-28','','False','Mulesoft Oct','Qualification','4','');
INSERT INTO "Opportunity" VALUES(67,'30000.0','2022-07-29','','False','Mulesoft Nov','Prospecting','4','');
INSERT INTO "Opportunity" VALUES(68,'30000.0','2022-07-30','','False','Mulesoft Dec','Id. Decision Makers','4','');
INSERT INTO "Opportunity" VALUES(69,'20000.0','2022-07-01','','False','Sonos Jul','Prospecting','5','');
INSERT INTO "Opportunity" VALUES(70,'20000.0','2022-07-02','','False','Sonos Aug','Prospecting','5','');
CREATE TABLE "QALookupChild__c" (
	id INTEGER NOT NULL, 
	"Amount__c" VARCHAR(255), 
	"Color__c" VARCHAR(255), 
	"Description2__c" VARCHAR(255), 
	"Description__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Parent_by_String__c" VARCHAR(255), 
	"Record_Notes__c" VARCHAR(255), 
	"LookupParent2__c" VARCHAR(255), 
	"LookupParent__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "QALookupChild__c" VALUES(1,'','','','','LookupChild1','a08DS000008Qjv4YAC','A child to LookupParent1, LookupParent2, and again to LookupParent1 by the string field.','3','4');
INSERT INTO "QALookupChild__c" VALUES(2,'','','','','LookupChild3','a08DS000008Qjv4YAC','Another child to LookupParent1, LookupParent2, and again to LookupParent1 by the string field. But the values in the lookups to the parents are reversed compared to LookupChild1 and 2.','3','3');
INSERT INTO "QALookupChild__c" VALUES(3,'','','','','LookupChild2','a08DS000008Qjv4YAC','Another child to LookupParent1, LookupParent2, and again to LookupParent1 by the string field.','3','4');
CREATE TABLE "QALookupParent__c" (
	id INTEGER NOT NULL, 
	"Colours__c" VARCHAR(255), 
	"Count_of_String_Children__c" VARCHAR(255), 
	"Descriptions2__c" VARCHAR(255), 
	"Descriptions__c" VARCHAR(255), 
	"Name" VARCHAR(255), 
	"Record_Notes__c" VARCHAR(255), 
	"Self_Relationship_Number_Target__c" VARCHAR(255), 
	"Total2__c" VARCHAR(255), 
	"Total__c" VARCHAR(255), 
	"Self_Relationship__c" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "QALookupParent__c" VALUES(1,'','','','','LookupParent3','This one is a "child" to LookupParent2.','','','','3');
INSERT INTO "QALookupParent__c" VALUES(2,'','','','','LookupParent4','This one is another "child" to LookupParent2.','','','','3');
INSERT INTO "QALookupParent__c" VALUES(3,'','','','','LookupParent2','Nothing special about this lookup parent. It''s just the second one created.','','','','');
INSERT INTO "QALookupParent__c" VALUES(4,'','','','','LookupParent1','Nothing special about this lookup parent. It''s just the first one created.','','','','');
COMMIT;
