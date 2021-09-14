/**
 * Copyright (c) 2017, Andrew Fawcett
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

@IsTest
public with sharing class RollupSummaryLogDeleteControllerTest {

    @IsTest
    public static void givenRecordsToDeleteThenDeleted() {
        
        // Given
        LookupRollupSummaryLog__c log1 = new LookupRollupSummaryLog__c(ParentId__c = 'abc');
        LookupRollupSummaryLog__c log2 = new LookupRollupSummaryLog__c(ParentId__c = 'xyz');
        insert new List<LookupRollupSummaryLog__c> { log1, log2 };
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(new List<LookupRollupSummaryLog__c> { log1 });
        std.setSelected(new List<LookupRollupSummaryLog__c> { log1 });
        RollupSummaryLogDeleteController ctrl = new RollupSummaryLogDeleteController(std);
        
        // When
        ctrl.deleteLog();
        
        // Then 
        System.assertEquals(1, [select Id from LookupRollupSummaryLog__c].size());
    }
    
    @IsTest
    public static void givenNoRecordsToDeleteThenNotDeleted() {
        
        // Given
        LookupRollupSummaryLog__c log1 = new LookupRollupSummaryLog__c(ParentId__c = 'abc');
        LookupRollupSummaryLog__c log2 = new LookupRollupSummaryLog__c(ParentId__c = 'xyz');
        insert new List<LookupRollupSummaryLog__c> { log1, log2 };
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(new List<LookupRollupSummaryLog__c> { });
        RollupSummaryLogDeleteController ctrl = new RollupSummaryLogDeleteController(std);
        
        // When
        ctrl.deleteLog();
        
        // Then 
        System.assertEquals(2, [select Id from LookupRollupSummaryLog__c].size());
    }    
}