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
 * Invocable method allows Processs Builder and Visual Flow to invoke the rollup engine
 *   (rollup summaries needed to be set to Process Builder)
 **/
global with sharing class RollupActionCalculate 
{
	/**
	 * Describes a specific rollup to process
	 **/
	global class RollupToCalculate {
		@InvocableVariable(label='Parent Record Id' required=true)
		global Id ParentId;
		@InvocableVariable(label='Rollup Summary Unique Name' required=true)
		global String RollupSummaryUniqueName;
		private RollupService.RollupToCalculate toServiceRollupToCalculate() {
			RollupService.RollupToCalculate rollupToCalculate = new RollupService.RollupToCalculate();
			rollupToCalculate.parentId = parentId;
			rollupToCalculate.rollupSummaryUniqueName = rollupSummaryUniqueName;
			return rollupToCalculate;
		}
	}

	@InvocableMethod(
		label='Calculates a rollup' 
		description='Provide the Id of the parent record and the unique name of the rollup to calculate, you specificy the same Id multiple times to invoke multiple rollups')
	global static void calculate(List<RollupToCalculate> rollupsToCalculate) {
		List<RollupService.RollupToCalculate> rollupsToCalc = new List<RollupService.RollupToCalculate>();
		for(RollupToCalculate rollupToCalc : rollupsToCalculate)
			rollupsToCalc.add(rollupToCalc.toServiceRollupToCalculate());
		RollupService.rollup(rollupsToCalc);
	}
}