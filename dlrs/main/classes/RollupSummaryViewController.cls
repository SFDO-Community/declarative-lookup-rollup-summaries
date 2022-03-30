//depends
public with sharing class RollupSummaryViewController {
  private Map<String, ViewerObject> viewerRecords;
  private List<RollupSummary> rollupRecords;
  private List<CronTrigger> cronRecords;

  public RollupSummaryViewController() {
    setupData();
  }

  @TestVisible
  private RollupSummaryViewController(
    List<RollupSummary> rs,
    List<CronTrigger> ct
  ) {
    this.viewerRecords = new Map<String, ViewerObject>();
    this.rollupRecords = rs;
    this.cronRecords = ct;
  }

  //Visualforce page needs access to this method
  public pagereference redirect() {
    try {
      PageReference redirectPageWithId = Page.managelookuprollupsummaries;
      redirectPageWithId.setRedirect(true);
      redirectPageWithId.getParameters()
        .put(
          'id',
          Apexpages.currentPage().getParameters().get('newid').escapeHtml4()
        );
      return redirectPageWithId;
    } catch (Exception e) {
      return Page.RollupSummaryView;
    }
  }

  //visualforce page needs access to this method
  public List<ViewerObject> getView() {
    //if no rollups then impossible to have scheduled jobs attached to them.
    if (rollupRecords.isEmpty()) {
      return null;
    }
    setRollupRecords();
    setCronRecords();
    return viewerRecords.values();
  }

  //setup instance varaibles with SOQL data
  private void setupData() {
    rollupRecords = new RollupSummariesSelector().selectAll();
    CronRecords = new CronTriggersSelector().selectAllScheduledApex();
    viewerRecords = new Map<String, ViewerObject>();
  }

  private void setRollupRecords() {
    for (RollupSummary rollup : rollupRecords) {
      ViewerObject viewObj = new ViewerObject();
      viewObj.label = rollup.UniqueName;
      viewObj.calcMode = rollup.CalculationMode;
      viewObj.RecordId = rollup.id;
      viewerRecords.put(rollup.id.substring(0, 15), viewObj);
    }
  }

  private void setCronRecords() {
    for (CronTrigger c : cronRecords) {
      String id = c.CronJobDetail.Name.substringBetween('(', ')');
      if (viewerRecords.containsKey(id)) {
        viewerRecords.get(id).apexJobName = c.CronJobDetail.Name;
        viewerRecords.get(id).scheduledTime = c.CronExpression;
        viewerRecords.get(id).jobFiredCount = c.TimesTriggered;
      }
    }
  }

  //Getter and Setter required for Visualforce page
  public class ViewerObject {
    public string recordId { get; set; }
    public string label { get; set; }
    public string calcMode { get; set; }

    public string scheduledTime { get; set; }
    public Integer jobFiredCount { get; set; }
    public string apexJobName { get; set; }
  }
}
