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

@IsTest
public class RollupSummariesTriggerTest {
  @IsTest
  static void testTriggerSuccess() {
    LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
    rollupSummary.Name = 'Test';
    rollupSummary.UniqueName__c = 'Test';
    rollupSummary.ParentObject__c = 'User';
    rollupSummary.ChildObject__c = 'User';
    rollupSummary.RelationShipField__c = 'CreatedById';
    rollupSummary.RelationShipCriteria__c = null;
    rollupSummary.FieldToAggregate__c = 'Id';
    rollupSummary.AggregateOperation__c = 'First';
    rollupSummary.AggregateResultField__c = 'FirstName';
    rollupSummary.Active__c = true;
    rollupSummary.CalculationMode__c = 'Process Builder';
    insert rollupSummary;
    List<LookupRollupSummary__c> summaries = [
      SELECT Id
      FROM LookupRollupSummary__c
    ];
    Assert.areEqual(1, summaries.size());
  }

  @IsTest
  static void testTriggerFail() {
    LookupRollupSummary__c rollupSummary = new LookupRollupSummary__c();
    rollupSummary.Name = 'Test';
    rollupSummary.UniqueName__c = 'Test';
    rollupSummary.ParentObject__c = 'User';
    rollupSummary.ChildObject__c = 'User';
    rollupSummary.RelationShipField__c = 'CreatedById';
    rollupSummary.RelationShipCriteria__c = null;
    rollupSummary.FieldToAggregate__c = 'NotAField';
    rollupSummary.AggregateOperation__c = 'First';
    rollupSummary.AggregateResultField__c = 'MiddleName';
    rollupSummary.Active__c = true;
    rollupSummary.CalculationMode__c = 'Process Builder';
    // Should fail because 'NotAField' in FieldToAggregate__c is not a valid field on User
    Database.SaveResult res = Database.Insert(rollupSummary, false);
    Assert.isFalse(
      res.isSuccess(),
      'Expected insert to fail as a result of trigger validation'
    );
  }
}
