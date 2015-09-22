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
 * Performs various queries on the ApexClass object
 **/
public class ApexClassesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			ApexClass.SystemModstamp, 
			ApexClass.Status, 
			ApexClass.NamespacePrefix, 
			ApexClass.Name, 
			ApexClass.LengthWithoutComments, 
			ApexClass.LastModifiedDate, 
			ApexClass.LastModifiedById, 
			ApexClass.IsValid, 
			ApexClass.Id, 
			ApexClass.CreatedDate, 
			ApexClass.CreatedById, 
			ApexClass.BodyCrc, 
			ApexClass.Body, 
			ApexClass.ApiVersion			
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return ApexClass.sObjectType;
	}
	
	/**
	 * Returns ApexClass that match the given name
	 **/	
	public Map<String, ApexClass> selectByName(Set<String> names)
	{
		List<ApexClass> apexClasses = 
			Database.query(
				newQueryFactory().
					setCondition('Name in :names').
					toSOQL());
		Map<String, ApexClass> mapByName = new Map<String, ApexClass>();
		for(ApexClass apexClass : apexClasses)
			mapByName.put(apexClass.Name, apexClass);
		return mapByName;
	}
}