/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 *	This class implements the verification modes with Mockito syntax style.
 *	It can be used in the classic verify and in the ordered verify.
 *	@group Core
 */
public with sharing class fflib_VerificationMode
{
	public Integer VerifyMin {get; set;}
	public Integer VerifyMax {get; set;}
	public String CustomAssertMessage { get; set; }

	public enum ModeName {times, atLeast, atMost, between, atLeastOnce, calls}

	public ModeName Method;

	public fflib_VerificationMode()
	{
		VerifyMin = 1;
		VerifyMax = null;
		CustomAssertMessage = null;
		Method = null;
	}

	/**
	* Sets how many times the method is expected to be called.
	  * For InOrder verification we copy Mockito behavior which is as follows;
	 * <ul>
	 * <li>Consume the specified number of matching invocations, ignoring non-matching invocations in between</li>
	 * <li>Fail an assert if the very next invocation matches, but additional matches can still exist so long as at least one non-matching invocation exists before them</li>
	 * </ul>
	 * For example if you had a(); a(); b(); a();
	 * then inOrder.verify(myMock, 2)).a(); or inOrder.verify(myMock, 3)).a(); would pass but not inOrder.verify(myMock, 1)).a();
	 * @param times The number of times you expect the method to have been called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode times(Integer times)
	{
		this.Method = ModeName.times;
		this.VerifyMin = this.VerifyMax = times;
		return this;
	}

	/**
	 * Sets a custom assert message for the verify.
	 * @param customAssertMessage The custom message for the assert in case the assert is false. The custom message is queued to the default message.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode description(String customAssertMessage)
	{
		this.CustomAssertMessage = customAssertMessage;
		return this;
	}

	/**
	 * Sets the minimum number of times the method is expected to be called.
	 * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
	 * @param atLeastTimes The minimum number of times you expect the method to have been called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode atLeast(Integer atLeastTimes)
	{
		this.Method = ModeName.atLeast;
		this.VerifyMin = atLeastTimes;

		return this;
	}

	/**
	 * Sets the maximum number of times the method is expected to be called. Not available in the InOrder verification.
	 * @param atMostTimes The maximum number of times the method is expected to be called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode atMost(Integer atMostTimes)
	{
		this.Method = ModeName.atMost;
		this.VerifyMax = atMostTimes;

		return this;
	}

	/**
	 * Sets that the method is called at least once.
	 * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode atLeastOnce()
	{
		this.Method = ModeName.atLeastOnce;
		this.VerifyMin = 1;

		return this;
	}

	/**
	 * Sets the range of how many times the method is expected to be called. Not available in the InOrder verification.
	 * @param atLeastTimes The minimum number of times you expect the method to have been called.
	 * @param atMostTimes The maximum number of times the method is expected to be called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode between(Integer atLeastTimes, Integer atMostTimes)
	{
		this.Method = ModeName.between;
		this.VerifyMin = atLeastTimes;
		this.VerifyMax = atMostTimes;

		return this;
	}

	/**
	 * Sets that the method is not expected to be called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode never()
	{
		this.VerifyMin = fflib_ApexMocks.NEVER;
		this.VerifyMax = fflib_ApexMocks.NEVER;

		return this;
	}

	/**
	 * Sets how many times the method is expected to be called for an InOrder verifier. Available Only with the InOrder verification.
	 * A verification mode using calls will not fail if the method is called more times than expected.
	 * @param callingTimes The number of times you expect the method to have been called in the InOrder verifying (no greedy verify).
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode calls(Integer callingTimes)
	{
		this.Method = ModeName.calls;
		this.VerifyMin = callingTimes;
		this.VerifyMax = null;

		return this;
	}
}