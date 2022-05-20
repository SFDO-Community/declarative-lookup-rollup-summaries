public with sharing class CronTriggersSelector extends fflib_SObjectSelector {
  public List<Schema.SObjectField> getSObjectFieldList() {
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

  public List<CronTrigger> selectAllScheduledApex() {
    List<CronTrigger> ct = Database.query(
      newQueryFactory()
        .selectfield('CronJobDetail.Name')
        .setCondition('CronJobDetail.JobType = \'7\'')
        .tosoql()
    );

    return ct;
  }

  public List<CronTrigger> selectScheduledApexById(String id) {
    id = '%' + id + '%';

    List<CronTrigger> ct = Database.query(
      newQueryFactory()
        .selectfield('CronJobDetail.Name')
        .setCondition('CronJobDetail.JobType = \'7\'')
        .setCondition('CronJobDetail.Name LIKE :id')
        .setLimit(1)
        .tosoql()
    );

    return ct;
  }
}
