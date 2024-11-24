/**
 * Copyright (c) 2013, Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

/**
 * Various queries for the Lookup Rollup Summary custom object and cusotm metadata object
 **/
public class RollupSummariesSelector {
  @TestVisible
  private CustomObjectSelector m_customObjectSelector;

  @TestVisible
  private CustomMetadataSelector m_customMetadataSelector;

  private static Map<String, List<RollupSummary>> summariesCacheByKey = new Map<String, List<RollupSummary>>();

  private List<RollupSummary> allSummaries;

  public static void clearRollupCache() {
    summariesCacheByKey = new Map<String, List<RollupSummary>>();
  }

  @TestVisible
  private static void setRollupCache(
    Boolean enforceSecurity,
    Boolean forEdit,
    List<RollupSummary> rollups
  ) {
    String cacheKey = getCacheKey(enforceSecurity, forEdit);
    summariesCacheByKey.put(cacheKey, rollups);
  }

  private static List<RollupSummary> getRollupsFromCache(
    Boolean enforceSecurity,
    Boolean forEdit
  ) {
    String cacheKey = getCacheKey(enforceSecurity, forEdit);
    return summariesCacheByKey.get(cacheKey);
  }

  public RollupSummariesSelector() {
    this(false, false);
  }

  public RollupSummariesSelector(boolean enforceSecurity) {
    this(enforceSecurity, false);
  }

  public RollupSummariesSelector(boolean enforceSecurity, boolean forEdit) {
    // Dual selectors for querying custom object and custom metadata stores
    m_customObjectSelector = new CustomObjectSelector(enforceSecurity, forEdit);
    m_customMetadataSelector = new CustomMetadataSelector(
      enforceSecurity,
      forEdit
    );

    this.allSummaries = getRollupsFromCache(enforceSecurity, forEdit);

    if (allSummaries == null) {
      this.allSummaries = new List<RollupSummary>();
      // build summaries cache
      // Dual selectors for querying custom object and custom metadata stores
      // Build the cache of data
      this.allSummaries.addAll(m_customObjectSelector.selectAll());
      this.allSummaries.addAll(m_customMetadataSelector.selectAll());

      setRollupCache(enforceSecurity, forEdit, this.allSummaries);
    }
  }

  private static String getCacheKey(boolean enforceSecurity, boolean forEdit) {
    return String.format(
      '{0}|{1}',
      new List<String>{
        enforceSecurity ? 'withSecurityEnforced' : 'withoutSecurityEnforced',
        forEdit ? 'forEdit' : 'forRead'
      }
    );
  }

  /**
   * Returns all rollups for the given Id set (can contain either Custom Metadata Ids or DeveloperNames)
   **/
  public List<RollupSummary> selectById(Set<String> idSet) {
    List<RollupSummary> records = new List<RollupSummary>();
    for (RollupSummary rs : this.allSummaries) {
      // case ignore on the 18 but case match on the 15
      if (
        containsIgnoreCase(idset, rs.Id) ||
        idset.contains(rs.Id.left(15)) ||
        containsIgnoreCase(idSet, rs.UniqueName)
      ) {
        records.add(rs);
      }
    }
    return records;
  }

  /**
   * Returns active lookup rollup summary definitions for thr given calculation mode and child object
   **/
  public List<RollupSummary> selectActiveByChildObject(
    RollupSummaries.CalculationMode calculationMode,
    Set<String> childObjectNames
  ) {
    return selectActiveByChildObject(
      new List<RollupSummaries.CalculationMode>{ calculationMode },
      childObjectNames
    );
  }

  /**
   * Returns active lookup rollup summary definitions for thr given calculation modes and child object
   **/
  public List<RollupSummary> selectActiveByChildObject(
    List<RollupSummaries.CalculationMode> calculationModes,
    Set<String> childObjectNames
  ) {
    List<String> rollupSummaryNames = new List<String>();
    for (RollupSummaries.CalculationMode cm : calculationModes) {
      rollupSummaryNames.add(cm.name());
    }
    List<RollupSummary> records = new List<RollupSummary>();
    for (RollupSummary rs : this.allSummaries) {
      if (
        rs.Active &&
        containsIgnoreCase(childObjectNames, rs.ChildObject) &&
        containsIgnoreCase(rollupSummaryNames, rs.CalculationMode)
      ) {
        records.add(rs);
      }
    }
    return sortSummaries(records, 'ParentObject__c', 'RelationshipField__c');
  }

  /**
   * Returns active lookup rollup summary definitions for the given rollup unique names
   **/
  public List<RollupSummary> selectActiveByUniqueName(Set<String> uniqueNames) {
    List<RollupSummary> records = new List<RollupSummary>();
    for (RollupSummary rs : selectByUniqueName(uniqueNames)) {
      if (rs.Active) {
        records.add(rs);
      }
    }
    return records;
  }

  /**
   * Returns active lookup rollup summary definitions for the given rollup unique names
   **/
  public List<RollupSummary> selectByUniqueName(Set<String> uniqueNames) {
    List<RollupSummary> records = new List<RollupSummary>();
    for (RollupSummary rs : this.allSummaries) {
      if (containsIgnoreCase(uniqueNames, rs.UniqueName)) {
        records.add(rs);
      }
    }
    return sortSummaries(records, 'ParentObject__c', 'RelationshipField__c');
  }

  /**
   * Returns lookup rollup summary definitions for all fields
   **/
  public List<RollupSummary> selectAll() {
    return this.allSummaries;
  }

  private Boolean containsIgnoreCase(Iterable<String> collection, String val) {
    if (collection == null) {
      return false;
    }
    Iterator<string> i = collection.iterator();
    while (i.hasNext()) {
      String s = i.next();
      if (val == null) {
        if (s == null) {
          return true;
        }
        continue;
      }
      if (val.equalsIgnoreCase(s)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Queries Custom Object store for rollups
   **/
  public class CustomObjectSelector extends fflib_SObjectSelector {
    public CustomObjectSelector(boolean enforceSecurity) {
      this(enforceSecurity, false);
    }

    public CustomObjectSelector(boolean enforceSecurity, boolean forEdit) {
      super(false, enforceSecurity, enforceSecurity);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
      return new List<Schema.SObjectField>{
        LookupRollupSummary__c.Name,
        LookupRollupSummary__c.Active__c,
        LookupRollupSummary__c.AggregateOperation__c,
        LookupRollupSummary__c.AggregateResultField__c,
        LookupRollupSummary__c.CalculationMode__c,
        LookupRollupSummary__c.ChildObject__c,
        LookupRollupSummary__c.ConcatenateDelimiter__c,
        LookupRollupSummary__c.FieldToAggregate__c,
        LookupRollupSummary__c.FieldToOrderBy__c,
        LookupRollupSummary__c.ParentObject__c,
        LookupRollupSummary__c.RelationshipCriteria__c,
        LookupRollupSummary__c.RelationshipCriteriaFields__c,
        LookupRollupSummary__c.RelationshipField__c,
        LookupRollupSummary__c.UniqueName__c,
        LookupRollupSummary__c.CalculationSharingMode__c,
        LookupRollupSummary__c.TestCode__c,
        LookupRollupSummary__c.TestCodeSeeAllData__c,
        LookupRollupSummary__c.AggregateAllRows__c,
        LookupRollupSummary__c.RowLimit__c
      };
    }

    public Schema.SObjectType getSObjectType() {
      return LookupRollupSummary__c.sObjectType;
    }

    /**
     * Select all
     **/
    public List<RollupSummary> selectAll() {
      return RollupSummary.toList(Database.query(newQueryFactory().toSOQL()));
    }
  }

  /**
   * Queries Custom Metadata store for rollups
   **/
  public virtual class CustomMetadataSelector extends fflib_SObjectSelector {
    private boolean forEdit = false;

    public CustomMetadataSelector(boolean enforceSecurity) {
      this(enforceSecurity, false);
    }

    public CustomMetadataSelector(boolean enforceSecurity, boolean forEdit) {
      super(false, enforceSecurity, enforceSecurity);
      this.forEdit = forEdit;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
      List<Schema.SObjectField> selectorFields = new List<Schema.SObjectField>{
        LookupRollupSummary2__mdt.Id,
        LookupRollupSummary2__mdt.Label,
        LookupRollupSummary2__mdt.DeveloperName,
        LookupRollupSummary2__mdt.Active__c,
        LookupRollupSummary2__mdt.AggregateOperation__c,
        LookupRollupSummary2__mdt.AggregateResultField__c,
        LookupRollupSummary2__mdt.BypassPermissionApiName__c,
        LookupRollupSummary2__mdt.CalculationMode__c,
        LookupRollupSummary2__mdt.ChildObject__c,
        LookupRollupSummary2__mdt.ConcatenateDelimiter__c,
        LookupRollupSummary2__mdt.FieldToAggregate__c,
        LookupRollupSummary2__mdt.FieldToOrderBy__c,
        LookupRollupSummary2__mdt.ParentObject__c,
        LookupRollupSummary2__mdt.RelationshipCriteria__c,
        LookupRollupSummary2__mdt.RelationshipCriteriaFields__c,
        LookupRollupSummary2__mdt.RelationshipField__c,
        LookupRollupSummary2__mdt.CalculationSharingMode__c,
        LookupRollupSummary2__mdt.TestCode__c,
        LookupRollupSummary2__mdt.TestCodeSeeAllData__c,
        LookupRollupSummary2__mdt.Description__c,
        LookupRollupSummary2__mdt.AggregateAllRows__c,
        LookupRollupSummary2__mdt.RowLimit__c
      };
      if (forEdit) {
        selectorFields.add(LookupRollupSummary2__mdt.TestCode2__c);
        selectorFields.add(LookupRollupSummary2__mdt.TestCodeParent__c);
      }

      return selectorFields;
    }

    public Schema.SObjectType getSObjectType() {
      return LookupRollupSummary2__mdt.sObjectType;
    }

    public List<RollupSummary> selectById(Set<String> idSet) {
      if (this.forEdit) {
        return RollupSummary.toList(
          this.getLookupRollupSummariesWithParameters(
            newQueryFactory().setCondition('id in :tmpVar1').toSOQL(),
            new List<Object>{ idSet }
          )
        );
      } else {
        List<RollupSummary> summaries = new List<RollupSummary>();
        List<SObject> records = new List<SObject>();
        for (String idVal : idSet) {
          SObject record = this.getLookupRollupSummaryByDeveloperNameOrId(
            idVal
          );
          if (record != null) {
            records.add(record);
          }
        }

        return RollupSummary.toList(records);
      }
    }

    public List<RollupSummary> selectByDeveloperName(
      Set<String> developerNames
    ) {
      String developerName = new List<String>(developerNames)[0];
      if (this.forEdit) {
        return RollupSummary.toList(
          this.getLookupRollupSummariesWithParameters(
            newQueryFactory().setCondition('DeveloperName = :tmpVar1').toSOQL(),
            new List<Object>{ developerName }
          )
        );
      } else {
        List<RollupSummary> summaries = new List<RollupSummary>();
        List<SObject> records = new List<SObject>();
        SObject record = this.getLookupRollupSummaryByDeveloperNameOrId(
          developerName
        );
        if (record != null) {
          records.add(
            this.getLookupRollupSummaryByDeveloperNameOrId(developerName)
          );
        }
        return RollupSummary.toList(records);
      }
    }

    /**
     * Select all
     **/
    public List<RollupSummary> selectAll() {
      if (this.forEdit) {
        return RollupSummary.toList(
          this.getLookupRollupSummariesWithParameters(
            newQueryFactory()
              .addOrdering(
                LookupRollupSummary2__mdt.Label,
                fflib_QueryFactory.SortOrder.ASCENDING
              )
              .toSOQL(),
            new List<Object>()
          )
        );
      } else {
        List<RollupSummary> summaries = RollupSummary.toList(
          this.getLookupRollupSummaries()
        );

        return sortSummaries(summaries, 'Label', null);
      }
    }

    protected virtual List<SObject> getLookupRollupSummariesWithParameters(
      String queryString,
      List<Object> tmpVars
    ) {
      //Executing dynamic SOQL requires any variable binding to be in the same
      //scope. We only ever use 2 variables in this class, so just hard coding
      //two temporary variables for the dynamic SOQL to run
      Object tmpVar1 = tmpVars.size() > 0 ? tmpVars[0] : null;
      Object tmpVar2 = tmpVars.size() > 1 ? tmpVars[1] : null;

      return Database.query(queryString);
    }

    protected virtual List<SObject> getLookupRollupSummaries() {
      return LookupRollupSummary2__mdt.getAll().values();
    }

    protected virtual SObject getLookupRollupSummaryByDeveloperNameOrId(
      String developerNameOrId
    ) {
      return LookupRollupSummary2__mdt.getInstance(developerNameOrId);
    }
  }

  private static List<RollupSummary> sortSummaries(
    List<RollupSummary> summaries,
    String sortField,
    String sortFieldSecondary
  ) {
    List<RollupSummaryComparable> rollupSummaryComparables = new List<RollupSummaryComparable>();
    for (RollupSummary summary : summaries) {
      rollupSummaryComparables.add(
        new RollupSummaryComparable(summary, sortField, sortFieldSecondary)
      );
    }

    rollupSummaryComparables.sort();

    List<RollupSummary> sortedSummaries = new List<RollupSummary>();

    for (RollupSummaryComparable comparable : rollupSummaryComparables) {
      sortedSummaries.add(comparable.summary);
    }

    return sortedSummaries;
  }

  private class RollupSummaryComparable implements Comparable {
    private RollupSummary summary;
    private String fieldToSortOn;
    private String sortOrder;
    private String fieldToSortOnSecondary;

    private RollupSummaryComparable(
      RollupSummary summary,
      String fieldToSortOn,
      String fieldToSortOnSecondary
    ) {
      this.summary = summary;
      this.fieldToSortOn = fieldToSortOn;
      this.fieldToSortOnSecondary = fieldToSortOnSecondary;
    }

    public Integer compareTo(Object compareTo) {
      RollupSummaryComparable compareToSummary = (RollupSummaryComparable) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (
        String.valueOf(this.summary.record.get(this.fieldToSortOn)) >
        String.valueOf(compareToSummary.summary.record.get(this.fieldToSortOn))
      ) {
        // Set return value to a positive value.
        returnValue = 1;
      } else if (
        String.valueOf(this.summary.record.get(this.fieldToSortOn)) <
        String.valueOf(compareToSummary.summary.record.get(this.fieldToSortOn))
      ) {
        // Set return value to a negative value.
        returnValue = -1;
      } else if (this.fieldToSortOnSecondary != null) {
        // First value the same, consider second value
        if (
          String.valueOf(this.summary.record.get(this.fieldToSortOnSecondary)) >
          String.valueOf(
            compareToSummary.summary.record.get(this.fieldToSortOnSecondary)
          )
        ) {
          return 1;
        } else if (
          String.valueOf(this.summary.record.get(this.fieldToSortOnSecondary)) <
          String.valueOf(
            compareToSummary.summary.record.get(this.fieldToSortOnSecondary)
          )
        ) {
          return -1;
        }
      }
      return returnValue;
    }
  }
}
