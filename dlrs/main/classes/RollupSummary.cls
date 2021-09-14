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
 * Wrapper class abstracts away from the underlying storage approached used for the rollup, this allows
 *   for the tools domain and service layer logic to work regardless of how the rollup summary is stored
 *
 *   TODO: I may implement this in due course differently, to use a small factory pattern and
 *         leverage explicit references to the Custom Object or Custom Metadata fields, likely 
 *         faster and also ensures the compiler is aware of the references
 **/
public class RollupSummary {

	/**
	 * Provides access to the wrapped SObject 
	 **/
	public SObject Record {get; private set;}

	/**
	 * Provides a means to log field level errors against the wrapped record
	 **/
	public RecordMetadata Fields {get; private set;}

	/**
	 * Record level error message
	 **/
	public String Error {get; private set;}

	/**
	 * Wraps the given LookupRollupSummary__c or LookupRollupSummary2__c
	 **/
	public RollupSummary(SObject record) {
		this.Record = migrate(record);
		this.Fields = new RecordMetadata(this);
	}

	public String Id { 
		get { return (String) Record.get('Id'); } 
	}

	public String Name { 
		get { return (String) Record.get(Record instanceof LookupRollupSummary__c ? 'Name' : 'Label'); } 
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
		get { return (String) Record.get(Record instanceof LookupRollupSummary__c ? 'UniqueName__c' : 'DeveloperName'); }
		set { Record.put(Record instanceof LookupRollupSummary__c ? 'UniqueName__c' : 'DeveloperName', value); } 
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
		get { return (String) Record.get(Record instanceof LookupRollupSummary2__mdt ? 'TestCode2__c' : 'TestCode__c'); }
		set { Record.put(Record instanceof LookupRollupSummary2__mdt ? 'TestCode2__c' : 'TestCode__c', value); } 
	}
	
	public String TestCodeParent {
		get { if (Record instanceof LookupRollupSummary2__mdt) { return (String) Record.get('TestCodeParent__c'); } else { return null; } }
		set { if (Record instanceof LookupRollupSummary2__mdt) { Record.put('TestCodeParent__c', value); } } 
	}
	
	public Boolean TestCodeSeeAllData {
		get { return (Boolean) Record.get('TestCodeSeeAllData__c'); }
		set { Record.put('TestCodeSeeAllData__c', value); } 
	}

	public Boolean AggregateAllRows {
		get { return (Boolean) Record.get('AggregateAllRows__c'); }
		set { Record.put('AggregateAllRows__c', value); }
	}

	public Decimal RowLimit {
		get { return (Decimal) Record.get('RowLimit__c'); }
		set { Record.put('RowLimit__c', value); }
	}

	public void addError(String errorMessage) {

		// Store the error message
		Error = errorMessage;

		// For Custom Object backed Rollup Summaries utilise SObject.addError
		if(Record instanceof LookupRollupSummary__c) {
			LookupRollupSummary__c rollupSummaryRecord = (LookupRollupSummary__c) Record;
			rollupSummaryRecord.addError(errorMessage);
		}
	}

	public Boolean equals(Object obj) {
		return Record == obj;
	}

	public Integer hashCode() {
		return System.hashCode(Record);
	}

	/**
	 * Class exposes type safe instances of FieldData to capture errors
	 **/
	public class RecordMetadata {

		public RollupSummary RollupSummary {get; private set;}

		public List<String> Errors {get; private set;}

		private RecordMetadata(RollupSummary rollupSummary) {
			this.RollupSummary = rollupSummary;
			this.Errors = new List<String>();
		}

		public final FieldData Active = new FieldData(this);
		public final FieldData AggregateOperation = new FieldData(this);
		public final FieldData AggregateResultField = new FieldData(this);
		public final FieldData CalculationMode = new FieldData(this);
		public final FieldData CalculationSharingMode = new FieldData(this);
		public final FieldData ChildObject = new FieldData(this);
		public final FieldData ConcatenateDelimiter = new FieldData(this);
		public final FieldData Description = new FieldData(this);
		public final FieldData FieldToAggregate = new FieldData(this);
		public final FieldData FieldToOrderBy = new FieldData(this);
		public final FieldData UniqueName = new FieldData(this);
		public final FieldData ParentObject = new FieldData(this);
		public final FieldData RelationshipCriteria = new FieldData(this);
		public final FieldData RelationshipCriteriaFields = new FieldData(this);
		public final FieldData RelationshipField = new FieldData(this);
		public final FieldData TestCode = new FieldData(this);
		public final FieldData TestCodeSeeAllData = new FieldData(this);
		public final FieldData AggregateAllRows = new FieldData(this);
		public final FieldData RowLimit = new FieldData(this);
	}

	/**
	 * Class provides a wrapper around a given record field data, error messages
	 **/
	public class FieldData {

		public RecordMetadata RecordMetadata {get; private set;}

		public FieldData(RecordMetadata recordMetadata) {
			this.RecordMetadata = recordMetadata;
		}

		public void addError(String errorMessage) {

			// Field in error?
			String fieldLabelInError;
			if(this === RecordMetadata.Active) {
				fieldLabelInError = LookupRollupSummary__c.Active__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.AggregateOperation) {
				fieldLabelInError = LookupRollupSummary__c.AggregateOperation__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.AggregateResultField) {
				fieldLabelInError = LookupRollupSummary__c.AggregateResultField__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.CalculationMode) {
				fieldLabelInError = LookupRollupSummary__c.CalculationMode__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.CalculationSharingMode) {
				fieldLabelInError = LookupRollupSummary__c.CalculationSharingMode__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.ChildObject) {
				fieldLabelInError = LookupRollupSummary__c.ChildObject__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.ConcatenateDelimiter) {
				fieldLabelInError = LookupRollupSummary__c.ConcatenateDelimiter__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.Description) {
				fieldLabelInError = LookupRollupSummary__c.Description__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.FieldToAggregate) {
				fieldLabelInError = LookupRollupSummary__c.FieldToAggregate__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.FieldToOrderBy) {
				fieldLabelInError = LookupRollupSummary__c.FieldToOrderBy__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.UniqueName) {
				fieldLabelInError = LookupRollupSummary__c.UniqueName__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.ParentObject) {
				fieldLabelInError = LookupRollupSummary__c.ParentObject__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.RelationshipCriteria) {
				fieldLabelInError = LookupRollupSummary__c.RelationshipCriteria__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.RelationshipCriteriaFields) {
				fieldLabelInError = LookupRollupSummary__c.RelationshipCriteriaFields__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.RelationshipField) {
				fieldLabelInError = LookupRollupSummary__c.RelationshipField__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.TestCode) {
				fieldLabelInError = LookupRollupSummary__c.TestCode__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.TestCodeSeeAllData) {
				fieldLabelInError = LookupRollupSummary__c.TestCodeSeeAllData__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.AggregateAllRows) {
				fieldLabelInError = LookupRollupSummary__c.AggregateAllRows__c.getDescribe().getLabel();
			} else if(this === RecordMetadata.RowLimit) {
				fieldLabelInError = LookupRollupSummary__c.RowLimit__c.getDescribe().getLabel();
			}				

			// Store error
			RecordMetadata.Errors.add(fieldLabelInError + ': ' + errorMessage);			

			// For Custom Object backed Rollup Summaries utilise SObject.addError
			if(RecordMetadata.RollupSummary.Record instanceof LookupRollupSummary__c) {
				LookupRollupSummary__c customObjectRecord = 
					(LookupRollupSummary__c) RecordMetadata.RollupSummary.Record;
				// Route the error accordingly
				if(this === RecordMetadata.Active) {
					customObjectRecord.Active__c.addError(errorMessage);
					fieldLabelInError = LookupRollupSummary__c.Active__c.getDescribe().getLabel();
				} else if(this === RecordMetadata.AggregateOperation) {
					customObjectRecord.AggregateOperation__c.addError(errorMessage);
				} else if(this === RecordMetadata.AggregateResultField) {
					customObjectRecord.AggregateResultField__c.addError(errorMessage);
				} else if(this === RecordMetadata.CalculationMode) {
					customObjectRecord.CalculationMode__c.addError(errorMessage);
				} else if(this === RecordMetadata.CalculationSharingMode) {
					customObjectRecord.CalculationSharingMode__c.addError(errorMessage);
				} else if(this === RecordMetadata.ChildObject) {
					customObjectRecord.ChildObject__c.addError(errorMessage);
				} else if(this === RecordMetadata.ConcatenateDelimiter) {
					customObjectRecord.ConcatenateDelimiter__c.addError(errorMessage);
				} else if(this === RecordMetadata.Description) {
					customObjectRecord.Description__c.addError(errorMessage);
				} else if(this === RecordMetadata.FieldToAggregate) {
					customObjectRecord.FieldToAggregate__c.addError(errorMessage);
				} else if(this === RecordMetadata.FieldToOrderBy) {
					customObjectRecord.FieldToOrderBy__c.addError(errorMessage);
				} else if(this === RecordMetadata.UniqueName) {
					customObjectRecord.UniqueName__c.addError(errorMessage);
				} else if(this === RecordMetadata.ParentObject) {
					customObjectRecord.ParentObject__c.addError(errorMessage);
				} else if(this === RecordMetadata.RelationshipCriteria) {
					customObjectRecord.RelationshipCriteria__c.addError(errorMessage);
				} else if(this === RecordMetadata.RelationshipCriteriaFields) {
					customObjectRecord.RelationshipCriteriaFields__c.addError(errorMessage);
				} else if(this === RecordMetadata.RelationshipField) {
					customObjectRecord.RelationshipField__c.addError(errorMessage);
				} else if(this === RecordMetadata.TestCode) {
					customObjectRecord.TestCode__c.addError(errorMessage);
				} else if(this === RecordMetadata.TestCodeSeeAllData) {
					customObjectRecord.TestCodeSeeAllData__c.addError(errorMessage);
				} else if(this === RecordMetadata.AggregateAllRows) {
					customObjectRecord.AggregateAllRows__c.addError(errorMessage);
				} else if(this === RecordMetadata.RowLimit) {
					customObjectRecord.RowLimit__c.addError(errorMessage);
				}				
			}
		}
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
	
	/**
	 * Migrate in memory representation to latest by migrating values from old fields to new ones accordingly
	 *   (this approach makes code elsewhere in the tool simpler as it only deals with the latest fields)
	 **/
	public static SObject migrate(SObject rollup) {
		// No migrations for legacy Custom Object based rollups presently
		if(rollup instanceof LookupRollupSummary__c) {						
			return rollup;
		}
		// Perform various field migrations for Custom Metadata based rollups (done via JSON, since Apex cannot write to MDT fields)
		String jsonRollup = JSON.serialize(rollup, true);
		Map<String, Object> jsonParsed = (Map<String, Object>) JSON.deserializeUntyped(jsonRollup);
		Map<String, Object> jsonNew = new Map<String, Object>();
		for(String field : jsonParsed.keySet()) {
			// Migrate TestCode__c to TestCode2__c
			if(field.endsWith('TestCode__c')) {
				jsonNew.put(field.replace('TestCode__c', 'TestCode2__c'), jsonParsed.get(field));
			// Migrate all other fields as-is
			} else {
				jsonNew.put(field, jsonParsed.get(field));
			}			
		}
		return (SObject) JSON.deserializeStrict(JSON.serialize(jsonNew),LookupRollupSummary2__mdt.class);		
	}	
}