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

public class Utilities {
	/**
	 * Get the namespace of this package
	 **/
	public static String namespace()
	{
		Schema.DescribeSObjectResult describe = LookupRollupSummary__c.sObjectType.getDescribe();
		String name = describe.getName();
		String localName = describe.getLocalName();
		String namespace = name.removeEnd(localName).removeEnd('__');
		return namespace;
	}

	/**
	 * Get the component prefix based on the current namespace
	 **/
	public static String componentPrefix()
	{
		String namespace = namespace();
		return String.isEmpty(namespace) ? '' : (namespace + '_');
	}

	/**
	 * Get the class prefix based on the current namespace
	 **/
	public static String classPrefix()
	{
		String namespace = namespace();
		return String.isEmpty(namespace) ? '' : (namespace + '.');
	}

	/**
	 * Get the object prefix based on the current namespace
	 **/
	public static String objectPrefix()
	{
		String namespace = namespace();
		return String.isEmpty(namespace) ? '' : (namespace + '__');
	}

	/**
	 * Parse a string that follows the SOQL Order By standard
	 * 
	 * @param orderByClause - order by clause (not including ORDER BY keywords) following standard at https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql_select_orderby.htm
	 * @param fields - Describe Fields obtained from getDescribe().fields.getMap()
	 *
	 * @return list containing one LREngine.Ordering element for each field in the order by clause
	 *
	 * @remark In order to ensure proper case-insensitive identification of fields in the clause, the fields passed
	 *         in MUST be generated from Describe information.  If the map is generated elsewhere or even using describe keySet()
	 *         field identification will be case sensitive and could result in unexpected failure to parse clause
	 *
	 * @throw  OrderByInvalidException when order by is not in proper format or field is not found in fields
	 **/
	public static List<LREngine.Ordering> parseOrderByClause(String orderByClause, Map<String, Schema.SObjectField> fields)
	{
		if (String.isBlank(orderByClause)) {
			return null;
		}

		List<LREngine.Ordering> orderByFields = new List<LREngine.Ordering>();
		List<String> orderByClauseFields = orderByClause.split(',');
		for(String field :orderByClauseFields) {
			orderByFields.add(parseOrderByField(field, fields));
		}

		return orderByFields;
	}

	// Regular expression for Order By Clause
	// Case-Insensitive pattern
	// Group 1 - Field Name (required)
	// Group 2 - ASC/DESC (optional)
	// Group 3 - NULLS FIRST (optional)
	// Group 4 - NULLS (required if Group 3 != null)
	// Group 5 - FIRST (required if Group 3 != null)
	private static Pattern orderByPattern = Pattern.compile('^(?i)[\\s]*([\\w]*)[\\s]*(ASC|DESC)?[\\s]*((NULLS)[\\s]*(FIRST|LAST))?[\\s]*$');
	private static LREngine.Ordering parseOrderByField(String orderByField, Map<String, Schema.SObjectField> fields)
	{
		Matcher matcher = orderByPattern.matcher(orderByField);
		if (!matcher.matches() || matcher.groupCount() != 5) {
			throw new OrderByInvalidException('Invalid order by clause.');
		}

		// need to validate the field against Describe Information
		String fieldName = matcher.group(1);
		if (String.isBlank(fieldName) || !fields.containsKey(fieldName)) {
			// this error message should likely be something more like 'Invalid field in order by clause'
			// since we support one or more fields.  However, to ensure backwards compat and avoid breaking
			// tests that might exist out in the wild, making this error message the same as what it
			// would have been when only a single field was supported.
			throw new OrderByInvalidException('Field does not exist.');
		}
		SObjectField sobjField = fields.get(fieldName);

		// regex enforces that ordering be null, ASC or DESC
		// == operator is case-insensitive
		String ordering = matcher.group(2);
		LREngine.SortOrder sortOrder = (ordering == null) ? null : (ordering == 'DESC' ? LREngine.SortOrder.DESCENDING : LREngine.SortOrder.ASCENDING);

		// regex enforces that firstLast be null, FIRST or LAST
		// == operator is case-insensitive		
		String firstLast = matcher.group(5);		
		Boolean nullsLast = (firstLast == null) ? null : (firstLast == 'LAST');

		return new LREngine.Ordering(sobjField.getDescribe(), sortOrder, nullsLast);
	}	

	public class OrderByInvalidException extends Exception {}
}
