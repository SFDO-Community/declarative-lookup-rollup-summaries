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
	 *
	 * @return list containing one LREngine.Ordering element for each field in the order by clause
	 *
	 * @throw  OrderByInvalidException when order by is not in proper format
	 **/
	public static List<Utilities.Ordering> parseOrderByClause(String orderByClause)
	{
		if (String.isBlank(orderByClause)) {
			return null;
		}

		List<Utilities.Ordering> orderByFields = new List<Utilities.Ordering>();
		List<String> orderByClauseFields = orderByClause.split(',');
		for(String field :orderByClauseFields) {
			orderByFields.add(parseOrderByField(field));
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
	private static Pattern orderByPattern = Pattern.compile('^(?i)[\\s]*([\\w]+)[\\s]*(ASC|DESC)?[\\s]*((NULLS)[\\s]*(FIRST|LAST))?[\\s]*$');
	private static Utilities.Ordering parseOrderByField(String orderByField)
	{
		Matcher matcher = orderByPattern.matcher(orderByField);
		if (!matcher.matches() || matcher.groupCount() != 5) {
			throw new Utilities.OrderByInvalidException('Invalid order by clause.');
		}

		// regex enforces that fieldname cannot be blank
		String fieldName = matcher.group(1);

		// regex enforces that ordering be null, ASC or DESC
		// == operator is case-insensitive
		String ordering = matcher.group(2);
		Utilities.SortOrder sortOrder = (ordering == null) ? null : (ordering == 'DESC' ? Utilities.SortOrder.DESCENDING : Utilities.SortOrder.ASCENDING);

		// regex enforces that firstLast be null, FIRST or LAST
		// == operator is case-insensitive		
		String firstLast = matcher.group(5);		
		Boolean nullsLast = (firstLast == null) ? null : (firstLast == 'LAST');

		return new Utilities.Ordering(fieldName, sortOrder, nullsLast);
	}

    /**
        Sort Order
    */
    public enum SortOrder {ASCENDING, DESCENDING}

    /**
        Represents a single portion of the Order By clause for SOQL statement
    */
    public class Ordering{
        private SortOrder direction;
        private Boolean nullsLast;
        private String field;
        private Boolean directionSpecified; // if direction was specified during construction
        private Boolean nullsLastSpecified; // if nullsLast was specified during construction

        /**
         * Construct a new ordering instance
        **/
        public Ordering(String field) {
            this(field, null);
        }        
        public Ordering(String field, SortOrder direction) {
            this(field, direction, null);
        }
        public Ordering(String field, SortOrder direction, Boolean nullsLast) {
            setField(field);
            this.directionSpecified = direction != null;
            this.nullsLastSpecified = nullsLast != null;
            this.direction = this.directionSpecified ? direction : SortOrder.ASCENDING; //SOQL docs ASC is default behavior
            this.nullsLast = this.nullsLastSpecified ? nullsLast : false; //SOQL docs state NULLS FIRST is default behavior
        }
        public String getField() {
            return field;
        }
        public void setField(String field) {
        	if (String.isBlank(field)) {
				throw new Utilities.BadOrderingStateException('field cannot be blank.');
        	}
        	this.field = field;
        }
        public SortOrder getDirection() {
            return direction;
        }
        public Boolean getNullsLast() {
            return nullsLast;
        }
        public override String toString() {
            return field + ' ' + (direction == Utilities.SortOrder.ASCENDING ? 'ASC' : 'DESC') + ' ' + (nullsLast ? 'NULLS LAST' : 'NULLS FIRST');
        }
        public String toAsSpecifiedString() {
            // emit order by using describe info with the direction and nullsLast
            // that was provided during construction.  This allows to regurgitate
            // the proper SOQL order by using exactly what was passed in
            return field + (directionSpecified ? (direction == Utilities.SortOrder.ASCENDING ? ' ASC' : ' DESC') : '') + (nullsLastSpecified ? (nullsLast ? ' NULLS LAST' : ' NULLS FIRST') : '');
        }
    }	


    /**
        Exception thrown if Order by clause is invalid
    */    
	public class OrderByInvalidException extends Exception {}

    /**
        Exception thrown if Ordering is in bad state
    */
    public class BadOrderingStateException extends Exception {}
}