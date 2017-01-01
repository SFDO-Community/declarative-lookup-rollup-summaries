/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
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
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public with sharing class fflib_MethodReturnValueRecorder
{
	public Boolean Stubbing { get; set; }

	public Exception DoThrowWhenException { get; set; }

	/**
	 * Map of matchers by method.
	 *
	 * Key: qualifiedMethod
	 * Object: map of method return values by method.
	 */
	
	private Map<fflib_QualifiedMethod, List<fflib_MatchersReturnValue>> matcherReturnValuesByMethod;

	public fflib_MethodReturnValue MethodReturnValue { get; private set; }

	public fflib_MethodReturnValueRecorder()
	{
		matcherReturnValuesByMethod = new Map<fflib_QualifiedMethod, List<fflib_MatchersReturnValue>>();
		
		MethodReturnValue = null;
	}

	/**
	 * Prepare a stubbed method return value.
	 * @param mockInstance The mock object instance.
	 * @param qm The method for which to prepare a return value.
	 * @param methodArg The method argument for which to prepare a return value.
	 */
	public fflib_MethodReturnValue prepareMethodReturnValue(fflib_QualifiedMethod qm, fflib_MethodArgValues methodArg)
	{
		MethodReturnValue = new fflib_MethodReturnValue();

		List<fflib_MatchersReturnValue> matcherReturnValues = matcherReturnValuesByMethod.get(qm);
		if (matcherReturnValues == null)
		{
			matcherReturnValues = new List<fflib_MatchersReturnValue>();
			matcherReturnValuesByMethod.put(qm, matcherReturnValues);
		}
		
		//Register explicit arg values as 'equals' matchers, to preserve old behaviour
		if (!fflib_Match.Matching)
		{
			for (Object arg : methodArg.argValues)
			{
				if (arg == null)
				{
					fflib_Match.isNull();
				}
				else
				{
					fflib_Match.eq(arg);
				}
			}
		}
		
		List<fflib_IMatcher> matchers = fflib_Match.getAndClearMatchers(methodArg.argValues.size());
		matcherReturnValues.add(new fflib_MatchersReturnValue(matchers, MethodReturnValue));

		return MethodReturnValue;
	}

	/**
	 * Get the method return value for the given method call.
	 * @param mockInstance The mock object instance.
	 * @param qm The method for which to prepare a return value.
	 * @param methodArg The method argument for which to prepare a return value.
	 * @return The MethodReturnValue instance.
	 */
	public fflib_MethodReturnValue getMethodReturnValue(fflib_QualifiedMethod qm, fflib_MethodArgValues methodArg)
	{
		List<fflib_MatchersReturnValue> matchersForMethods = matcherReturnValuesByMethod.get(qm);
		if (matchersForMethods != null)
		{
			for (Integer i = matchersForMethods.size() - 1; i >= 0; i--)
			{
				fflib_MatchersReturnValue matchersReturnValue = (fflib_MatchersReturnValue)matchersForMethods.get(i);
				if (fflib_Match.matchesAllArgs(methodArg, matchersReturnValue.matchers))
				{
					return matchersReturnValue.returnValue;
				}
			}
		}

		return null;
	}

	/**
	 * Prepare a stubbed exception for a void method.
	 * @param e The exception to throw.
	 */
	public void prepareDoThrowWhenException(Exception e)
	{
		DoThrowWhenException = e;
	}
}