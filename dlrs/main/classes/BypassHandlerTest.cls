/**
 * Copyright (c), Andrew Fawcett
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
private class BypassHandlerTest {
  @IsTest
  static void testApi() {
    String rollupUniqueName = 'SampleRollup';
    Assert.isFalse(
      BypassHandler.isBypassed(rollupUniqueName),
      'The rollup should not be bypassed yet.'
    );

    Assert.isTrue(
      BypassHandler.bypass(rollupUniqueName),
      'Should have modified the bypassed rollups set.'
    );
    Assert.isTrue(
      BypassHandler.isBypassed(rollupUniqueName),
      'The rollup should be bypassed.'
    );

    Assert.isTrue(
      BypassHandler.clearBypass(rollupUniqueName),
      'Should have modified the bypassed rollups set.'
    );
    Assert.isFalse(
      BypassHandler.isBypassed(rollupUniqueName),
      'The rollup should not be bypassed anymore.'
    );
    BypassHandler.bypass(rollupUniqueName);
    BypassHandler.clearAllBypasses();
    Assert.isFalse(
      BypassHandler.isBypassed(rollupUniqueName),
      'The rollup should not be bypassed anymore.'
    );

    Assert.isFalse(
      BypassHandler.bypass(null),
      'Should return "false" for a null rollup name.'
    );

    Assert.isFalse(
      BypassHandler.clearBypass(null),
      'Should return "false" for a null rollup name.'
    );

    BypassHandler.setBypassAll(true);
    Assert.isTrue(
      BypassHandler.isBypassed(rollupUniqueName),
      'Should return "true" for all rollup names.'
    );
    Assert.isTrue(
      BypassHandler.isBypassed('new name'),
      'Should return "true" for all rollup names.'
    );
    BypassHandler.setBypassAll(false);

    Assert.isFalse(
      BypassHandler.isBypassed(rollupUniqueName),
      'Should return "false" for all rollup names.'
    );
    Assert.isFalse(
      BypassHandler.isBypassed('new name'),
      'Should return "false" for all rollup names.'
    );
    BypassHandler.setBypassAll(true);
    Assert.isTrue(
      BypassHandler.isBypassed('new name'),
      'Should return "true" for all rollup names.'
    );
    BypassHandler.clearAllBypasses();
    Assert.isFalse(
      BypassHandler.isBypassed('new name'),
      'Should return "false" for all rollup names.'
    );
  }

  @IsTest
  static void testCustomSettingDisable() {
    String rollupUniqueName = 'Rollup1';
    Assert.isFalse(BypassHandler.isBypassed(rollupUniqueName));

    DeclarativeLookupRollupSummaries__c settings = DeclarativeLookupRollupSummaries__c.getInstance();
    settings.DisableDLRSGlobally__c = true;
    insert settings;

    Assert.isTrue(BypassHandler.isBypassed(rollupUniqueName));
  }
}
