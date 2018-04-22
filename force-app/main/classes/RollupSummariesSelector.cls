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
public class RollupSummariesSelector
{
	private CustomObjectSelector m_customObjectSelector;

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
		m_customMetadataSelector = new CustomMetadataSelector(enforceSecurity, forEdit);
	}

	/**
	 * Returns all rollups for the given Id set (can contain either Custom Metadata Id' or DeveloperName's)
	 **/
	public List<RollupSummary> selectById(Set<String> idSet)
	{
		List<RollupSummary> records = new List<RollupSummary>();
		records = m_customObjectSelector.selectById(idSet);
		records.addAll(m_customMetadataSelector.selectById(idSet));
		records.addAll(m_customMetadataSelector.selectByDeveloperName(idSet));		
		return records;
	}

	/**
	 * Returns active lookup rollup summary definitions for thr given calculation mode and child object
	 **/
	public List<RollupSummary> selectActiveByChildObject(RollupSummaries.CalculationMode calculationMode, Set<String> childObjectNames)
	{
		List<RollupSummary> records = new List<RollupSummary>();
		records = m_customObjectSelector.selectActiveByChildObject(calculationMode, childObjectNames);
		records.addAll(m_customMetadataSelector.selectActiveByChildObject(calculationMode, childObjectNames));
		return records;
	}
	
	/**
	 * Returns active lookup rollup summary definitions for thr given calculation modes and child object
	 **/
	public List<RollupSummary> selectActiveByChildObject(List<RollupSummaries.CalculationMode> calculationModes, Set<String> childObjectNames)
	{
		List<RollupSummary> records = new List<RollupSummary>();
		records = m_customObjectSelector.selectActiveByChildObject(calculationModes, childObjectNames);
		records.addAll(m_customMetadataSelector.selectActiveByChildObject(calculationModes, childObjectNames));
		return records;
	}

	/**
	 * Returns active lookup rollup summary definitions for the given rollup unique names
	 **/
	public List<RollupSummary> selectActiveByUniqueName(Set<String> uniqueNames)
	{
		List<RollupSummary> records = new List<RollupSummary>();
		records = m_customObjectSelector.selectActiveByUniqueName(uniqueNames);
		records.addAll(m_customMetadataSelector.selectActiveByUniqueName(uniqueNames));
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

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return new List<Schema.SObjectField> {
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

		public Schema.SObjectType getSObjectType()
		{
			return LookupRollupSummary__c.sObjectType;
		}

		public List<RollupSummary> selectById(Set<String> idSet)
		{
			Set<Id> recordIds = new Set<Id>();
			for(String idAsString : idSet)
				recordIds.add((Id)idAsString);
			return RollupSummary.toList(selectSObjectsById(recordIds));
		}

		/**
		 * Returns active lookup rollup summary definitions for thr given calculation mode and child object
		 **/
		public List<RollupSummary> selectActiveByChildObject(RollupSummaries.CalculationMode calculationMode, Set<String> childObjectNames)
		{
			return selectActiveByChildObject(new List<RollupSummaries.CalculationMode> { calculationMode }, childObjectNames);
		}
		
		/**
		 * Returns active lookup rollup summary definitions for thr given calculation modes and child object
		 **/
		public List<RollupSummary> selectActiveByChildObject(List<RollupSummaries.CalculationMode> calculationModes, Set<String> childObjectNames)
		{
			List<String> calculationModeNames = new List<String>();
			for(RollupSummaries.CalculationMode calculationMode : calculationModes)
				calculationModeNames.add(calculationMode.name());
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().
						setCondition('CalculationMode__c in :calculationModeNames and ChildObject__c in :childObjectNames and Active__c = true').
					 	addOrdering(LookupRollupSummary__c.ParentObject__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	addOrdering(LookupRollupSummary__c.RelationshipField__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	toSOQL()));
		}

		/**
		 * Returns active lookup rollup summary definitions for the given rollup unique names
		 **/
		public List<RollupSummary> selectActiveByUniqueName(Set<String> uniqueNames)
		{
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().
						setCondition('UniqueName__c in :uniqueNames and Active__c = true').
					 	addOrdering(LookupRollupSummary__c.ParentObject__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	addOrdering(LookupRollupSummary__c.RelationshipField__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	toSOQL()));
		}

		/**
		 * Returns lookup rollup summary definitions for the given rollup unique names
		 **/
		public List<RollupSummary> selectByUniqueName(Set<String> uniqueNames)
		{
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().
						setCondition('UniqueName__c in :uniqueNames').
					 	addOrdering(LookupRollupSummary__c.ParentObject__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	addOrdering(LookupRollupSummary__c.RelationshipField__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	toSOQL()));
		}
	}

	/**
	 * Queries Custom Metadata store for rollups
	 **/
	public class CustomMetadataSelector extends fflib_SObjectSelector {

		private boolean forEdit = false;

		public CustomMetadataSelector(boolean enforceSecurity) {
			this(enforceSecurity, false);
		}

		public CustomMetadataSelector(boolean enforceSecurity, boolean forEdit) {
			super(false, enforceSecurity, enforceSecurity);
			this.forEdit = forEdit;
		}

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			List<Schema.SObjectField> selectorFields = 
				new List<Schema.SObjectField> {
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
			if(forEdit) {
				selectorFields.add(LookupRollupSummary2__mdt.TestCode2__c);				
				selectorFields.add(LookupRollupSummary2__mdt.TestCodeParent__c);
			}
			return selectorFields;
		}

		public Schema.SObjectType getSObjectType()
		{
			return LookupRollupSummary2__mdt.sObjectType;
		}

		public List<RollupSummary> selectById(Set<String> idSet)
		{
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().setCondition('id in :idSet').toSOQL()));
		}

		public List<RollupSummary> selectByDeveloperName(Set<String> idSet)
		{
			String developerName = new List<String>(idSet)[0];
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().setCondition('DeveloperName = :developerName').toSOQL()));
		}

		/**
		 * Returns active lookup rollup summary definitions for thr given calculation mode and child object
		 **/
		public List<RollupSummary> selectActiveByChildObject(RollupSummaries.CalculationMode calculationMode, Set<String> childObjectNames)
		{
			return selectActiveByChildObject(new List<RollupSummaries.CalculationMode> { calculationMode }, childObjectNames);
		}
		
		/**
		 * Returns active lookup rollup summary definitions for thr given calculation modes and child object
		 **/
		public List<RollupSummary> selectActiveByChildObject(List<RollupSummaries.CalculationMode> calculationModes, Set<String> childObjectNames)
		{
			List<String> calculationModeNames = new List<String>();
			for(RollupSummaries.CalculationMode calculationMode : calculationModes)
				calculationModeNames.add(calculationMode.name());
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().
						setCondition('CalculationMode__c in :calculationModeNames and ChildObject__c in :childObjectNames and Active__c = true').
					 	addOrdering(LookupRollupSummary2__mdt.ParentObject__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	addOrdering(LookupRollupSummary2__mdt.RelationshipField__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	toSOQL()));
		}

		/**
		 * Returns active lookup rollup summary definitions for the given rollup unique names
		 **/
		public List<RollupSummary> selectActiveByUniqueName(Set<String> uniqueNames)
		{
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().
						setCondition('DeveloperName in :uniqueNames and Active__c = true').
					 	addOrdering(LookupRollupSummary2__mdt.ParentObject__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	addOrdering(LookupRollupSummary2__mdt.RelationshipField__c, fflib_QueryFactory.SortOrder.ASCENDING).
					 	toSOQL()));
		}

		/**
		 * Select all
		 **/
		public List<RollupSummary> selectAll()
		{
			return RollupSummary.toList(
				Database.query(
					newQueryFactory().
					 	addOrdering(LookupRollupSummary2__mdt.Label, fflib_QueryFactory.SortOrder.ASCENDING).
					 	toSOQL()));
		}
	}	
}