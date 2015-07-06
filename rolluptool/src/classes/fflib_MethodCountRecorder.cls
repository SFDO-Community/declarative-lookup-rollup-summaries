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
public with sharing class fflib_MethodCountRecorder
{
	public Boolean Verifying { get; set; }
	public Integer VerifyCount { get; set; }

	/**
	 * Map of method counts by type name.
	 *
	 * Key: typeName
	 * Object: map of method calls by methodName.
	 *
	 * Key: methodName
	 * Object: map of count by method call argument.
	 */
	private Map<String, Map<String, Map<Object, Integer>>> methodCountsByTypeName;

	public fflib_MethodCountRecorder()
	{
		methodCountsByTypeName = new Map<String, Map<String, Map<Object, Integer>>>();
	}

	/**
	 * Verfiy a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method you expect to have been called.
	 * @param methodArg The argument you expect to have been passed to the method being verified.
	 */
	public void verifyMethodCall(Object mockInstance, String methodName, Object methodArg)
	{
		String typeName = fflib_ApexMocks.extractTypeName(mockInstance);
		System.assertEquals(VerifyCount, getMethodCount(mockInstance, methodName, methodArg), 'Wanted but not invoked: ' + typeName + '.' + methodName + '.');
		Verifying = false;
	}

	/**
	 * Record a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method to be recorded.
	 * @param methodArg The method argument to be recorded.
	 */
	public void recordMethod(Object mockInstance, String methodName, Object methodArg)
	{
		String typeName = fflib_ApexMocks.extractTypeName(mockInstance);
		Map<String, Map<Object, Integer>> methodCountsForType = methodCountsByTypeName.get(typeName);

		if (methodCountsForType == null)
		{
			recordInitialMethodCall(typeName, methodName, methodArg);
		}
		else
		{
			Map<Object, Integer> methodCountsForArg = methodCountsForType.get(methodName);
			Integer count;

			if (methodCountsForArg == null)
			{
				count = null;
			}
			else
			{
				count = methodCountsForArg.get(methodArg);
			}

			if (count == null)
			{
				if (methodCountsForType.get(methodName) == null)
				{
					methodCountsForType.put(methodName, new Map<Object, Integer>());
				}

				methodCountsByTypeName.get(typeName).get(methodName).put(methodArg, 1);
			}
			else
			{
				methodCountsForType.get(methodName).put(methodArg, count + 1);
			}
		}
	}

	private void recordInitialMethodCall(String typeName, String methodName, Object methodArg)
	{
		methodCountsByTypeName.put(typeName, new Map<String, Map<Object, Integer>>());
		methodCountsByTypeName.get(typeName).put(methodName, new Map<Object, Integer>());
		methodCountsByTypeName.get(typeName).get(methodName).put(methodArg, 1);
	}

	private Integer getMethodCount(Object mockInstance, String methodName, Object methodArg)
	{
		String typeName = fflib_ApexMocks.extractTypeName(mockInstance);
		Map<String, Map<Object, Integer>> methodCountsForType = methodCountsByTypeName.get(typeName);

		if (methodCountsForType == null)
		{
			return 0;
		}
		else
		{
			Map<Object, Integer> methodCountsForArg = methodCountsForType.get(methodName);

			if (methodCountsForArg == null)
			{
				return 0;
			}

			Integer methodCounts = methodCountsForArg.get(methodArg);
			return methodCounts == null ? 0 : methodCounts;
		}
	}
}