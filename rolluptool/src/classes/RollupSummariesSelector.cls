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
 * - Neither the name of the Andrew Fawcett, inc nor the names of its contributors 
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
 * Various queries for the Lookup Rollup Summary custom object
 **/
public with sharing class RollupSummariesSelector extends SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			LookupRollupSummary__c.Name,
			LookupRollupSummary__c.Active__c,
			LookupRollupSummary__c.AggregateOperation__c,
			LookupRollupSummary__c.AggregateResultField__c,
			LookupRollupSummary__c.CalculationMode__c,
			LookupRollupSummary__c.ChildObject__c,
			LookupRollupSummary__c.FieldToAggregate__c,
			LookupRollupSummary__c.ParentObject__c,
			LookupRollupSummary__c.RelationshipCriteria__c,
			LookupRollupSummary__c.RelationshipField__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return LookupRollupSummary__c.sObjectType;
	}

	public List<LookupRollupSummary__c> selectById(Set<ID> idSet)
	{
		return (List<LookupRollupSummary__c>) selectSObjectsById(idSet);
	}

	/**
	 * Returns active lookup rollup summary definitions for thr given calculation mode and child object
	 **/
	public List<LookupRollupSummary__c> selectActiveByChildObject(RollupSummaries.CalculationMode calculationMode, Set<String> childObjectNames)
	{
		assertIsAccessible();
		String calculationModeName = calculationMode.name();
		return Database.query(String.format(
			'select {0} from {1} where CalculationMode__c = :calculationModeName and ChildObject__c in :childObjectNames and Active__c = true order by ParentObject__c, RelationshipField__c', 
				new List<String>{getFieldListString(),
					getSObjectName(),
					getOrderBy()}));		
	}
}