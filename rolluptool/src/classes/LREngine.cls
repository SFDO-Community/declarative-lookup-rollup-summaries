/*
Copyright (c) tgerm.com
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/**
    LREngine("L"ookup "R"ollup Engine) : This class simplifies rolling up on the child records in lookup relationship.
*/
public class LREngine {
    
    /*
        Tempalte tokens
            0 : Fields to project
            1 : Object to query
            2 : Optional WHERE clause filter to add
            3 : Group By field name
    */
    static String SOQL_AGGREGATE_TEMPLATE = 'SELECT {0} FROM {1} WHERE {3} in :masterIds {2} GROUP BY {3}';

    /*
        Tempalte tokens
            0 : Fields to project
            1 : Object to query
            2 : Optional WHERE clause filter to add
            3 : Order by clause
    */
    static String SOQL_QUERY_TEMPLATE = 'SELECT {0} FROM {1} WHERE {2} in :masterIds {3} ORDER BY {4}';
    
    /*
    Support for multi-currency orgs
    */
    static String MASTERCURRENCYALIAS = 'mastercc';
    public static String CURRENCYISOCODENAME = 'CurrencyIsoCode';
    //http://advancedapex.com/2013/07/07/optional-features/
    private static Boolean m_IsMultiCurrency = null;
    public static Boolean IsMultiCurrencyOrg() {
        if(m_IsMultiCurrency!=null) return m_IsMultiCurrency;
        m_IsMultiCurrency = UserInfo.isMultiCurrencyOrganization();
        return m_IsMultiCurrency;
    }

    // Currency lookup
    static final Map<String,Decimal> currencyConversionMap = new Map<String,Decimal>();
    private static Decimal convertCurrency(String iso, Decimal val) {
        if(currencyConversionMap.isEmpty()){
            String query = 'select IsoCode, ConversionRate from CurrencyType where IsActive = true';
            for(sObject ct : Database.query(query))
                currencyConversionMap.put((String)ct.get('IsoCode'), (Decimal)ct.get('ConversionRate'));
        }
        return val!=null ? val * currencyConversionMap.get(iso) : 0;
    }

    /**
        Key driver method that rolls up lookup fields based on the context. This is specially useful in Trigger context.
        
        @param ctx Context the complete context required to rollup
        @param detailRecordsFromTrigger child/detail records which are modified/created/deleted during the Trigger 
        @returns Array of in memory master objects. These objects are not updated back to the database
                because we want client or calling code to have this freedom to do some post processing and update when required.
    */
    public static Sobject[] rollUp(Context ctx, Sobject[] detailRecordsFromTrigger) {
        
        // API name of the lookup field on detail sobject
        String lookUpFieldName = ctx.lookupField.getName();
                
        Set<Id> masterRecordIds = new Set<Id>(); 
        for (Sobject kid : detailRecordsFromTrigger) {
            masterRecordIds.add((Id)kid.get(lookUpFieldName));
        }
        return rollUp(ctx, masterRecordIds);
    }

    /**
        Key driver method that rolls up lookup fields based on the context. This is meant to be called from non trigger contexts like
        scheduled/batch apex, where we want to rollup on some master record ids.
        
        @param Context the complete context required to rollup
        @param masterIds Master record IDs whose child records should be rolled up. 
        @returns Array of in memory master objects. These objects are not updated back to the database
                because we want client or calling code to have this freedom to do some post processing and update when required.
    */
    public static Sobject[] rollUp(Context ctx,  Set<Id> masterIds) {
        return rollUp(ctx, masterIds, false);
    }
    
    /**
        Key driver method that rolls up lookup fields based on the context. This is meant to be called from non trigger contexts like
        scheduled/batch apex, where we want to rollup on some master record ids.
        
        @param Context the complete context required to rollup
        @param masterIds Master record IDs whose child records should be rolled up. 
        @param validateOnly Checks the SOQL query is valid, throws an exception if not, returns null if valid
        @returns Array of in memory master objects. These objects are not updated back to the database
                because we want client or calling code to have this freedom to do some post processing and update when required.
    */
    public static Sobject[] rollUp(Context ctx,  Set<Id> masterIds, Boolean validateOnly) {
        // Clone this since we are about to modify it later
        masterIds = masterIds.clone();
        // K: Id of master record
        // V: Empty sobject with ID field, this will be used for updating the masters
        Map<Id, Sobject> masterRecordsMap = new Map<Id, Sobject>(); 
        for (Id mId : masterIds) {
            masterRecordsMap.put(mId, ctx.master.newSobject(mId));
        }
        
        // #0 token : SOQL projection
        String soqlProjection = ctx.lookupField.getName();
        List<String> orderByFields = new List<String>();
        orderByFields.add(ctx.lookupField.getName()); // ensure details records are ordered by parent record

        // k: detail field name, v: master field name
        Integer exprIdx = 0;
        Boolean needsCurrency = false;
        Boolean builtAggregateQuery = false;
        Map<String, RollupSummaryField> rsfByAlais = new Map<String, RollupSummaryField>();
        for (RollupSummaryField rsf : ctx.fieldsToRoll) {
            if(rsf.operation == RollupOperation.Sum ||
               rsf.operation == RollupOperation.Max ||
               rsf.operation == RollupOperation.Min ||
               rsf.operation == RollupOperation.Avg ||
               rsf.operation == RollupOperation.Count ||
               rsf.operation == RollupOperation.Count_Distinct) {
                // create aggreate projection with alias for easy fetching via AggregateResult class
                // i.e. SUM(Amount) Amount
                builtAggregateQuery = true;
                String alias = 'lre'+exprIdx++; // Calculate an alias, using field name blew the 25 character limit in some cases
                soqlProjection += ', ' + rsf.operation + '(' + rsf.detail.getName() + ') ' + alias;
                rsfByAlais.put(alias, rsf);
                if(IsMultiCurrencyOrg() == true && needsCurrency == false && rsf.isMasterTypeCurrency){
                    needsCurrency = true;
                }                
            } else {
                // create field projection 
                // i.e. Amount
                soqlProjection += ', ' + rsf.detail.getName();
                // create order by projections
                // i.e. Amount ASC NULLS FIRST
                String orderByField = 
                    rsf.detailOrderBy!=null ? rsf.detailOrderBy.getName() : rsf.detail.getName();
                orderByFields.add(orderByField);
            }
        }
        
        // Add a field selection to get the currency from the parent record if we are depositing values into a currency field
        if(IsMultiCurrencyOrg() == true && needsCurrency == true){
            String lookupRelationshipName = ctx.lookupField.getRelationshipName();
            soqlProjection += ', ' + RollupOperation.Max + '(' + lookupRelationshipName + 
                    '.' + CURRENCYISOCODENAME + ') ' + MASTERCURRENCYALIAS;
        }

        // #1 token for SOQL_TEMPLATE
        String detailTblName = ctx.detail.getDescribe().getName();
        
        // #2 Where clause
        String whereClause = '';
        if (ctx.detailWhereClause != null && ctx.detailWhereClause.trim().length() > 0) {
            whereClause = 'AND ' + ctx.detailWhereClause ;
        }
        
        // #3 Group by field
        String grpByFld = ctx.lookupField.getName();

        // build approprite soql for this rollup context
        String soql =
            builtAggregateQuery ? 
                String.format(SOQL_AGGREGATE_TEMPLATE, 
                    new String[]{ 
                        soqlProjection, 
                        detailTblName, 
                        whereClause, 
                        grpByFld}) : 
                String.format(SOQL_QUERY_TEMPLATE, 
                    new String[]{
                        soqlProjection, 
                        detailTblName, 
                        ctx.lookupField.getName(), 
                        whereClause, 
                        String.join(orderByFields, ',')});
        System.debug('SOQL is ' + soql);

        // validate only?
        if(validateOnly) {
            Database.getQueryLocator(soql);
            return null;
        }

        // query results 
        Object queryResults = Database.query(soql);
        if(queryResults instanceof List<AggregateResult>) {

            // Process Aggregate query results from RollupOperations related to Aggergate operations
            List<AggregateResult> results = (List<AggregateResult>) queryResults;
            for (AggregateResult res : results){
                Id masterRecId = (Id)res.get(grpByFld);
                Sobject masterObj = masterRecordsMap.get(masterRecId);
                if (masterObj == null) {
                    System.debug(Logginglevel.WARN, 'No master record found for ID :' + masterRecId);
                    continue;
                }
                
                for (String alias : rsfByAlais.keySet()) {
                    RollupSummaryField rsf = rsfByAlais.get(alias);
                    Object aggregatedDetailVal = res.get(alias);
                    System.debug(LoggingLevel.INFO, 'New aggregarte value ' + aggregatedDetailVal + ' for master ' + masterRecId);
                    // Should also test for necessity
                    if(IsMultiCurrencyOrg() == true && rsf.isMasterTypeCurrency){
                        masterObj.put(rsf.master.getName(), convertCurrency((String)res.get(MASTERCURRENCYALIAS),(Decimal)aggregatedDetailVal));
                    } else {
                        masterObj.put(rsf.master.getName(), aggregatedDetailVal);
                    }
                }           
                // Remove master Id record as its been processed    
                masterIds.remove(masterRecId);  
            }            
        } else if(queryResults instanceof List<SObject>) {

            // Group detail records by master Id
            List<SObject> detailRecords = (List<SObject>) queryResults;
            Map<Id, List<SObject>> detailRecordsByMasterId = new Map<Id, List<SObject>>();
            Id lastMasterId = null;
            List<SObject> currentDetailRecords = null;
            for(SObject detailRecord : detailRecords) {
                Id masterId = (Id) detailRecord.get(ctx.lookupField.getName());
                if(masterId != lastMasterId) {
                    currentDetailRecords = new List<SObject>();
                    detailRecordsByMasterId.put(masterId, currentDetailRecords);
                }
                currentDetailRecords.add(detailRecord);
                lastMasterId = masterId;
            }

            // Process rollup fields
            for(Id masterId : detailRecordsByMasterId.keySet()) {
                for (RollupSummaryField rsf : ctx.fieldsToRoll) {
                    List<SObject> childDetailRecords = detailRecordsByMasterId.get(masterId);
                    if(rsf.operation == RollupOperation.Concatenate ||
                       rsf.operation == RollupOperation.Concatenate_Distinct) {                    
                        Concatenator concatenator =
                            new Concatenator(rsf.operation == RollupOperation.Concatenate_Distinct, rsf.concatenateDelimiter);
                        for(SObject childDetailRecord : childDetailRecords) {
                            String childFieldValue = String.valueOf(childDetailRecord.get(rsf.detail.getName()));
                            if (childFieldValue != null) {
                            if (rsf.detail.getType() == Schema.DisplayType.MultiPicklist) {
                                    for (String mspValue : childFieldValue.split(';')) {
                                    concatenator.add(mspValue);
                                }
                            } else {
                                    concatenator.add(childFieldValue);
                                }
                            }
                        }
                        String concatenatedValues = concatenator.toString();
                        concatenatedValues = concatenatedValues.abbreviate(rsf.master.getLength());
                        masterRecordsMap.get(masterId).put(rsf.master.getName(), concatenatedValues);
                    } else if(rsf.operation == RollupOperation.First) {
                        masterRecordsMap.get(masterId).put(
                            rsf.master.getName(), childDetailRecords[0].get(rsf.detail.getName()));
                    } else if(rsf.operation == RollupOperation.Last) {
                        masterRecordsMap.get(masterId).put(
                            rsf.master.getName(), childDetailRecords[childDetailRecords.size()-1].get(rsf.detail.getName()));                        
                    }
                    // Remove master Id record as its been processed    
                    masterIds.remove(masterId);                          
                }                
            }
        }
        
        // Zero rollups for unprocessed master records (those with no longer any child relationships)
        for(Id masterRecId : masterIds)
            for (RollupSummaryField rsf : ctx.fieldsToRoll)
                masterRecordsMap.get(masterRecId).put(rsf.master.getName(), 
                    rsf.isMasterTypeNumber ? 0 : null);
        
        return masterRecordsMap.values();   
    }

    /**
     * Concatenates strings (removes duplicates)
     **/
    private class Concatenator
    {
        private Boolean distinct;
        private List<String> listOfString;
        private Set<String> setOfStrings;
        private String delimiter;

        public Concatenator(Boolean distinct, String delimiter) {
            this.distinct = distinct;
            if(delimiter!=null)
                this.delimiter = delimiter.equals('BR()') ? '\n' : delimiter;
            setOfStrings = new Set<String>();
            listOfString = new List<String>();
        }

        public void add(String value) {
            Boolean exists = setOfStrings.contains(value);
            if(!exists)
                setOfStrings.add(value);
            if(distinct ? !exists : true)
                listOfString.add(value);
        }

        public override String toString() {
            return String.join(listOfString, delimiter == null ? '' : delimiter);
        }
    }
        
    /**
        Exception throwed if Rollup Summary field is in bad state
    */
    public class BadRollUpSummaryStateException extends Exception {}
    
   /**
       Which rollup operation you want to perform 
    */ 
    public enum RollupOperation {
        Sum, Max, Min, Avg, Count, Count_Distinct, Concatenate, Concatenate_Distinct, First, Last
    }
    
    /**
        Represents a "Single" roll up field, it contains
        - Master field where the rolled up info will be saved
        - Detail field that will be rolled up via any operation i.e. sum, avg etc 
        - Operation to perform i.e. sum, avg, count etc
            
    */
    public class RollupSummaryField {
        public Schema.Describefieldresult master;
        public Schema.Describefieldresult detail;
        public Schema.Describefieldresult detailOrderBy;
        public RollupOperation operation;
        public String concatenateDelimiter;
        
        // derived fields, kept like this to save script lines later, by saving the same
        // computations over and over again
        public boolean isMasterTypeNumber;
        public boolean isDetailTypeNumber;
        public boolean isMasterTypeDateOrTime;
        public boolean isDetailTypeDateOrTime; 
        public boolean isMasterTypeCurrency;
        public boolean isMasterTypeText;
        public boolean isDetailTypeText;

        public RollupSummaryField(Schema.Describefieldresult m, 
                                         Schema.Describefieldresult d, RollupOperation op) {
            this(m, d, null, op, null);
        }

        public RollupSummaryField(Schema.Describefieldresult m, 
                                         Schema.Describefieldresult d, 
                                         Schema.Describefieldresult detailOrderBy,
                                         RollupOperation op,
                                         String concatenateDelimiter) {
            this.master = m;
            this.detail = d;
            this.detailOrderBy = detailOrderBy;
            this.operation = op;
            this.concatenateDelimiter = concatenateDelimiter;
            // caching these derived attrbutes for once
            // as their is no view state involved here
            // and this caching will lead to saving in script lines later on
            this.isMasterTypeNumber = isNumber(master.getType());
            this.isDetailTypeNumber = isNumber(detail.getType());
            this.isMasterTypeDateOrTime = isDateOrTime(master.getType());
            this.isDetailTypeDateOrTime = isDateOrTime(detail.getType()); 
            this.isMasterTypeCurrency = isCurrency(master.getType());
            this.isMasterTypeText = isText(master.getType());
            this.isDetailTypeText = isText(detail.getType());
            // validate if field is good to work on later 
            validate();
        }   
        
        void validate() {
            if (master == null || detail == null || operation == null) 
                throw new BadRollUpSummaryStateException('All of Master/Detail Describefieldresult and RollupOperation info is mandantory');

            if (operation == RollupOperation.Concatenate ||
                operation == RollupOperation.Concatenate_Distinct) {
                if ( !isMasterTypeText ) {
                    throw new BadRollUpSummaryStateException('Only Text/Text Area fields are allowed for Concatenate and Concatenate Distinct');
                }
            }

            if (operation == RollupOperation.First ||
                operation == RollupOperation.Last) {
                if ( (this.master.getType() != this.detail.getType()) &&
                     (!isDetailTypeText && !isMasterTypeText) ) {
                    throw new BadRollUpSummaryStateException('Master and detail fields must be the same field type (or text based) for First or Last operations');
                }
            }

            if (operation == RollupOperation.Sum ||
                operation == RollupOperation.Max ||
                operation == RollupOperation.Min ||
                operation == RollupOperation.Avg) {
                if ( (!isMasterTypeDateOrTime && !isMasterTypeNumber) ||
                     (!isDetailTypeDateOrTime && !isDetailTypeNumber)) {
                    throw new BadRollUpSummaryStateException('Only Date/DateTime/Time/Numeric fields are allowed for Sum, Max, Min and Avg');
                }
            }
            
            if (isMasterTypeDateOrTime && (RollupOperation.Sum == operation || RollupOperation.Avg == operation)) {
                throw new BadRollUpSummaryStateException('Sum/Avg doesnt looks like valid for dates ! Still want, then implement the IRollerCoaster yourself and change this class as required.');
            }
        }

        boolean isText (Schema.Displaytype dt) {
            return dt == Schema.Displaytype.TextArea ||
                dt == Schema.Displaytype.String ||
                dt == Schema.Displaytype.Picklist ||
                dt == Schema.Displaytype.MultiPicklist;
        }

        boolean isNumber (Schema.Displaytype dt) {
            return dt == Schema.Displaytype.Currency 
                   || dt == Schema.Displaytype.Integer
                   || dt == Schema.Displaytype.Percent
                   || dt == Schema.Displaytype.Double;
        }
        
        boolean isDateOrTime(Schema.DisplayType dt) {
            return dt == Schema.Displaytype.Time 
                   || dt == Schema.Displaytype.Date
                   || dt == Schema.Displaytype.Datetime;
        }

        boolean isCurrency(Schema.DisplayType dt) {
            return dt == Schema.Displaytype.Currency;
        }

        public boolean isAggregateBasedRollup() {
            return operation == RollupOperation.Sum ||
                operation == RollupOperation.Min ||
                operation == RollupOperation.Max ||
                operation == RollupOperation.Avg ||
                operation == RollupOperation.Count ||
                operation == RollupOperation.Count_Distinct;
        }

        public boolean isQueryBasedRollup() {
            return operation == RollupOperation.Concatenate ||
                operation == RollupOperation.Concatenate_Distinct ||
                operation == RollupOperation.First ||
                operation == RollupOperation.Last;
        }
    }
    
    /**
        Context having all the information about the rollup to be done. 
        Please note : This class encapsulates many rollup summary fields with different operations.
    */
    public class Context {
        // Master Sobject Type
        public Schema.Sobjecttype master;
        // Child/Details Sobject Type
        public Schema.Sobjecttype detail;
        // Lookup field on Child/Detail Sobject
        public Schema.Describefieldresult lookupField;
        // various fields to rollup on
        public List<RollupSummaryField> fieldsToRoll;
        // what type of rollups does this context contain
        private Boolean isAggregateBased = null;
        private Boolean isQueryBased = null;
        
        // Where clause or filters to apply while aggregating detail records
        public String detailWhereClause;            
        
        public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf) {
            this(m, d, lf, '');                             
        }
        
        public Context(Schema.Sobjecttype m, Schema.Sobjecttype d, 
                           Schema.Describefieldresult lf, String detailWhereClause) {
            this.master = m;
            this.detail = d;
            this.lookupField = lf;
            this.detailWhereClause = detailWhereClause;
            this.fieldsToRoll = new List<RollupSummaryField>();
        }
        
        /**
            Adds new rollup summary fields to the context
        */
        public void add(RollupSummaryField fld) {

            // The type of query this context is based is driven by the first summary field added
            if(isQueryBased == null && isAggregateBased == null)
            {
                isAggregateBased = fld.isAggregateBasedRollup();
                isQueryBased = fld.isQueryBasedRollup();
            }

            // A context cannot support summary fields with operations that mix the use of underlying query types
            if(isAggregateBased && !fld.isAggregateBasedRollup() ||
               isQueryBased && !fld.isQueryBasedRollup())
                throw new BadRollUpSummaryStateException('Cannot mix Sum, Max, Min, Avg, Count, Count_Distinct operations with Concatenate, Concatenate_Distinct, First, Last operations');

            this.fieldsToRoll.add(fld);
        }
    }    
}