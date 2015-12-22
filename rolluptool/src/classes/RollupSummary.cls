/**
 * Copyright (c), Andrew Fawcett
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
 * Wrapper class abstracts away from the underlying storage approached used for the rollup
 *
 *   TODO: I may implement this in due course differently, to use a small factory pattern and
 *         leverage explicit references to the Custom Object or Custom Metadata fields, likely 
 *         faster and also ensures the compiler is aware of the references
 **/
public class RollupSummary {

	public SObject Record {get; private set;}

	public RollupSummary(SObject record) {
		this.Record = record;	
	}

	public String Id { 
		get { return (String) Record.get('Id'); } 
	}

	public String Name { 
		get { return (String) Record.get('Name'); } 
		set { Record.put('Name', value); } 
	}

	public Boolean Active { 
		get { return (Boolean) Record.get('Active__c'); }
		set { Record.put('Active__c', value); } 
	}

	public String AggregateOperation {
		get { return (String) Record.get('AggregateOperation__c'); }
		set { Record.put('AggregateOperation__c', value); } 
	}

	public String AggregateResultField {
		get { return (String) Record.get('AggregateResultField__c'); }
		set { Record.put('AggregateResultField__c', value); } 
	}

	public String CalculationMode {
		get { return (String) Record.get('CalculationMode__c'); }
		set { Record.put('CalculationMode__c', value); } 
	}

	public String CalculationSharingMode {
		get { return (String) Record.get('CalculationSharingMode__c'); }
		set { Record.put('CalculationSharingMode__c', value); } 
	}
	
	public String ChildObject {
		get { return (String) Record.get('ChildObject__c'); }
		set { Record.put('ChildObject__c', value); } 
	}
	
	public String ConcatenateDelimiter {
		get { return (String) Record.get('ConcatenateDelimiter__c'); }
		set { Record.put('ConcatenateDelimiter__c', value); } 
	}
	
	public String Description {
		get { return (String) Record.get('Description__c'); }
		set { Record.put('Description__c', value); } 
	}
	
	public String FieldToAggregate {
		get { return (String) Record.get('FieldToAggregate__c'); }
		set { Record.put('FieldToAggregate__c', value); } 
	}
	
	public String FieldToOrderBy {
		get { return (String) Record.get('FieldToOrderBy__c'); }
		set { Record.put('FieldToOrderBy__c', value); } 
	}
	
	public String UniqueName {
		get { return (String) Record.get('UniqueName__c'); }
		set { Record.put('UniqueName__c', value); } 
	}
	
	public String ParentObject {
		get { return (String) Record.get('ParentObject__c'); }
		set { Record.put('ParentObject__c', value); } 
	}
	
	public String RelationshipCriteria {
		get { return (String) Record.get('RelationshipCriteria__c'); }
		set { Record.put('RelationshipCriteria__c', value); } 
	}
	
	public String RelationshipCriteriaFields {
		get { return (String) Record.get('RelationshipCriteriaFields__c'); }
		set { Record.put('RelationshipCriteriaFields__c', value); } 
	}
	
	public String RelationshipField {
		get { return (String) Record.get('RelationshipField__c'); }
		set { Record.put('RelationshipField__c', value); } 
	}
	
	public String TestCode {
		get { return (String) Record.get('TestCode__c'); }
		set { Record.put('TestCode__c', value); } 
	}
	
	public Boolean TestCodeSeeAllData {
		get { return (Boolean) Record.get('TestCodeSeeAllData__c'); }
		set { Record.put('TestCodeSeeAllData__c', value); } 
	}

	public Boolean equals(Object obj) {
		return Record == obj;
	}

	public Integer hashCode() {
		return System.hashCode(Record);
	}

	public static List<RollupSummary> toList(List<SObject> records) {
		List<RollupSummary> summaries = new List<RollupSummary>();
		for(SObject record : records) {
			summaries.add(new RollupSummary(record));
		}
		return summaries;
	}

	public static Map<String, RollupSummary> toMap(List<RollupSummary> records) {
		Map<String, RollupSummary> summariesById = new Map<String, RollupSummary>();
		for(RollupSummary record : records) {
			summariesById.put(record.Id, record);
		}
		return summariesById;
	}
}