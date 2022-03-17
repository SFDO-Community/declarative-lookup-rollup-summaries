public with sharing class RollupSummaryViewController {
  public pagereference redirect() {
    PageReference redirectPageWithId = Page.managelookuprollupsummaries;
    redirectPageWithId.setRedirect(true);
    redirectPageWithId.getParameters()
      .put(
        'id',
        Apexpages.currentPage().getParameters().get('newid').escapeHtml4()
      );

    return redirectPageWithId;
  }

  public List<ViewerObject> getView() {
    Map<String, ViewerObject> viewerMap = new Map<String, ViewerObject>();
    list<RollupSummary> rs = new RollupSummariesSelector.CustomMetadataSelector(
        false,
        false
      )
      .selectAll();

    if (rs.isEmpty()) {
      return null;
    }

    viewerMap = setRollupSummaryToMap(rs);
    viewerMap = setCronTriggerToMap(viewerMap);

    return viewerMap.values();
  }

  private Map<String, ViewerObject> setRollupSummaryToMap(
    List<RollupSummary> rs
  ) {
    Map<String, ViewerObject> viewerMap = new Map<String, ViewerObject>();

    for (integer i = 0; i < rs.size(); i++) {
      ViewerObject viewObj = new ViewerObject();
      viewObj.label = rs[i].UniqueName;
      viewObj.calcMode = rs[i].CalculationMode;
      viewObj.RecordId = rs[i].id;
      viewerMap.put(rs[i].id.substring(0, 15), viewObj);
    }
    return viewerMap;
  }

  private Map<String, ViewerObject> setCronTriggerToMap(
    Map<String, ViewerObject> viewerMap
  ) {
    List<CronTrigger> ct = [
      SELECT
        CronJobDetail.Name,
        CronExpression,
        OwnerId,
        NextFireTime,
        TimesTriggered
      FROM CronTrigger
      WHERE CronJobDetail.JobType = '7'
      WITH SECURITY_ENFORCED
    ];

    for (CronTrigger c : ct) {
      String id = c.CronJobDetail.Name.substringBetween('(', ')');
      if (viewerMap.containsKey(id)) {
        viewerMap.get(id).apexJobName = c.CronJobDetail.Name;
        viewerMap.get(id).scheduledTime = c.CronExpression;
        viewerMap.get(id).jobFiredCount = c.TimesTriggered;
      }
    }
    return viewerMap;
  }

  private class ViewerObject {
    public string recordId { get; set; }
    public string label { get; set; }
    public string calcMode { get; set; }

    public string scheduledTime { get; set; }
    public Integer jobFiredCount { get; set; }
    public Datetime endtime { get; set; }
    public string apexJobName { get; set; }
  }
}
