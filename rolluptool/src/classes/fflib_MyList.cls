/*
 Copyright (c) 2014-2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @nodoc
 */
@isTest
public with sharing class fflib_MyList implements IList
{
	public interface IList
	{
		void add(String value);
		void add(String value1, String value2, String value3, String value4);
		void addMore(String value);
		void add(String[] value); // Test methods with the same name and number of params
		String get(Integer index);
		String get2(Integer index, String value); // This is just a method signature to allow me to test stubbing a method with multiple arguments
		void clear();
		Boolean isEmpty();
		void set(Integer index, Object value);
	}

	public void add(String[] value)
	{
	}

	public void add(String value)
	{
	}

	public void add(String value1, String value2, String value3, String value4)
	{
	}

	public void addMore(String value)
	{
	}

	public String get(Integer index)
	{
		return 'fred';
	}

	public void clear()
	{
	}

	public Boolean isEmpty()
	{
		return true;
	}

	public void set(Integer index, Object value)
	{
	}

	public String get2(Integer index, String value)
	{
		return 'mary';
	}

	public static String getStubClassName()
	{
		return fflib_ApexMocks.extractTypeName(new fflib_ApexMocks().mock(fflib_MyList.class));
	}
}