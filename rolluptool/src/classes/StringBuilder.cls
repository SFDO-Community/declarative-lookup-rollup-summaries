/**
 * Copyright (c) 2012, FinancialForce.com, inc
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
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
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

public virtual with sharing class StringBuilder
{
	protected String m_stringValue;
	
	public StringBuilder() {}
	
	public StringBuilder(List<String> values)
	{
		add(values);
	}
	
	public virtual void add(List<String> values)
	{
		for(String value : values)
			add(value);
	}

	public virtual void add(String value)
	{
		m_stringValue = ( m_stringValue==null ? value : m_stringValue + value );
	}

	public virtual String getStringValue()
	{
		return m_stringValue;
	}


	/** Subclasses **/

	public virtual with sharing class CSVBuilder extends StringBuilder
	{
		public CSVBuilder() {}

		public CSVBuilder(List<String> values)
		{
			super(values);
		}
		
		public virtual override void add(String value)
		{
			m_stringValue = ( m_stringValue==null ? '{0}' + value : m_stringValue + ',{0}' + value );
		}
		
		public override String getStringValue()
		{
			return getStringValue('');
		}
		
		public String getStringValue(String itemPrefix)
		{
			return m_stringValue==null ? null : String.format(m_stringValue,new List<String>{itemPrefix});
		}
	}

	public virtual with sharing class FieldListBuilder extends CSVBuilder
	{
		public FieldListBuilder(List<Schema.SObjectField> values)
		{
			for(Schema.SObjectField value : values)
				add(value.getDescribe().getName());
		}
	}
	
	public with sharing class MultiCurrencyFieldListBuilder extends FieldListBuilder
	{
		public MultiCurrencyFieldListBuilder(List<Schema.SObjectField> values)
		{
			super(values);
			
			if(Userinfo.isMultiCurrencyOrganization())
				add('CurrencyIsoCode');
		}
	}
}