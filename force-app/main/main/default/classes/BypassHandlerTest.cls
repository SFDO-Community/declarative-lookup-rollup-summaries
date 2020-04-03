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
private class BypassHandlerTest
{
    @IsTest
    static void testApi()
    {
        String rollupUniqueName = 'SampleRollup';
        Boolean bypassResult;

        Test.startTest();
        System.assertEquals(false, BypassHandler.isBypassed(rollupUniqueName), 'The rollup should not be bypassed yet.');
        bypassResult = BypassHandler.bypass(rollupUniqueName);
        System.assert(bypassResult, 'Should have modified the bypassed rollups set.');
        System.assertEquals(true, BypassHandler.isBypassed(rollupUniqueName), 'The rollup should be bypassed.');
        bypassResult = BypassHandler.clearBypass(rollupUniqueName);
        System.assert(bypassResult, 'Should have modified the bypassed rollups set.');
        System.assertEquals(false, BypassHandler.isBypassed(rollupUniqueName), 'The rollup should not be bypassed anymore.');
        BypassHandler.bypass(rollupUniqueName);
        BypassHandler.clearAllBypasses();
        System.assertEquals(false, BypassHandler.isBypassed(rollupUniqueName), 'The rollup should not be bypassed anymore.');

        bypassResult = BypassHandler.bypass(null);
        System.assertEquals(false, bypassResult, 'Should return "false" for a null rollup name.');
        bypassResult = BypassHandler.clearBypass(null);
        System.assertEquals(false, bypassResult, 'Should return "false" for a null rollup name.');
        Test.stopTest();
    }
}
