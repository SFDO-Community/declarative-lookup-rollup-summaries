public with sharing class CronTriggersSelector extends fflib_SObjectSelector {

    List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
          CronTrigger.CronExpression,
          CronTrigger.CronJobDetailId,
          CronTrigger.EndTime,
          CronTrigger.NextFireTime,
          CronTrigger.OwnerId,
          CronTrigger.PreviousFireTime,
          CronTrigger.StartTime,
          CronTrigger.State,
          CronTrigger.TimesTriggered,
          CronTrigger.TimeZoneSidKey
        };
    }

        public Schema.SObjectType getSObjectType() {
            return CronTrigger.sObjectType;
          }

        public List<CronTrigger> selectAll(){
            List<CronTrigger> ct = new List<CronTrigger>{};


            return ct;
        }

    }
