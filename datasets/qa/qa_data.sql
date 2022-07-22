BEGIN TRANSACTION;
CREATE TABLE "Account" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"Description" VARCHAR(255), 
	"BillingStreet" VARCHAR(255), 
	"BillingCity" VARCHAR(255), 
	"BillingState" VARCHAR(255), 
	"BillingPostalCode" VARCHAR(255), 
	"BillingCountry" VARCHAR(255), 
	"ShippingStreet" VARCHAR(255), 
	"ShippingCity" VARCHAR(255), 
	"ShippingState" VARCHAR(255), 
	"ShippingPostalCode" VARCHAR(255), 
	"ShippingCountry" VARCHAR(255), 
	"Phone" VARCHAR(255), 
	"Fax" VARCHAR(255), 
	"Website" VARCHAR(255), 
	"NumberOfEmployees" VARCHAR(255), 
	"AccountNumber" VARCHAR(255), 
	"Site" VARCHAR(255), 
	"Type" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Account" VALUES(1,'Apple','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(2,'Sample Account for Entitlements','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(3,'Google','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(4,'Slack','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(5,'Mulesoft','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(6,'Sonos','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(7,'Salesforce','','','','','','','','','','','','','','','','','','');
INSERT INTO "Account" VALUES(8,'Microsoft','','','','','','','','','','','','','','','','','','');
CREATE TABLE "Opportunity" (
	id INTEGER NOT NULL, 
	"Name" VARCHAR(255), 
	"StageName" VARCHAR(255), 
	"Amount" VARCHAR(255), 
	"CloseDate" VARCHAR(255), 
	"Probability" VARCHAR(255), 
	"LeadSource" VARCHAR(255), 
	"AccountId" VARCHAR(255), 
	PRIMARY KEY (id)
);
INSERT INTO "Opportunity" VALUES(1,'Apple Jan','Prospecting','5000.0','2022-06-01','10.0','Web','1');
INSERT INTO "Opportunity" VALUES(2,'Apple Feb','Qualification','5000.0','2022-06-02','11.0','Web','1');
INSERT INTO "Opportunity" VALUES(3,'Apple Mar','Needs Analysis','5000.0','2022-06-03','12.0','Web','1');
INSERT INTO "Opportunity" VALUES(4,'Apple Apr','Value Proposition','5000.0','2022-06-04','13.0','Web','1');
INSERT INTO "Opportunity" VALUES(5,'Apple May','Id. Decision Makers','5000.0','2022-06-05','14.0','Web','1');
INSERT INTO "Opportunity" VALUES(6,'Apple Jun','Perception Analysis','5000.0','2022-06-06','15.0','Phone Inquiry','1');
INSERT INTO "Opportunity" VALUES(7,'Apple Jul','Negotiation/Review','5000.0','2022-06-07','16.0','Phone Inquiry','1');
INSERT INTO "Opportunity" VALUES(8,'Apple Aug','Qualification','5000.0','2022-06-08','17.0','Phone Inquiry','1');
INSERT INTO "Opportunity" VALUES(9,'Apple Sep','Qualification','5000.0','2022-06-09','18.0','Phone Inquiry','1');
INSERT INTO "Opportunity" VALUES(10,'Apple Oct','Qualification','5000.0','2022-06-10','19.0','Phone Inquiry','1');
INSERT INTO "Opportunity" VALUES(11,'Google Nov','Prospecting','10000.0','2022-06-11','20.0','Web','3');
INSERT INTO "Opportunity" VALUES(12,'Google Dec','Prospecting','10000.0','2022-06-12','21.0','Web','3');
INSERT INTO "Opportunity" VALUES(13,'Google Jan','Prospecting','10000.0','2022-06-13','22.0','Web','3');
INSERT INTO "Opportunity" VALUES(14,'Google Feb','Value Proposition','10000.0','2022-06-14','23.0','Web','3');
INSERT INTO "Opportunity" VALUES(15,'Google Mar','Value Proposition','10000.0','2022-06-15','24.0','Web','3');
INSERT INTO "Opportunity" VALUES(16,'Google Apr','Value Proposition','10000.0','2022-06-16','25.0','Web','3');
INSERT INTO "Opportunity" VALUES(17,'Google May','Value Proposition','10000.0','2022-06-17','26.0','Web','3');
INSERT INTO "Opportunity" VALUES(18,'Google Jun','Prospecting','10000.0','2022-06-18','27.0','Web','3');
INSERT INTO "Opportunity" VALUES(19,'Google Jul','Prospecting','10000.0','2022-06-19','28.0','Web','3');
INSERT INTO "Opportunity" VALUES(20,'Google Aug','Prospecting','10000.0','2022-06-20','29.0','Web','3');
INSERT INTO "Opportunity" VALUES(21,'Salesforce Sep','Prospecting','15000.0','2022-06-21','30.0','Web','7');
INSERT INTO "Opportunity" VALUES(22,'Salesforce Oct','Prospecting','15000.0','2022-06-22','31.0','Web','7');
INSERT INTO "Opportunity" VALUES(23,'Salesforce Nov','Negotiation/Review','15000.0','2022-06-23','32.0','Web','7');
INSERT INTO "Opportunity" VALUES(24,'Salesforce Dec','Value Proposition','15000.0','2022-06-24','33.0','Web','7');
INSERT INTO "Opportunity" VALUES(25,'Salesforce Jan','Value Proposition','15000.0','2022-06-25','34.0','Web','7');
INSERT INTO "Opportunity" VALUES(26,'Salesforce Feb','Negotiation/Review','15000.0','2022-06-26','35.0','Web','7');
INSERT INTO "Opportunity" VALUES(27,'Salesforce Mar','Negotiation/Review','15000.0','2022-06-27','36.0','Web','7');
INSERT INTO "Opportunity" VALUES(28,'Salesforce Apr','Negotiation/Review','15000.0','2022-06-28','37.0','Web','7');
INSERT INTO "Opportunity" VALUES(29,'Salesforce May','Negotiation/Review','15000.0','2022-06-29','38.0','Web','7');
INSERT INTO "Opportunity" VALUES(30,'Salesforce Jun','Prospecting','15000.0','2022-06-30','39.0','Web','7');
INSERT INTO "Opportunity" VALUES(31,'Sonos Jul','Prospecting','20000.0','2022-07-01','40.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(32,'Sonos Aug','Prospecting','20000.0','2022-07-02','41.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(33,'Sonos Sep','Prospecting','20000.0','2022-07-03','42.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(34,'Sonos Oct','Id. Decision Makers','20000.0','2022-07-04','43.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(35,'Sonos Nov','Id. Decision Makers','20000.0','2022-07-05','44.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(36,'Sonos Dec','Id. Decision Makers','20000.0','2022-07-06','45.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(37,'Sonos Jan','Id. Decision Makers','20000.0','2022-07-07','46.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(38,'Sonos Feb','Id. Decision Makers','20000.0','2022-07-08','47.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(39,'Sonos Mar','Prospecting','20000.0','2022-07-09','48.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(40,'Sonos Apr','Id. Decision Makers','20000.0','2022-07-10','49.0','Phone Inquiry','6');
INSERT INTO "Opportunity" VALUES(41,'Microsoft May','Id. Decision Makers','25000.0','2022-07-11','50.0','Other','8');
INSERT INTO "Opportunity" VALUES(42,'Microsoft Jun','Prospecting','25000.0','2022-07-12','51.0','Other','8');
INSERT INTO "Opportunity" VALUES(43,'Microsoft Jul','Qualification','25000.0','2022-07-13','52.0','Other','8');
INSERT INTO "Opportunity" VALUES(44,'Microsoft Aug','Qualification','25000.0','2022-07-14','53.0','Other','8');
INSERT INTO "Opportunity" VALUES(45,'Microsoft Sep','Qualification','25000.0','2022-07-15','54.0','Other','8');
INSERT INTO "Opportunity" VALUES(46,'Microsoft Oct','Qualification','25000.0','2022-07-16','55.0','Other','8');
INSERT INTO "Opportunity" VALUES(47,'Microsoft Nov','Qualification','25000.0','2022-07-17','56.0','Other','8');
INSERT INTO "Opportunity" VALUES(48,'Microsoft Dec','Prospecting','25000.0','2022-07-18','57.0','Other','8');
INSERT INTO "Opportunity" VALUES(49,'Microsoft Jan','Negotiation/Review','25000.0','2022-07-19','58.0','Web','8');
INSERT INTO "Opportunity" VALUES(50,'Microsoft Feb','Negotiation/Review','25000.0','2022-07-20','59.0','Web','8');
INSERT INTO "Opportunity" VALUES(51,'Mulesoft Mar','Prospecting','30000.0','2022-07-21','60.0','Web','5');
INSERT INTO "Opportunity" VALUES(52,'Mulesoft Apr','Prospecting','30000.0','2022-07-22','61.0','Web','5');
INSERT INTO "Opportunity" VALUES(53,'Mulesoft May','Prospecting','30000.0','2022-07-23','62.0','Web','5');
INSERT INTO "Opportunity" VALUES(54,'Mulesoft Jun','Id. Decision Makers','30000.0','2022-07-24','63.0','Web','5');
INSERT INTO "Opportunity" VALUES(55,'Mulesoft Jul','Id. Decision Makers','30000.0','2022-07-25','64.0','Web','5');
INSERT INTO "Opportunity" VALUES(56,'Mulesoft Aug','Qualification','30000.0','2022-07-26','65.0','Purchased List','5');
INSERT INTO "Opportunity" VALUES(57,'Mulesoft Sep','Qualification','30000.0','2022-07-27','66.0','Purchased List','5');
INSERT INTO "Opportunity" VALUES(58,'Mulesoft Oct','Qualification','30000.0','2022-07-28','67.0','Purchased List','5');
INSERT INTO "Opportunity" VALUES(59,'Mulesoft Nov','Prospecting','30000.0','2022-07-29','68.0','Purchased List','5');
INSERT INTO "Opportunity" VALUES(60,'Mulesoft Dec','Id. Decision Makers','30000.0','2022-07-30','69.0','Purchased List','5');
INSERT INTO "Opportunity" VALUES(61,'Slack Jan','Prospecting','40000.0','2022-07-31','70.0','Purchased List','4');
INSERT INTO "Opportunity" VALUES(62,'Slack Feb','Negotiation/Review','40000.0','2022-08-01','71.0','Purchased List','4');
INSERT INTO "Opportunity" VALUES(63,'Slack Mar','Prospecting','40000.0','2022-08-02','72.0','Purchased List','4');
INSERT INTO "Opportunity" VALUES(64,'Slack Apr','Qualification','40000.0','2022-08-03','73.0','Purchased List','4');
INSERT INTO "Opportunity" VALUES(65,'Slack May','Qualification','40000.0','2022-08-04','74.0','Purchased List','4');
INSERT INTO "Opportunity" VALUES(66,'Slack Jun','Qualification','40000.0','2022-08-05','75.0','Purchased List','4');
INSERT INTO "Opportunity" VALUES(67,'Slack Jul','Prospecting','40000.0','2022-08-06','76.0','Web','4');
INSERT INTO "Opportunity" VALUES(68,'Slack Aug','Prospecting','40000.0','2022-08-07','77.0','Web','4');
INSERT INTO "Opportunity" VALUES(69,'Slack Sep','Id. Decision Makers','40000.0','2022-08-08','78.0','Web','4');
INSERT INTO "Opportunity" VALUES(70,'Slack Oct','Prospecting','40000.0','2022-08-09','79.0','Web','4');
COMMIT;
