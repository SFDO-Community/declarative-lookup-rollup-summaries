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
 * Performs various queries on the ApexTrigger object
 **/
public class ApexTriggersSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			ApexTrigger.Name,
			ApexTrigger.UsageIsBulk, 
			ApexTrigger.UsageBeforeUpdate, 
			ApexTrigger.UsageBeforeInsert, 
			ApexTrigger.UsageBeforeDelete, 
			ApexTrigger.UsageAfterUpdate, 
			ApexTrigger.UsageAfterUndelete, 
			ApexTrigger.UsageAfterInsert, 
			ApexTrigger.UsageAfterDelete, 
			ApexTrigger.TableEnumOrId, 
			ApexTrigger.SystemModstamp,
			ApexTrigger.Status, 
			ApexTrigger.NamespacePrefix, 
			ApexTrigger.LengthWithoutComments, 
			ApexTrigger.LastModifiedDate, 
			ApexTrigger.LastModifiedById, 
			ApexTrigger.IsValid, 
			ApexTrigger.Id, 
			ApexTrigger.CreatedDate, 
			ApexTrigger.CreatedById, 
			ApexTrigger.BodyCrc, 
			ApexTrigger.Body, 
			ApexTrigger.ApiVersion
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return ApexTrigger.sObjectType;
	}
	
	/**
	 * Returns ApexTriggers that match the given name
	 **/
	public Map<String, ApexTrigger> selectByName(Set<String> names)
	{
		List<ApexTrigger> apexTriggers = 
			Database.query(
				newQueryFactory().
					setCondition('Name in :names').
					toSOQL());
		Map<String, ApexTrigger> mapByName = new Map<String, ApexTrigger>();
		for(ApexTrigger apexTrigger : apexTriggers)
			mapByName.put(apexTrigger.Name, apexTrigger);
		return mapByName;
	}
}