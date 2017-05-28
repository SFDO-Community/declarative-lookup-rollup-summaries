/*
 * Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @group Core
 * Contains counterparts for helper methods in the native System class.
 */

public class fflib_System
{
	/**
	 * Verifies that the supplied argument is meaningfully equivalent to the expected argument, as defined by its matcher.
	 * See fflib_SystemTest for examples of usage.
	 * @param ignoredRetval Dummy value, returned on registering an fflib_IMatcher.
	 * @param value         The object instance upon which we are checking equality.
	 */
	public static void assertEquals(Object ignoredRetval, Object value)
	{
		assertEquals(ignoredRetval, value, null);
	}

	/**
	 * Verifies that the supplied argument is meaningfully equivalent to the expected argument, as defined by its matcher.
	 * See fflib_SystemTest for examples of usage.
	 * @param ignoredRetval Dummy value, returned on registering an fflib_IMatcher.
	 * @param value         The object instance upon which we are checking equality.
	 * @param customAssertMessage Provides context or additional information for the assertion.
	 */
	public static void assertEquals(Object ignoredRetval, Object value, String customAssertMessage)
	{
		fflib_IMatcher matcher = null;
		try
		{
			List<fflib_IMatcher> matchers = fflib_Match.getAndClearMatchers(1);
			matcher = matchers[0];
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			throw new fflib_ApexMocks.ApexMocksException('fflib_System.assertEquals expects you to register exactly 1 fflib_IMatcher (typically through the helpers in fflib_Match).');
		}
		
		if (!matcher.matches(value))
		{
			throw new fflib_ApexMocks.ApexMocksException(String.format('Expected : {0}, Actual: {1}{2}', new String[]{
				String.valueOf(matcher),
				String.valueOf(value),
				String.isBlank(customAssertMessage) ? '' : (' -- ' + customAssertMessage)
			}));
		}
	}
}