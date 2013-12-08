/**
 * Copyright (c), Andrew Fawcett, inc
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

public abstract with sharing class SObjectSelector
{
	private StringBuilder.FieldListBuilder m_fieldListBuilder;
	
	private static Set<String> whiteListStandardWithoutCurrencyIso = 
		new Set<String> { 'AsyncApexJob', 'ApexClass', 'ApexTrigger' };	
	
	public SObjectSelector()
	{
	}
	
	abstract List<Schema.SObjectField> getSObjectFieldList();
	
	abstract Schema.SObjectType getSObjectType();

	public StringBuilder.FieldListBuilder getFieldListBuilder()
	{
		if(m_fieldListBuilder == null)
			m_fieldListBuilder = whiteListStandardWithoutCurrencyIso.contains(getSObjectType().getDescribe().getName()) ?
				new StringBuilder.FieldListBuilder( getSObjectFieldList() ) : 
				new StringBuilder.MultiCurrencyFieldListBuilder( getSObjectFieldList());				
		return m_fieldListBuilder;
	}
	
	public void setFieldListBuilder(StringBuilder.FieldListBuilder fieldListBuilder)
	{
		m_fieldListBuilder = fieldListBuilder;
	}
	
	public String getFieldListString()
	{
		return getFieldListBuilder().getStringValue();
	}
	
	public String getRelatedFieldListString(String relation)
	{
		return getFieldListBuilder().getStringValue(relation + '.');
	}
	
	public String getSObjectName()
	{
		return getSObjectType().getDescribe().getName();
	}
	
	public virtual String getOrderBy()
	{
		return 'Name';
	}
		
	public List<SObject> selectSObjectsById(Set<Id> idSet)
	{
		assertIsAccessible();
		return Database.query(String.format('SELECT {0} FROM {1} WHERE id in :idSet ORDER BY {2}', new List<String>{getFieldListString(),getSObjectName(),getOrderBy()}));
	}

	public void assertIsAccessible()
	{
    	if(!getSObjectType().getDescribe().isAccessible())
    	   throw new SObjectDomain.DomainException('Permission to access an ' + getSObjectType().getDescribe().getName() + ' dennied.');		
	}
}