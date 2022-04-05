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
  }

  /**
   * Returns all rollups for the given Id set (can contain either Custom Metadata Id' or DeveloperName's)
   **/
  public List<RollupSummary> selectById(Set<String> idSet) {
    List<RollupSummary> records = new List<RollupSummary>();
    records = m_customObjectSelector.selectById(idSet);
    records.addAll(m_customMetadataSelector.selectById(idSet));
    records.addAll(m_customMetadataSelector.selectByDeveloperName(idSet));
    return records;
  }

  /**
   * Returns active lookup rollup summary definitions for thr given calculation mode and child object
   **/
  public List<RollupSummary> selectActiveByChildObject(
    RollupSummaries.CalculationMode calculationMode,
    Set<String> childObjectNames
  ) {
    List<RollupSummary> records = new List<RollupSummary>();
    records = m_customObjectSelector.selectActiveByChildObject(
      calculationMode,
      childObjectNames
    );
    records.addAll(
      m_customMetadataSelector.selectActiveByChildObject(
        calculationMode,
        childObjectNames
      )
    );
    return records;
  }

  /**
   * Returns active lookup rollup summary definitions for thr given calculation modes and child object
   **/
  public List<RollupSummary> selectActiveByChildObject(
    List<RollupSummaries.CalculationMode> calculationModes,
    Set<String> childObjectNames
  ) {
    List<RollupSummary> records = new List<RollupSummary>();
    records = m_customObjectSelector.selectActiveByChildObject(
      calculationModes,
      childObjectNames
    );
    records.addAll(
      m_customMetadataSelector.selectActiveByChildObject(
        calculationModes,
        childObjectNames
      )
    );
    return records;
  }

  /**
   * Returns active lookup rollup summary definitions for the given rollup unique names
   **/
  public List<RollupSummary> selectActiveByUniqueName(Set<String> uniqueNames) {
    List<RollupSummary> records = new List<RollupSummary>();
    records = m_customObjectSelector.selectActiveByUniqueName(uniqueNames);
    records.addAll(
      m_customMetadataSelector.selectActiveByUniqueName(uniqueNames)
    );
    return records;
  }

  /**
   * Returns lookup rollup summary definitions for all fields
   **/
  public List<RollupSummary> selectAll() {
    List<RollupSummary> records = new List<RollupSummary>();
    records = m_customMetadataSelector.selectAll();
    records.addAll(m_customObjectSelector.selectAll());

    return records;
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

    public List<RollupSummary> selectById(Set<String> idSet) {
      Set<Id> recordIds = new Set<Id>();
      for (String idAsString : idSet)
        recordIds.add((Id) idAsString);
      return RollupSummary.toList(selectSObjectsById(recordIds));
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
      List<String> calculationModeNames = new List<String>();
      for (RollupSummaries.CalculationMode calculationMode : calculationModes)
        calculationModeNames.add(calculationMode.name());
      return RollupSummary.toList(
        Database.query(
          newQueryFactory()
            .setCondition(
              'CalculationMode__c in :calculationModeNames and ChildObject__c in :childObjectNames and Active__c = true'
            )
            .addOrdering(
              LookupRollupSummary__c.ParentObject__c,
              fflib_QueryFactory.SortOrder.ASCENDING
            )
            .addOrdering(
              LookupRollupSummary__c.RelationshipField__c,
              fflib_QueryFactory.SortOrder.ASCENDING
            )
            .toSOQL()
        )
      );
    }

    /**
     * Returns active lookup rollup summary definitions for the given rollup unique names
     **/
    public List<RollupSummary> selectActiveByUniqueName(
      Set<String> uniqueNames
    ) {
      return RollupSummary.toList(
        Database.query(
          newQueryFactory()
            .setCondition('UniqueName__c in :uniqueNames and Active__c = true')
            .addOrdering(
              LookupRollupSummary__c.ParentObject__c,
              fflib_QueryFactory.SortOrder.ASCENDING
            )
            .addOrdering(
              LookupRollupSummary__c.RelationshipField__c,
              fflib_QueryFactory.SortOrder.ASCENDING
            )
            .toSOQL()
        )
      );
    }

    /**
     * Returns lookup rollup summary definitions for the given rollup unique names
     **/
    public List<RollupSummary> selectByUniqueName(Set<String> uniqueNames) {
      return RollupSummary.toList(
        Database.query(
          newQueryFactory()
            .setCondition('UniqueName__c in :uniqueNames')
            .addOrdering(
              LookupRollupSummary__c.ParentObject__c,
              fflib_QueryFactory.SortOrder.ASCENDING
            )
            .addOrdering(
              LookupRollupSummary__c.RelationshipField__c,
              fflib_QueryFactory.SortOrder.ASCENDING
            )
            .toSOQL()
        )
      );
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
      List<String> calculationModeNames = new List<String>();
      for (RollupSummaries.CalculationMode calculationMode : calculationModes)
        calculationModeNames.add(calculationMode.name());
      if (this.forEdit) {
        return RollupSummary.toList(
          this.getLookupRollupSummariesWithParameters(
            newQueryFactory()
              .setCondition(
                'CalculationMode__c in :tmpVar1 and ChildObject__c in :tmpVar2 and Active__c = true'
              )
              .addOrdering(
                LookupRollupSummary2__mdt.ParentObject__c,
                fflib_QueryFactory.SortOrder.ASCENDING
              )
              .addOrdering(
                LookupRollupSummary2__mdt.RelationshipField__c,
                fflib_QueryFactory.SortOrder.ASCENDING
              )
              .toSOQL(),
            new List<Object>{ calculationModeNames, childObjectNames }
          )
        );
      } else {
        List<RollupSummary> summaries = RollupSummary.toList(
          this.getLookupRollupSummaries()
        );

        List<RollupSummary> filteredSummaries = new List<RollupSummary>();

        for (RollupSummary summary : summaries) {
          if (
            summary != null &&
            summary.Active &&
            calculationModeNames.contains(summary.CalculationMode) &&
            childObjectNames.contains(summary.ChildObject)
          ) {
            filteredSummaries.add(summary);
          }
        }

        return sortSummaries(
          filteredSummaries,
          'ParentObject__c',
          'RelationshipField__c'
        );
      }
    }

    /**
     * Returns active lookup rollup summary definitions for the given rollup unique names
     **/
    public List<RollupSummary> selectActiveByUniqueName(
      Set<String> uniqueNames
    ) {
      if (this.forEdit) {
        return RollupSummary.toList(
          this.getLookupRollupSummariesWithParameters(
            newQueryFactory()
              .setCondition('DeveloperName in :tmpVar1 and Active__c = true')
              .addOrdering(
                LookupRollupSummary2__mdt.ParentObject__c,
                fflib_QueryFactory.SortOrder.ASCENDING
              )
              .addOrdering(
                LookupRollupSummary2__mdt.RelationshipField__c,
                fflib_QueryFactory.SortOrder.ASCENDING
              )
              .toSOQL(),
            new List<Object>{ uniqueNames }
          )
        );
      } else {
        List<RollupSummary> summaries = new List<RollupSummary>();
        List<SObject> records = new List<SObject>();
        for (String uniqueName : uniqueNames) {
          SObject record = getLookupRollupSummaryByDeveloperNameOrId(
            uniqueName
          );
          if (record != null && (Boolean) record.get('Active__c')) {
            records.add(record);
          }
        }

        return sortSummaries(
          RollupSummary.toList(records),
          'ParentObject__c',
          'RelationshipField__c'
        );
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

    private List<RollupSummary> sortSummaries(
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
