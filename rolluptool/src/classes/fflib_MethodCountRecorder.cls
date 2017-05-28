/*
 Copyright (c) 2014-2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @group Core
 */
public with sharing class fflib_MethodCountRecorder
{
	/*
	 * Map of method counts by type name.
	 *
	 * Key: qualifiedMethod
	 * Object: map of method calls by method.
	 *
	 * Key: methodArgValues
	 * Object: map of count by method call argument.
	 */
	private static Map<fflib_QualifiedMethod, Map<fflib_MethodArgValues, Integer>> methodCountsByTypeName =
		new Map<fflib_QualifiedMethod, Map<fflib_MethodArgValues, Integer>>();

	private static List<fflib_InvocationOnMock> orderedMethodCalls =
		new List<fflib_InvocationOnMock>();

	/**
	 * Getter for the list of the methods ordered calls.
	 * @return The list of methods called in order.
	 */
	public static List<fflib_InvocationOnMock> getOrderedMethodCalls()
	{
		return orderedMethodCalls;
	}

	/**
	 * Getter for the map of the method's calls with the related arguments.
	 * @return The map of methods called with the arguments.
	 */
	public static Map<fflib_QualifiedMethod, Map<fflib_MethodArgValues, Integer>> getMethodCountsByTypeName()
	{
		return methodCountsByTypeName;
	}

	/**
	 * Record a method was called on a mock object.
	 * @param invocation The object holding all the data of the invocation, like the method and arguments and the mock instance.
	 */
	public void recordMethod(fflib_InvocationOnMock invocation)
	{
		Map<fflib_MethodArgValues, Integer> methodCountByArgs =
			methodCountsByTypeName.get(invocation.getMethod());

		if (methodCountByArgs == null)
		{
			methodCountByArgs = new Map<fflib_MethodArgValues, Integer>();
			methodCountsByTypeName.put(invocation.getMethod(), methodCountByArgs);
		}

		Integer currentCount = methodCountByArgs.get(invocation.getMethodArgValues());
		Integer newCount = currentCount == null ? 1 : ++currentCount;

		methodCountByArgs.put(invocation.getMethodArgValues(), newCount);

		orderedMethodCalls.add(invocation);
	}
}