/*
 Copyright (c) 2016-2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @group Core
 */
public with sharing class fflib_QualifiedMethodAndArgValues
{
	private final fflib_QualifiedMethod qm;
	private final fflib_MethodArgValues args;
	private final Object mockInstance;

	public fflib_QualifiedMethodAndArgValues(fflib_QualifiedMethod qm, fflib_MethodArgValues args, Object mockInstance)
	{
		this.qm = qm;
		this.args = args;
		this.mockInstance = mockInstance;
	}

	public fflib_QualifiedMethod getQualifiedMethod()
	{
		return qm;
	}

	public fflib_MethodArgValues getMethodArgValues()
	{
		return args;
	}

	public Object getMockInstance()
	{
		return mockInstance;
	}

	public override String toString()
	{
		return qm + ' with args: [' + String.join(args.argValues, '],[') + ']';
	}
}