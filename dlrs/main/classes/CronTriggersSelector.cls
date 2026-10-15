public with sharing class CronTriggersSelector extends fflib_SObjectSelector {
  public override List<Schema.SObjectField> getSObjectFieldList() {
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

  public override Schema.SObjectType getSObjectType() {
    return CronTrigger.sObjectType;
  }

  public List<CronTrigger> selectAllScheduledApex() {
    List<String> omittedStates = new List<String>{ 'DELETED' };

    List<CronTrigger> ct = Database.query(
      newQueryFactory()
        .selectfield('CronJobDetail.Name')
        .setCondition(
          'CronJobDetail.JobType = \'7\' AND State NOT IN :omittedStates'
        )
        .tosoql()
    );

    return ct;
  }

  public List<CronTrigger> selectScheduledApexById(String id) {
    return selectFullCalculateJobsByRollupId(id);
  }

  public List<CronTrigger> selectFullCalculateJobsByRollupId(String rollupId) {
    String idPattern = '%' + String.valueOf(rollupId).substring(0, 15) + '%';

    return Database.query(
      newQueryFactory()
        .selectfield('CronJobDetail.Name')
        .setCondition(
          'CronJobDetail.JobType = \'7\' AND CronJobDetail.Name LIKE :idPattern'
        )
        .tosoql()
    );
  }
}
