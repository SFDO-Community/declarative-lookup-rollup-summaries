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
 * Wraps the Apex Metadata API to provide create, update and delete operations around Custom Metadata SObject's
 *
 *  NOTE: Upsert is currently not supported by the Metadata API
 *
 * TODO: Support bulk requests
 * TODO: Support All Or Nothing (new for Metadata API v34.0)
 **/
public class CustomMetadataService {

	public static void createMetadata(SObjectType mdtType, List<Map<SObjectField, Object>> records) {

	}

	/**
	 * Insert the given Custom Metadata records into the orgs config
	 **/
	public static void createMetadata(List<SObject> records) {
		// Call Metadata API and handle response
		MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 
			service.createMetadata(new List<MetadataService.Metadata> { toCustomMetadata(records[0]) });
		handleSaveResults(results[0]);
	}

	/**
	 * Update the given Custom Metadata records in the orgs config
	 **/
	public static void updateMetadata(List<SObject> records) {
		// Call Metadata API and handle response
		MetadataService.MetadataPort service = createService();
		List<MetadataService.SaveResult> results = 
			service.updateMetadata(new List<MetadataService.Metadata> { toCustomMetadata(records[0]) });
		handleSaveResults(results[0]);
	}

	/**
	 * Delete the given Custom Metadata records from the orgs config
	 **/
	public static void deleteMetadata(SObjectType qualifiedMetadataType, List<String> customMetadataFullNames) {
		MetadataService.MetadataPort service = createService();
		List<String> qualifiedFullNames = new List<String>();
		for(String customMetadataFullName : customMetadataFullNames)
			qualifiedFullNames.add(qualifiedMetadataType.getDescribe().getName() + '.' + customMetadataFullName);
		List<MetadataService.DeleteResult> results = 
			service.deleteMetadata('CustomMetadata', qualifiedFullNames);
		handleDeleteResults(results[0]);
	}

	public class CustomMetadataServiceException extends Exception {}

	/**
	 * Takes the SObject instance of the Custom Metadata Type and translates to a Metadata API Custmo Metadata Type
	 **/
	private static MetadataService.CustomMetadata toCustomMetadata(SObject customMetadataRecord) {
		MetadataService.CustomMetadata cm = new MetadataService.CustomMetadata();
		cm.values = new List<MetadataService.CustomMetadataValue>();
		SObjectType recordType = customMetadataRecord.getSObjectType();
		cm.fullName = recordType.getDescribe().getName().replace('__mdt', '') + '.' + customMetadataRecord.get('DeveloperName');
		cm.label = (String) customMetadataRecord.get('Label');
		for(SObjectField sObjectField : recordType.getDescribe().fields.getMap().values()) {
			DescribeFieldResult dsr = sObjectField.getDescribe();
			if(!dsr.isCustom())
				continue;
			Object fieldValue = customMetadataRecord.get(sObjectField);
			MetadataService.CustomMetadataValue cmdv = new MetadataService.CustomMetadataValue();
			cmdv.field = dsr.getName();
			if(dsr.getType() == Schema.DisplayType.Double) {
				if(fieldValue!=null) {
					Decimal fieldValueNumber = (Decimal) fieldValue;
					// TODO: Bit of a hack, MDT Number fields seem to be populated with zeros when the VF bound field is emptied by the user?!?
					if(fieldValueNumber != 0) {
						fieldValueNumber = fieldValueNumber.setScale(dsr.getScale());
						cmdv.value = fieldValueNumber.format();											
					}
				}
			} else if( dsr.getType() == Schema.DisplayType.String) {
				cmdv.value = fieldValue == null ? '' : (String) fieldValue;
			} else if( dsr.getType() == Schema.DisplayType.TextArea) {
				cmdv.value = fieldValue == null ? '' : (String) fieldValue;
			} else {
				cmdv.value = fieldValue + ''; // TODO: More work here, type conversion				
			}
			cm.values.add(cmdv);
		}
		return cm;
	}

	/** 
	 * Connect to the Metadata API 
	 **/
	private static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}

	/**
	 * Example helper method to interpret a SaveResult, throws an exception if errors are found
	 **/
	private static void handleSaveResults(MetadataService.SaveResult saveResult)
	{
		// Nothing to see?
		if(saveResult==null || saveResult.success)
			return;
		// Construct error message and throw an exception
		if(saveResult.errors!=null) 
		{
			List<String> messages = new List<String>();
			messages.add(
				(saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
					'occured processing component ' + saveResult.fullName + '.');
			for(MetadataService.Error error : saveResult.errors)
				messages.add(
					error.message + ' (' + error.statusCode + ').' + 
					( error.fields!=null && error.fields.size()>0 ? 
						' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
			if(messages.size()>0)
				throw new CustomMetadataServiceException(String.join(messages, ' '));
		}
		if(!saveResult.success)
			throw new CustomMetadataServiceException('Request failed with no specified error.');
	}	

	/**
	 * Example helper method to interpret a SaveResult, throws an exception if errors are found
	 **/
	private static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
	{
		// Nothing to see?
		if(deleteResult==null || deleteResult.success)
			return;
		// Construct error message and throw an exception
		if(deleteResult.errors!=null)
		{
			List<String> messages = new List<String>();
			messages.add(
				(deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') + 
					'occured processing component ' + deleteResult.fullName + '.');
			for(MetadataService.Error error : deleteResult.errors)
				messages.add(
					error.message + ' (' + error.statusCode + ').' + 
					( error.fields!=null && error.fields.size()>0 ? 
						' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
			if(messages.size()>0)
				throw new CustomMetadataServiceException(String.join(messages, ' '));
		}
		if(!deleteResult.success)
			throw new CustomMetadataServiceException('Request failed with no specified error.');		
	}	
}