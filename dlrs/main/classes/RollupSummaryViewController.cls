//depends  
public with sharing class RollupSummaryViewController {

  private Map<String, ViewerObject> viewerRecords;
  private List<RollupSummary> rollupRecords;
  private List<CronTrigger> cronRecords;

  private CronTriggersSelector selectorLayerClass;


  public RollupSummaryViewController() {
    this(new CronTriggersSelector());
  }

  @TestVisible
  private RollupSummaryViewController(CronTriggersSelector cronSelector){
    this.selectorLayerClass = cronSelector;

  }

  //Visualforce page needs access to this method
  public pagereference redirect() {
    PageReference redirectPageWithId = Page.managelookuprollupsummaries;
    redirectPageWithId.setRedirect(true);
    redirectPageWithId.getParameters().put('id', Apexpages.currentPage().getParameters().get('newid').escapeHtml4() );

    return redirectPageWithId;
  }

  //visualforce page needs access to this method
  //defers data initialization until method is called in VF page
  public List<ViewerObject> getView() {
    setupData();
    //if no rollups then impossible to have scheduled jobs attached to them.
    if (rollupRecords.isEmpty()) {
      return null;
    }
    setRollupRecords();
    setCronRecords();
    return viewerRecords.values();
  }

  //setup instance varaibles with SOQL data
  private void setupData(){
    rollupRecords = new RollupSummariesSelector.CustomMetadataSelector(false,false).selectAll();
    CronRecords = selectorLayerClass.selectAllScheduledApex();
    viewerRecords = new Map<String, ViewerObject>();

  }

  //Can be expanded for more rollup fields as part of a feature
  private void setRollupRecords() {
    for (RollupSummary rollup : rollupRecords) {
      ViewerObject viewObj = new ViewerObject();
      viewObj.label = rollup.UniqueName;
      viewObj.calcMode = rollup.CalculationMode;
      viewObj.RecordId = rollup.id;
      viewerRecords.put(rollup.id.substring(0, 15), viewObj);
    }
  }

  //can be expanded with more cronTrigger fields as a feature expansion
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
  //Can add more fields as a feature expansion
  public class ViewerObject {
    public string recordId { get; set; }
    public string label { get; set; }
    public string calcMode { get; set; }

    public string scheduledTime { get; set; }
    public Integer jobFiredCount { get; set; }
    public Datetime endtime { get; set; }
    public string apexJobName { get; set; }
  }
}
