/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 *	An invocation on a mock.
 *	A place holder for mock, the method that was called and the arguments that were passed.
 *	@group Core
 */
public with sharing class fflib_InvocationOnMock
{
	private fflib_QualifiedMethod qm;
	private fflib_MethodArgValues methodArg;
	private Object mockInstance;

	/**
	 *	Constructor for the class.
	 *  @param qm The fflib_QualifiedMethod instance to be stored.
	 *  @param args The fflib_MethodArgValues instance to be stored.
	 *  @param mockInstance The mock instance to be stored.
	 */
	public fflib_InvocationOnMock(fflib_QualifiedMethod qm, fflib_MethodArgValues args, Object mockInstance)
	{
		this.qm = qm;
		this.methodArg = args;
		this.mockInstance = mockInstance;
	}

	/**
	 *	Returns the argument at the given index.
	 *  @param index The index of the wanted argument.
	 *  @throws ApexMocksException in case the index is out of range.
	 *  @return The argument at the given index.
	 */
	public Object getArgument(Integer index)
	{
		validateIndex(index);
		return methodArg.argValues[index];
	}

	/**
	 *	Returns the list of arguments passed to the method.
	 *  @return The list of arguments.
	 */
	public List<Object> getArguments()
	{
		return methodArg.argValues;
	}

	/**
	 *	Returns fflib_MethodArgValues instance that represents the arguments passed to the method.
	 *  @return The fflib_MethodArgValues instance that represents the arguments passed to the method.
	 */
	public fflib_MethodArgValues getMethodArgValues()
	{
		return methodArg;
	}

	/**
	 *	Returns the fflib_QualifiedMethod instance that represent the fully qualified method called within the invocation.
	 *	@return The method stored in the invocation.
	 */
	public fflib_QualifiedMethod getMethod()
	{
		return qm;
	}

	/**
	 *	Returns the mock object on which the invocation occurs.
	 *	@return The mock object on which the invocation occurs.
	 */
	public Object getMock()
	{
		return mockInstance;
	}

	private void validateIndex(Integer index)
	{
		if(index < 0 || index >= methodArg.argValues.size())
		{
			throw new fflib_ApexMocks.ApexMocksException('Invalid index, must be greater or equal to zero and less of ' + methodArg.argValues.size()+'.');
		}
	}
}