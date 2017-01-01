/*
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

/**
 * @group Core
 */
public with sharing class fflib_MethodCountRecorder
{
	public Boolean Verifying { get; set; }
	public Integer VerifyCount { get; set; }

	/*
	 * Map of method counts by type name.
	 *
	 * Key: qualifiedMethod
	 * Object: map of method calls by method.
	 *
	 * Key: methodArgValues
	 * Object: map of count by method call argument.
	 */
	private Map<fflib_QualifiedMethod, Map<fflib_MethodArgValues, Integer>> methodCountsByTypeName;

	public fflib_MethodCountRecorder()
	{
		methodCountsByTypeName = new Map<fflib_QualifiedMethod, Map<fflib_MethodArgValues, Integer>>();
	}

	/**
	 * Verify a method was called on a mock object.
	 * @param qm The method you expect to have been called.
	 * @param methodArg The argument you expect to have been passed to the method being verified.
	 */
	public void verifyMethodCall(fflib_QualifiedMethod qm, fflib_MethodArgValues methodArg)
	{
		System.assertEquals(VerifyCount, getMethodCount(qm, methodArg), 'Wanted but not invoked: ' + qm + '.');
		Verifying = false;
	}

	/**
	 * Record a method was called on a mock object.
	 * @param qm The method to be recorded.
	 * @param methodArg The method argument to be recorded.
	 */
	public void recordMethod(fflib_QualifiedMethod qm, fflib_MethodArgValues methodArg)
	{
		Map<fflib_MethodArgValues, Integer> methodCountByArgs = methodCountsByTypeName.get(qm);
		if (methodCountByArgs == null)
		{
			methodCountByArgs = new Map<fflib_MethodArgValues, Integer>();
			methodCountsByTypeName.put(qm, methodCountByArgs);
		}

		Integer currentCount = methodCountByArgs.get(methodArg);
		Integer newCount = currentCount == null ? 1 : ++currentCount;

		methodCountByArgs.put(methodArg, newCount);
	}

	private Integer getMethodCount(fflib_QualifiedMethod qm, fflib_MethodArgValues methodArg)
	{
		List<fflib_IMatcher> matchers = fflib_Match.Matching ? fflib_Match.getAndClearMatchers(methodArg.argValues.size()) : null;
		Integer retval = 0;
		Map<fflib_MethodArgValues, Integer> methodCountByArgs = methodCountsByTypeName.get(qm);
		if (methodCountByArgs != null)
		{
			if (matchers != null)
			{
				for (fflib_MethodArgValues args : methodCountByArgs.keySet())
				{
					if (fflib_Match.matchesAllArgs(args, matchers))
					{
						capture(matchers);

						retval += methodCountByArgs.get(args);
					}
				}
			}
			else if (methodCountByArgs.get(methodArg) != null)
			{
				return methodCountByArgs.get(methodArg);
			}
		}

		return retval;
	}

	private void capture(List<fflib_IMatcher> matchers)
	{
		for(fflib_IMatcher matcher : matchers)
		{
			if( matcher instanceof fflib_ArgumentCaptor.AnyObject )
			{
				((fflib_ArgumentCaptor.AnyObject)matcher).storeArgument();
			}
		}
	}
}