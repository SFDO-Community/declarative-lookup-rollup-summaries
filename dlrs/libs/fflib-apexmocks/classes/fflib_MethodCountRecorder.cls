/*
 Copyright (c) 2014-2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @group Core
 */
public with sharing class fflib_MethodCountRecorder
{
	/*
	 * Map of method arguments by type name.
	 *
	 * Key: qualifiedMethod
	 * Object: list of method arguments.
	 *
	 * Object: map of count by method call argument.
	 */
	private static Map<fflib_QualifiedMethod, List<fflib_MethodArgValues>> methodArgumentsByTypeName =
		new Map<fflib_QualifiedMethod, List<fflib_MethodArgValues>>();

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
	public static Map<fflib_QualifiedMethod, List<fflib_MethodArgValues>> getMethodArgumentsByTypeName()
	{
		return methodArgumentsByTypeName;
	}

	/**
	 * Record a method was called on a mock object.
	 * @param invocation The object holding all the data of the invocation, like the method and arguments and the mock instance.
	 */
	public void recordMethod(fflib_InvocationOnMock invocation)
	{
		List<fflib_MethodArgValues> methodArgs =
			methodArgumentsByTypeName.get(invocation.getMethod());

		if (methodArgs == null)
		{
			methodArgs = new List<fflib_MethodArgValues>();
			methodArgumentsByTypeName.put(invocation.getMethod(), methodArgs);
		}

		methodArgs.add(invocation.getMethodArgValues());

		orderedMethodCalls.add(invocation);
	}
}